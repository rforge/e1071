sparsify <- function (x,y=NULL) {
  if (!is.numeric(x)) stop("x should be numeric!")
  x <- as.matrix(x)
  if (!is.null(y)) {
    if (length(y) != nrow(x))
      stop (paste ("Length of y (=",
                   length(y),
                   ") does not match number of rows of x (=",
                   nrow(x),
                   ")!", sep=""))
  }
  colnames(x) <- 1:ncol(x)
  m <- lapply(1:nrow(x),	
             function (yy) {
               v <- x[yy,]
               names(v) <- colnames(x)
               if (length(ret <- v[is.na(v) | v!=0])) ret
             }
             )
  names(m) <- 1:nrow(x)
  m <- m[!sapply(m,is.null)]
  attr(m, "ncol") <- ncol(x)
  attr(m, "nrow") <- nrow(x)
  class(m) <- "sparse.matrix"
  if (is.null(y)) {
    m
  } else {
    s <- list(x=m, y=y)
    class (s) <- "sparse.svm.data"
    s
  }
}

desparsify <- function (x)
  UseMethod("desparsify")

desparsify.sparse.svm.data <- function (x)
  list(x=desparsify(x$x), y=x$y)

desparsify.sparse.matrix <- function (x) {
  ret  <- matrix(0, attr(x, "nrow"), attr(x, "ncol"))
  rows <- as.numeric(names(x))
  for (i in 1:length(x))
    for (j in 1:length(x[[i]])) {
      cols <- as.numeric(names(x[[i]]))
      ret[rows[i], cols[j]] <- x[[i]][j]
    }
  ret
}

"[.sparse.matrix" <- function (x, i, j) {

  # x[i] -> return sparse row vector
  if (nargs() < 3) {
    # x[] -> return x
    if (missing(i)) return(x)
    if (is.logical(i)) i <- (1:length(i))[i]
    if (as.numeric(i) > length(x)) stop("subscript out of bounds")
    ret <- NextMethod("[")
    class(ret) <- "sparse.matrix"
    attr(ret, "ncol") <- attr(x, "ncol")
    attr(ret, "nrow") <- 1
    return(ret)
  }

  # x[,] -> return desparsified matrix
  if (missing(i) && missing(j)) return(desparsify(x))
  
  # x[i,] -> return desparsified row vector
  if (missing(j)) {
    if (is.logical(i)) i <- (1:length(i))[i]
    if (length(i)>1) return(t(sapply(i, function (xx) x[xx,])))
    if (i > attr(x, "nrow")) stop("subscript out of bounds") 
    if (as.character(i) %in% names(x)) {
      y <- x[as.character(i)]
      names(y)[1] <- "1"
      y <- desparsify(y)
      return(if (nrow(y) == 1) as.vector(y) else y)
    } else return(rep(0, attr(x, "ncol")))
  }

  # x[,j] -> return desparsified column vector
  if (missing(i)) {
    if (is.logical(j)) i <- (1:length(j))[j]
    if (length(j)>1) return(sapply(j, function (xx) x[,xx]))
    if (j > attr(x, "ncol")) stop("subscript out of bounds") 
    ret  <- rep(0, attr(x, "ncol"))
    rows <- as.numeric(names(x))
    for (i in 1:length(x)) {
       v <- x[[i]][as.character(j)]
       ret[rows[i]] <- if (is.na(v)) 0 else v
     }
    return(ret)
  }

  # x[i,j] -> return value
  if (j > attr(x, "ncol") || i > attr(x, "nrow")) stop("subscript out of bounds") 
  return(if (length(i)>1) x[i,][,j] else x[i,][j])
}

print.sparse.svm.data <- function (x, ...) {
  cat("x:\n")
  print(x$x)
  cat("y:\n")
  print(x$y)
}

print.sparse.matrix <- function (x, ...) {
  nam <- names(x)
  for (i in 1:length(x)) {
    cat ("x[", nam[i],",]:\n", sep="")
    print(x[[i]])
    cat ("\n")
  }
}

na.omit.sparse.matrix <- function (object, ...) {
  nas <- sapply (object, function(x) any(is.na(x)))
  nams <- 1:attr(object,"nrow") %in% as.numeric(names(object))
  ret <- unclass(object)[!nas]
  tmp <- rep(TRUE,attr(object,"nrow"))
  tmp[as.numeric(names(nas))] <- !nas   
  tmp2 <- rep(FALSE,attr(object,"nrow"))
  tmp2[as.numeric(names(nas))] <- !nas   
  names(ret) <- cumsum(tmp)[tmp2]
  attr (ret, "nrow") <- attr (object, "nrow") - sum(nas)
  attr (ret, "ncol") <- attr (obhect, "ncol")
  class(ret) <- "sparse.matrix"
  ret
}

na.fail.sparse.matrix <- function (object, ...) {
  if (any(is.na(object)))
    stop("missing values in object")
  else
    object
}

is.na.sparse.matrix <- function (x) {
  sapply (x, function(xx) any(is.na(xx)))
}

read.sparse <- function (file, fac=FALSE, ncol=NULL) {
  con <- file(file)
  open (con)
  y <- vector()
  x <- list()
  i <- 1
  maxcol <- 1
  while (isOpen(con) & length(buf <- readLines (con, 1))>0) {
    s <- strsplit(buf, " ")[[1]]
    
    ## y
    if (length(grep(":", s[1])) == 0) {
      y[i] <- if (fac) s[1] else as.numeric(s[1])
      s <- s[-1]
    }

    nam <- x[[i]] <- vector()
    ## x-values
    if (length(s))
      for (ii in 1:length(s)) {
        ss <- strsplit(s[[ii]], ":")[[1]]
        x[[i]][ii] <- as.numeric(ss[2])
        nam[ii]    <- ss[1]
        maxcol     <- max(as.numeric(ss[1]), maxcol)
      }
    names (x[[i]]) <- nam
    i <- i + 1
  }
  names(x) <- 1:(i-1)
  class(x) <- "sparse.matrix"
  attr(x, "nrow") <- i-1
  attr(x, "ncol") <- if (is.null(ncol)) maxcol else max(ncol,maxcol)
  if (length(y)) {
    ret <- list (x=x, y=if (fac) as.factor(y) else y)
    class (ret) <- "sparse.svm.data"
    ret
  } else x
}

write.sparse <- function (x, file)
  UseMethod ("write.sparse")

write.sparse.default <- function (x, file="out.dat", y=NULL) {
  if (!is.null(y) & (length(y) != nrow(x)))
    stop(paste("Length of y (=", length(y),
                 ") does not match number of rows of x (=",
                 nrow(x), ")!", sep=""))
  sink(file)
  for (i in 1:nrow(x)) {
    if (!is.null(y)) cat (y[i]," ")
    for (j in 1:ncol(x))
      if (x[i,j] != 0)
        cat(j, ":", x[i,j], " ", sep="")
    cat("\n")
  }
  sink()
}

write.sparse.sparse.svm.data <- function (x, file="out.dat") {
  sink (file)
  count <- 1
  nam <- as.numeric(names (x$x))
  for (i in 1:length(x$x)) {
    if (!is.null(x$y)) cat (x$y[i]," ")
    if (nam[count] == i) {
      for (j in 1:length(x$x[[i]]))
        cat(names(x$x[[i]])[j], ":", x$x[[i]][j], " ", sep="")
      count <- count + 1
    }
    cat ("\n")
  }
  sink()
}

write.sparse.sparse.matrix <- function (x, file="out.dat")
  write.sparse.sparse.svm.data (list (x=x, y=NULL), file)
