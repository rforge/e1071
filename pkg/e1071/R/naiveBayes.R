naiveBayes <- function(x, ...)
    UseMethod("naiveBayes")

naiveBayes.default <- function(x, y, laplace = 0, ...) {
    call <- match.call()
    Yname <- deparse(substitute(y))
    x <- as.data.frame(x)
    if (is.logical(y))
        y <- factor(y, levels = c("FALSE", "TRUE"))
    
    ## estimation-function
    est <- function(var)
        if (is.numeric(var)) {
            cbind(tapply(var, y, mean, na.rm = TRUE),
                  tapply(var, y, sd, na.rm = TRUE))
        } else {
            if (is.logical(var))
                var <- factor(var, levels = c("FALSE", "TRUE"))
            tab <- table(y, var)
            (tab + laplace) / (rowSums(tab) + laplace * nlevels(var))
        }

    ## create tables
    apriori <- table(y)
    tables <- lapply(x, est)
    isnumeric <- vapply(x, is.numeric, NA)

    ## fix dimname names
    for (i in 1:length(tables))
        names(dimnames(tables[[i]])) <- c(Yname, colnames(x)[i])
    names(dimnames(apriori)) <- Yname

    structure(list(apriori = apriori,
                   tables = tables,
                   levels = names(apriori),
                   isnumeric = isnumeric,
                   call   = call
                   ),

              class = "naiveBayes"
              )
}

naiveBayes.formula <- function(formula, data, laplace = 0, ...,
                               subset, na.action = na.pass) {
    call <- match.call()
    Yname <- as.character(formula[[2]])

    if (is.data.frame(data)) {
        ## handle formula
        m <- match.call(expand.dots = FALSE)
        m$... <- NULL
        m$laplace = NULL
        m$na.action <- na.action
        m[[1L]] <- quote(stats::model.frame)
        m <- eval(m, parent.frame())
        Terms <- attr(m, "terms")
        if (any(attr(Terms, "order") > 1))
            stop("naiveBayes cannot handle interaction terms")
        Y <- model.extract(m, "response")
        X <- m[,gsub("`", "", labels(Terms)), drop = FALSE]

        return(naiveBayes(X, Y, laplace = laplace, ...))
    } else if (is.array(data)) {
        nam <- names(dimnames(data))
        ## Find Class dimension
        Yind <- which(nam == Yname)

        ## Create Variable index
#        deps <- strsplit(as.character(formula)[3], ".[+].")[[1]]
        deps <- labels(terms(formula, data = data))
        if (length(deps) == 1 && deps == ".")
            deps <- nam[-Yind]
        Vind <- which(nam %in% deps)

        ## create tables
        apriori <- margin.table(data, Yind)
        tables <- lapply(Vind,
                         function(i) (margin.table(data, c(Yind, i)) + laplace) /
                         (as.numeric(apriori) + laplace * dim(data)[i]))
        names(tables) <- nam[Vind]

        isnumeric = rep(FALSE, length(Vind))
        names(isnumeric) <- nam[Vind]

        structure(list(apriori = apriori,
                       tables = tables,
                       levels = names(apriori),
                       isnumeric = isnumeric,
                       call   = call
                       ),

                  class = "naiveBayes"
                  )
    } else stop("naiveBayes formula interface handles data frames or arrays only")

}


print.naiveBayes <- function(x, ...) {
    cat("\nNaive Bayes Classifier for Discrete Predictors\n\n")
    cat("Call:\n")
    print(x$call)
    cat("\nA-priori probabilities:\n")
    print(x$apriori / sum(x$apriori))

    cat("\nConditional probabilities:\n")
    for (i in x$tables) {print(i); cat("\n")}

}

predict.naiveBayes <- function(object,
                               newdata,
                               type = c("class", "raw"),
                               threshold = 0.001,
                               eps = 0,
                               ...) {
    type <- match.arg(type)
    newdata <- as.data.frame(newdata)

    ## fix factor levels to be identical with training data
    for (i in names(object$tables)) {
        if (!is.null(newdata[[i]]) && !is.numeric(newdata[[i]]))
            newdata[[i]] <- factor(newdata[[i]], levels = colnames(object$tables[[i]]))
        if (object$isnumeric[i] != is.numeric(newdata[[i]]))
            warning(paste0("Type mismatch between training and new data for variable '", i,
                           "'. Did you use factors with numeric labels for training, and numeric values for new data?"))
    }

    attribs <- match(names(object$tables), names(newdata))
    isnumeric <- vapply(newdata, is.numeric, NA)
    islogical <- vapply(newdata, is.logical, NA)
    newdata <- data.matrix(newdata)
    len <- length(object$apriori)
    L <- vapply(seq_len(nrow(newdata)), function(i) {
        ndata <- newdata[i, ]
        L <- log(object$apriori) + apply(log(vapply(seq_along(attribs),
            function(v) {
                nd <- ndata[attribs[v]]
                if (is.na(nd)) rep.int(1, len) else {
                  prob <- if (isnumeric[attribs[v]]) {
                    msd <- object$tables[[v]]
                    msd[, 2][msd[, 2] <= eps] <- threshold
                    dnorm(nd, msd[, 1], msd[, 2])
                  } else object$tables[[v]][, nd + islogical[attribs[v]]]
                  prob[prob <= eps] <- threshold
                  prob
                }
            }, double(len))), 1, sum)
        if (type == "class")
            L
        else {
            ## Numerically unstable:
            ##            L <- exp(L)
            ##            L / sum(L)
            ## instead, we use:
            vapply(L, function(lp) {
                1/sum(exp(L - lp))
            }, double(1))
        }
    }, double(len))
    if (type == "class") {
        if (is.logical(object$levels))
            L[2,] > L[1,]
        else
            factor(object$levels[apply(L, 2, which.max)], levels = object$levels)
    } else t(L)
}
