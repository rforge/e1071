svm <-
function (x,
          y,
          svm.type    = NULL,
          kernel.type = "radial",
          degree      = 3,
          gamma       = 1/dim(x)[2],
          coef0       = 0,
          cost        = 1,
          nu          = 0.5,
          cachesize   = 40,
          tolerance   = 0.001,
          epsilon     = 0.5)
{
  if (is.null (svm.type)) svm.type <-
      if (is.factor(y)) "C-classification" else "regression"

  svm.type    <- pmatch (svm.type, c("C-classification",
                                     "nu-classification",
                                     "one-classification",
                                     "regression")) - 1
  
  kernel.type <- pmatch (kernel.type, c("linear",
                                        "polynomial",
                                        "radial",
                                        "sigmoid")) - 1

  if (!is.matrix(x))          stop ("x must be a matrix.")
  if (!is.vector(y))          stop ("y must be a vector.")
  if (length(y) != dim(x)[1]) stop ("x and y don't match.")

  if (cachesize < 0.1) cachesize <- 0.1
  
  lev <- NULL
  # in case of classification: map levels into {-1,1}
  if (is.factor(y)) {
    lev <- levels (y)
    y <- codes (y) * 2 - 3
  } else if (svm.type < 3) {
    lev <- levels (as.factor (y))
    y <- codes (as.factor(y)) * 2 - 3
  }

  if (length (lev) > 2) stop ("sorry, can't handle more than 2 classes !")
    
  cret <- .C ("svmtrain",
              as.double  (t(x)), as.integer(dim (x)[1]), as.integer(dim(x)[2]),
              as.double  (y),
              as.integer (svm.type),
              as.integer (kernel.type),
              as.double  (degree),
              as.double  (gamma),
              as.double  (coef0),
              as.double  (cost),
              as.double  (nu),
              as.double  (cachesize),
              as.double  (tolerance),
              as.double  (epsilon),
              nr    = integer (1),
              index = integer (dim(x)[1]),
              coefs = double  (dim(x)[1]),
              rho   = double  (1)
             )
  
  ret <- list (
               call        = match.call(),
               svm.type    = svm.type,
               kernel.type = kernel.type,
               cost        = cost,
               degree      = degree,
               gamma       = gamma,
               coef0       = coef0,
               nu          = nu,
               epsilon     = epsilon,
               
               levels      = lev,
               nr          = cret$nr,                  #number of sv
               sv          = x[cret$index==1,],        #copy of sv
               index       = which (cret$index==1),    #indexes of sv in x
               rho         = cret$rho,                 #constant in decision function
               coefs       = cret$coefs[cret$index==1] #coefficiants of sv
              )
  class (ret) <- "svm"
  ret
} 

predict.svm <- function (model, x, type = c("raw","class")) {
  if (length (x) != dim (model$sv)[2]) stop ("test vector does not match model !")

  type <- match.arg (type)
  
  ret <- .C ("svmclassify",
             #model
             as.double  (t(model$sv)),
             as.integer(dim (model$sv)[1]), as.integer(dim(model$sv)[2]),
             as.double  (model$coefs),
             as.double  (model$rho),
             
             #parameter
             as.integer (model$svm.type),
             as.integer (model$kernel.type),
             as.double  (model$degree),
             as.double  (model$gamma),
             as.double  (model$coef0),

             #test vector
             as.double (x),
             
             #decision-value
             ret = double  (1)
            )$ret

  if ((type == "raw") || is.null(model$level))
    ret
  else if (sign (ret) < 0)
    model$level[1]
  else
    model$level[2]
}

print.svm <- function (model) {
  cat ("\nCall:\n",deparse (model$call),"\n\n")
  cat ("Parameters:\n")
  cat ("   SVM-Type: ",c("C-classification",
                         "nu-classification",
                         "one-classification",
                         "regression")[model$svm.type+1],"\n")
  cat (" SVM-Kernel: ",c("linear",
                         "polynomial",
                         "radial",
                         "sigmoid")[model$kernel.type+1],"\n")
  cat ("       cost: ",model$cost,"\n")
  cat ("     degree: ",model$degree,"\n")
  cat ("      gamma: ",model$gamma,"\n")
  cat ("     coef.0: ",model$coef0,"\n")
  cat ("         nu: ",model$nu,"\n")
  cat ("    epsilon: ",model$epsilon,"\n")
  cat ("       cost: ",model$cost,"\n\n")
  
  cat ("\nNumber of Support Vectors:\n",model$nr,"\n\n")
  cat ("Rho:\n",model$rho,"\n\n")
  
  
}

summary.svm <- function (x) {
  print (x)
  cat ("Support Vectors:\n")
  print (x$sv)
  cat ("\n\nCoefficiants:\n")
  print (x$coefs)
  cat ("\n\n")
}
  
