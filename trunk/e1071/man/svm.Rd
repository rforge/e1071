\name{svm}
\alias{svm}
%- Also NEED an `\alias' for EACH other topic documented here.
\title{Support Vector Machine}
\description{
\code{svm} is used to train a support vector machine. It can be used to carry
out general regression and classification.
}
\usage{
svm(x, y, svm.type=NULL, kernel.type="radial", degree=3, gamma=1/dim(x)[2],
coef0=0, cost=1, nu=0.5, cachesize=40, tolerance=0.001, epsilon=0.5)
}
\arguments{
  \item{x}{Some data matrix.}
  \item{y}{A response vector. Must match \code{x} in size. Can be either
  a factor or a numeric vector.}
  \item{svm.type}{\code{svm} can ether be used as a classification
    machine or as a regresson machine. Depending of whether \code{y} is
    a factor or not, the default setting for \code{svm.type} is \code{C-classification} or \code{regression}, respectively, but may be overwritten by setting an explicit value.\cr
    Valid options are:
    \itemize{
      \item \code{C-classification}
      \item \code{nu-classification}
      \item \code{one-clasification}
      \item \code{regression}
    }
  }
  \item{kernel.type}{The kernel used in training and predicting. You
    might consider changing some of the following parameters, depending
    on the kernel type.\cr
    \describe{
      \item{linear:}{\eqn{u'v}{u'*v}}
      \item{polynomial:}{\eqn{(\gamma u'v + coef0)^{degree}}{(gamma*u'*v + coef0)^degree}}
      \item{radial basis:}{\eqn{e^(-\gamma |u-v|^2)}{exp(-gamma*|u-v|^2)}}
      \item{sigmoid:}{\eqn{tanh(\gamma u'v + coef0)}{tanh(gamma*u'*v + coef0)}}
      }
    }
  \item{degree}{parameter needed for kernel of type \code{polynomial} (default: 3)}
  \item{gamma}{parameter needed for all kernels except \code{linear}
    (default: 1/(data dimension))}
  \item{coef0}{parameter needed for kernels of type \code{polynomial}
    and \code{sigmoid} (default: 0)}
  \item{cost}{cost of constraints violation. (default: 1)}
  \item{nu}{parameter needed for \code{nu-classification} and \code{one-classification}}
  \item{cachesize}{cache memory in MB. (default 40)}
  \item{tolerance}{tolerance of termination criterion (default: 0.001)}
  \item{epsilon}{epsilon in the insensitive-loss function (default: 0.5)}
}

\value{
  An object of class \code{svm} containing the whole model, the
  resulting support vectors, their index in the data matrix, and the
  corresponding coefficiants. (Use \code{summary} and \code{print} to
  get some output).
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
  \code{\link{predict.svm}},
  \code{\link{print.svm}},
  \code{\link{summary.svm}}
}
\examples{
\dontrun{svm (x,y)}
\dontrun{svm (x,y,svm.type="regression")}
}
\keyword{SVM}
\keyword{neural networks}
\keyword{support vector machines}
\keyword{classification}
\keyword{regression}
\keyword{training}






