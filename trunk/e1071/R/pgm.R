plot.pgm <- function(pgmobj, xlab=NULL, ylab=NULL,
                     axes=FALSE, ...){

  d <- dim(pgmobj)
  maxval <- attr(pgmobj, "maxval")
  image(x=1:d[2], y=1:d[1], z=t(pgmobj[d[1]:1,]),
        col=gray((0:maxval)/maxval),
        xlab=xlab, ylab=ylab, axes=axes, ...)

}

read.pgm <- function(file){

  pgmhead <- .C("readpgminit",
                file = as.character(file),
                nc = as.integer(1),
                nr = as.integer(1),
                maxval = as.integer(1))

  retval <- .C("readpgm",
               file = as.character(file),
               image = integer(pgmhead$nc * pgmhead$nr))
  
  retval <- matrix(retval$image, ncol = pgmhead$nc, byrow=TRUE)
  attr(retval, "maxval") <- pgmhead$maxval
  class(retval) <- "pgm"
  retval
}


write.pgm <- function(pgmobj, file="Rimage.pgm",
                      forceplain=FALSE){

  retval <- .C("writepgm",
               file = as.character(file),
               image = as.integer(t(pgmobj)),
               nc = as.integer(ncol(pgmobj)),
               nr = as.integer(nrow(pgmobj)),
               maxval = as.integer(attr(pgmobj, "maxval")),
               forceplain = as.integer(forceplain))
}
            
