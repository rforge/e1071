\name{sparsify}
\alias{sparsify}
\alias{desparsify}
\alias{desparsify.sparse.matrix}
\alias{desparsify.sparse.svm.data}
\alias{write.sparse}
\alias{write.sparse.default}
\alias{write.sparse.sparse.matrix}
\alias{write.sparse.sparse.svm.data}
\alias{read.sparse}
\alias{print.sparse.matrix}
\alias{print.sparse.svm.data}
\alias{[.sparse.matrix}

%- Also NEED an `\alias' for EACH other topic documented here.
\title{Sparce Matrices Support}
\description{
A suite of functions for supporting the handling of sparse matrices
(sparsifying, desparsifying, reading, and writing), with special support
for Support Vector Machines.
}
\usage{
sparsify(x, y=NULL)

\method{desparsify}{sparse.svm.data}(x)
\method{desparsify}{sparse.matrix}(x)

read.sparse(file, fac=FALSE)

\method{write.sparse}{default}(x, file="out.dat", y=NULL)
\method{write.sparse}{sparse.svm.data}(x, file="out.dat")
\method{write.sparse}{sparse.matrix}(x, file="out.dat")

\method{print}{sparse.svm.data}(x, ...)
\method{print}{sparse.matrix}(x, ...)

}
%- maybe also `usage' for other objects documented here.
\arguments{
  \item{x}{A data object, i.e. a matrix for \code{sparsify} and
    \code{write.sparse.default} and a sparse object
    (\code{sparse.matrix} or {sparse.svm.data}) for the others.}
  \item{y}{A vector (either numeric or a factor)}
  \item{file}{File path for \code{read.sparse} and \code{write.sparse}}
  \item{fac}{Option whether the \code{y}-values possibly read by
    \code{read.sparse} should be transformed into a factor.}
  \item{\dots}{Additional arguments for the \code{print}-methods.}
}
\details{
if \code{x} is a sparse matrix, \code{x[i]} returns a sparse structure,
\code{i} referring to the internal sparse structure of \code{x}, whereas
\code{x[i,]}, \code{x[,j]}, \code{x[i,j]} and \code{x[,]} return
desparsified data, the indices referring to the full matrix.
}
\value{
  \code{sparsify} and \code{read.sparse} return a sparse object
  (\code{sparse.matrix} or \code{sparse.svm.data}, depending on whether
  a response variable is specified or not).
  \code{sparse.matrix} is a list of vectors, the lists' names indicate the
  row numbers. Each element of this list corresponds to a row of the
  original matrix; the names of each vector indicate the columns of the
  values in the original matrix.
  \code{desparsify.sparse.matrix} returns an ordinary matrix, whereas
  \code{desparsify.sparse.svm.data} returns a list with two components:
  A matrix \code{x} and a vector \code{y} (which is just copied from the
  sparse structure).
  \code{sparse.svm.data}, suitable for the use with Support Vector
  Machines (see \code{svm()}), is a list with two components:
  \item{x}{An object of type \code{sparse.matrix}}
  \item{y}{A vector (either numeric or a factor)}
}
\author{
  David Meyer\cr
  \email{david.meyer@ci.tuwien.ac.at}
}
\seealso{\code{\link{svm}}}

\examples{
library (e1071)

## create sparse matrix
d <- matrix (1:100,10,10)
d[2:9,2:9] <- 0
d

## sparsify
sp <- sparsify (d)
sp

## access to a sparse line:
sp[3]

## indexing works as usual:
sp[3,]
sp[,4]
sp[2:9,2:9]

## desparsify
desparsify (sp)

## create a sparse svm-data-object:
svmd <- sparsify (d, y=factor(c(rep ("a",5),rep("b",5))))
m <- svm (svmd)
m
}
\keyword{manip}
\keyword{array}
