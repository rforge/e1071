\name{predict.svm}
\alias{predict.svm}
\title{Predict method for Support Vector Machines}
\description{
  This function predicts values based upon a model trained by \code{svm}.
}
\method{predict}{svm}{predict.svm(object, newdata, ...)}

\arguments{
  \item{object}{object of class \code{"svm"}, created by \code{svm}.}
  \item{newdata}{a matrix containing the new input data.}
  \item{\dots}{currently not used.}
}
\value{
  The predicted value.
}
\references{
  \itemize{
    \item
      Chang, Chih-Chung and Lin, Chih-Jen:\cr
      \emph{LIBSVM 2.0: Solving Different Support Vector Formulations.}\cr
      \url{http://www.csie.ntu.edu.tw/~cjlin/papers/libsvm2.ps.gz}
    
    \item 
      Chang, Chih-Chung and Lin, Chih-Jen:\cr
      \emph{Libsvm: Introduction and Benchmarks}\cr
      \url{http://www.csie.ntu.edu.tw/~cjlin/papers/q2.ps.gz}
    
  }
}
\author{
  David Meyer (based on C++-code by Chih-Chung Chang and Chih-Jen Lin)\cr
  \email{david.meyer@ci.tuwien.ac.at}
}
\seealso{
  \code{\link{svm}}
}
\examples{
data(iris)
attach(iris)

# default with factor response: classification mode
model <- svm (Species~., data=iris)

# alternatively the classical interface:
x <- subset (iris, select = -Species)
y <- Species
model <- svm (x, y) 

print (model)
summary (model)

# test with train data
pred <- predict (model, x)

# should be TRUE:
all.equal (pred, y)

# try regression mode on two dimensions in linear mode
model <- svm (Petal.Length ~ Petal.Width, type="eps-regression", kernel="linear")
print (model)


pred <- predict (model, Petal.Length)

par (mfcol=c(1,2))
plot(Petal.Length,Petal.Width)
plot(Petal.Length,pred)
}
\keyword{neural}
\keyword{nonlinear}
\keyword{classif}
