tune <- function(method, train.x, train.y = NULL, data = list(),
                 validation.x = NULL, validation.y = NULL,
                 ranges,
                 random = FALSE,
                 nrepeat = 1,
                 repeat.aggregate = min,
                 sampling = c("cross", "fix", "bootstrap"),
                 sampling.aggregate = mean,
                 cross = 10,
                 fix = 2 / 3,
                 nboot = 10,
                 boot.size = 9 / 10,
                 predict.func = predict,
                 best.model = TRUE,
                 performances = TRUE,
                 ...
                 ) {
  ## internal helper function
  resp <- function(formula, data)
    model.response(model.frame(formula, data))
  
  ## parameter handling
  sampling <- match.arg(sampling)
  method <- deparse(substitute(method))
  if (sampling == "cross") validation.x <- validation.y <- NULL
  useFormula <- is.null(train.y)
  
  ## prepare training indices
  if (!is.null(validation.x)) fix <- 1
  n <- nrow(if (useFormula) data else train.x)
  perm.ind <- sample(n)

  train.ind <- if (sampling == "cross")
    tapply(1:n, cut(1:n, breaks = cross), function(x) perm.ind[-x])
  else if (sampling == "fix")
    list(perm.ind[1:trunc(n * fix)])
  else ## bootstrap
    lapply(1:nboot, function(x) sample(n, n * boot.size))

  ## find best model
  parameters <- expand.grid(ranges)
  p <- nrow(parameters)
  if (!is.logical(random)) {
    if (random < 1)
      stop ("random must be a strictly positive integer")
    if (random > p) random <- p
    parameters <- parameters[sample(1:p, random),]
  }
  model.errors <- c()
  
  ## - loop over all models
  for (para.set in 1:p) {
    sampling.errors <- c()
    
    ## - loop over all training samples
    for (sample in 1:length(train.ind)) {
      repeat.errors <- c()
      
      ## - repeat training `nrepeat' times
      for (reps in 1:nrepeat) {
        
        ## train one model
        model <- if (useFormula) 
          do.call(method, c(list(train.x,
                                 data = data,
                                 subset = train.ind[[sample]]), 
                            parameters[para.set,,drop = FALSE], ...
                            )
                  )
        else 
          do.call(method, c(list(train.x[train.ind[[sample]],],
                                 y = train.y[train.ind[[sample]]]),
                            parameters[para.set,,drop = FALSE], ...
                            )
                  )

        ## predict validation set
        pred <- predict.func(model,
                        if (!is.null(validation.x))
                          validation.x
                        else if (useFormula)
                          data[-train.ind[[sample]],]
                        else
                          train.x[-train.ind[[sample]],]
                        )
        
        ## compute performance measure
        true.y <- if (!is.null(validation.y))
          validation.y
        else if (useFormula)
          resp(train.x, data[-train.ind[[sample]],])
        else
          train.y[-train.ind[[sample]]]
        
        repeat.errors[reps] <- if (is.factor(true.y)) ## classification error
          1 - classAgreement(table(pred, true.y), match.names = TRUE)$diag
        else ## mean squared error
          crossprod(pred - true.y) / length(pred)
      }
      sampling.errors[sample] <- repeat.aggregate(repeat.errors)
    }
    model.errors[para.set] <- sampling.aggregate(sampling.errors)
  }

  ## return results
  best <- which.min(model.errors)
  structure(list(best.parameters  = parameters[best,,drop = FALSE],
                 best.performance = model.errors[best],
                 method           = method,
                 sampling         = switch(sampling,
                   fix = "fixed training/validation set",
                   bootstrap = "bootstrapping",
                   cross = if (cross == 1) "leave-one-out" else
                           paste(cross,"-fold cross validation", sep="")
                   ),
                 data             = if (useFormula)
                                      deparse(substitute(data))
                                    else
                                      deparse(substitute(train.x)),
                 performances     = if (performances) cbind(parameters, error = model.errors),
                 best.model       = if (best.model)
                   if (useFormula) 
                     do.call(method, c(list(train.x, data = substitute(data)),
                                       parameters[best,,drop = FALSE], ...))
                   else 
                     do.call(method, c(list(x = substitute(train.x),
                                            y = substitute(train.y)),
                                       parameters[best,,drop = FALSE], ...))
                 ),
            class = "tune"
       )
}

print.tune <- function(x, ...) {
  cat("\nParameter tuning of `", x$method, sep="")
  cat("' on `", x$data, "' data:\n\n", sep="")
  cat("- sampling method:", x$sampling,"\n\n")
  cat("- best parameters:\n")
  print(x$best.parameters)
  cat("\n- best performance:", x$best.performance, "\n")
  cat("\n")
}

summary.tune <- function(object, ...)
  structure(object, class = "summary.tune")

print.summary.tune <- function(x, ...) {
  print.tune(x)
  if (!is.null(x$performances)) {
    cat("- Detailed performance results:\n")
    print(x$performances)
    cat("\n")
  }
}

plot.tune <- function(x,
                      type=c("contour","perspective"),
                      theta=60,
                      col="lightblue",
                      main = NULL,
                      xlab = NULL,
                      ylab = NULL,
                      ...)
{
  if (is.null(x$performance))
    stop("Object does not contain detailed performance measures!")
  k <- ncol(x$performance) 
  if (k > 3) stop("Cannot visualize more than 2 parameters")
  type = match.arg(type)

  if (is.null(main))
    main <- paste("Performance of `",x$method,"' on `",x$data,"'", sep="")
  
  if (k == 2)
    plot(x$performances, type = "b", main = main)
  else  {
    x <- xtabs(error~., data = x$performances)
    if (is.null(xlab)) xlab <- names(dimnames(x))[1]
    if (is.null(ylab)) ylab <- names(dimnames(x))[2]
    if (type == "perspective")
      persp(x=as.double(rownames(x)),
            y=as.double(colnames(x)),
            z=x,
            xlab=xlab,
            ylab=ylab,
            zlab="accuracy",
            theta=theta,
            col=col,
            ticktype="detailed",
            main = main,
            ...
            )
    else
      filled.contour(x=as.double(rownames(x)),
                     y=as.double(colnames(x)),
                     xlab=xlab,
                     ylab=ylab,
                     nlevels=20,
                     main = main,
                     x, ...)
    }
}

#############################################
## convenience functions for some methods
#############################################

tune.svm <- function(x, degree = NULL, gamma = NULL,
    coef0 = NULL, cost = NULL, nu = NULL, ...) {
  ranges <- list(degree = degree, gamma = gamma,
    coef0 = coef0, cost = cost, nu = nu)
  ranges[sapply(ranges, is.null)] <- NULL
  if (length(ranges) < 1)
    stop("No parameter range given.")
  tune(svm, train.x = x, ranges = ranges, ...)
}
  
best.svm <- function(x, ...)
  tune.svm(x, ..., best.model = TRUE)$best.model

tune.nnet <- function(x, size = NULL, decay = NULL, nrepeat = 5, trace = FALSE,
                      predict.func = function(...) predict(..., type="class"), ...) {
  require(nnet)
  ranges <- list(size = size, decay = decay)
  ranges[sapply(ranges, is.null)] <- NULL
  if (length(ranges) < 1)
    stop("No parameter range given.")
  tune(nnet, train.x = x, ranges = ranges, nrepeat = nrepeat, trace = trace,
       predict.func = predict.func, ...)
}

best.nnet <- function(x, ...)
  tune.nnet(x, ..., best.model = TRUE)$best.model

tune.randomForest <- function(x, nodesize = NULL, mtry = NULL, ntree = NULL, ...) {
  require(randomForest)
  ranges <- list(nodesize = nodesize, mtry = mtry, ntree = ntree)
  ranges[sapply(ranges, is.null)] <- NULL
  if (length(ranges) < 1)
    stop("No parameter range given.")
  tune(randomForest, train.x = x, ranges = ranges, ...)
}
  
best.randomForest <- function(x, ...)
  tune.randomForest(x, ..., best.model = TRUE)$best.model

knn.wrapper <- function(x, y, k = 1, l = 0, ...)
  list(train = x, cl = y, k = k, l = l, ...)

tune.knn <- function(x, y, k = NULL, l = NULL, ...) {
  require(class)
  ranges <- list(k = k, l = l)
  ranges[sapply(ranges, is.null)] <- NULL
  if (length(ranges) < 1)
    stop("No parameter range given.")
  tune(knn.wrapper,
       train.x = x, train.y = y, ranges = ranges,
       predict.func = function(x, ...) knn(train = x$train, cl = x$cl, k = x$k, l = x$l, ...),
       ...)
}

rpart.wrapper <- function(formula, minsplit=20, minbucket=round(minsplit/3), cp=0.01, 
                   maxcompete=4, maxsurrogate=5, usesurrogate=2, xval=10,
                   surrogatestyle=0, maxdepth=30, ...)
  rpart(formula, control = rpart.control(minsplit=minsplit, minbucket=minbucket, cp=cp, 
                 maxcompete=maxcompete, maxsurrogate=maxsurrogate,
                 usesurrogate=usesurrogate, xval=xval,
                 surrogatestyle=surrogatestyle, maxdepth=maxdepth),
        ...
        )

tune.rpart <- function(formula, data, na.action = na.omit,
                       minsplit=NULL, minbucket=NULL, cp=NULL, 
                       maxcompete=NULL, maxsurrogate=NULL, usesurrogate=NULL, xval=NULL,
                       surrogatestyle=NULL, maxdepth=NULL,
                       predict.func = NULL,
                       ...) {
  require(rpart)
  ranges <- list(minsplit=minsplit, minbucket=minbucket, cp=cp, 
                 maxcompete=maxcompete, maxsurrogate=maxsurrogate,
                 usesurrogate=usesurrogate, xval=xval,
                 surrogatestyle=surrogatestyle, maxdepth=maxdepth)
  ranges[sapply(ranges, is.null)] <- NULL
  if (length(ranges) < 1)
    stop("No parameter range given.")
  
  predict.func <- if (is.factor(model.response(model.frame(formula, data))))
    function(...) predict(..., type="class")
  else
    predict
  tune(rpart.wrapper, train.x = formula, data = data, ranges = ranges,
       predict.func = predict.func, na.action = na.omit, ...)
}
  
best.rpart <- function(formula, ...)
  tune.rpart(formula, ..., best.model = TRUE)$best.model





