\name{pgm}
\title{Portable Graymap Images}
\usage{
read.pgm(file)
write.pgm(pgmobj, file="Rimage.pgm", forceplain=FALSE)
plot(pgmobj, xlab=NULL, ylab=NULL, axes=FALSE, ...)
}
\alias{write.pgm}
\alias{read.pgm}
\alias{plot.pgm}
\arguments{
  \item{pgmobj}{an object of class \code{pgm}}
  \item{file}{name of the pgm file}
  \item{forceplain}{If \code{TRUE}, an ASCII pgm file is written. Default
    is to write a binary (raw) pgm file.}
}
\description{
  \code{read.pgm} reads a pgm file and loads the image into an
  object of class \code{pgm}, which is basically a
  matrix. \code{write.pgm} writes an object of class \code{pgm} to a
  file.

  \code{plot.pgm} plots a pgm object using the command
  \code{\link{image}}. The only difference is that the element \code{[1,1]} of
  \code{pgmobj} is plotted as the upper left corner (plain
  \code{\link{image}} would plot \code{[1,1]} as the lower left corner.
}
\value{
  \code{read.pgm} returns an object of class \code{pgm}. The maximum
  gray value (corresponding to the color black) is stored as attribute
  \code{"maxval"}). 
}
\author{Friedrich Leisch}
\seealso{\code{\link{image}}}
\keyword{file,hplot}
