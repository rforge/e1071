\name{predict.svm}
\alias{predict.svm}
\title{Support Vector Machine}
\description{
  This function predicts a value based upon a model trained by \code{svm}.
}
\usage{
predict.svm(model, x, type=c("raw","class")
}

\arguments{
  \item{model}{object of class \code{svm}, created by \code{svm}.}
  \item{x}{Some vector containing the input data.}
  \item{type}{Option indicating whether the output should be the
    computed value itself (\code{raw}, default) or match the factor of the training data
    if a factor was supplied with \code{svm} (\code{class}).}
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
  David Meyer\cr
  \email{david.meyer@ci.tuwien.ac.at}
}
\seealso{
  \code{svm}, \code{print.svm}, \code{summary.svm}
}

\examples{
\dontrun{model <- svm (x,y)}
\dontrun{predict (model, x)}
\dontrun{predict (model, x, type="class")}
}
\keyword{SVM}
\keyword{neural networks}
\keyword{support vector machines}
\keyword{classification}
\keyword{regression}
