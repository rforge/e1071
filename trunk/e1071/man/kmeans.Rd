\name{kmeans}
\title{k-Means Clustering}
\usage{
kmeans(x, centers, iter.max=100, verbose=FALSE, method=0)
}
\alias{kmeans}
\alias{plot.cluster}
\alias{predict.cluster}
\alias{error.cluster}
\arguments{
\item{x}{Data matrix}
\item{centers}{Number of clusters or initial values for cluster centers}
\item{iter.max}{Max. number of iterations}
\item{verbose}{If TRUE, make some output during learning}
\item{method}{If 0, then mean square error, otherwise the mean absolute
  error is used}
}
\description{
  The data given by \code{x} is clustered by the k-Means algorithm.
  This algorithm works by repeatedly moving all cluster centers
  to the mean of their Voronoi sets.

  If \code{centers} is a matrix, its rows are taken as the initial cluster
  centers. If \code{centers} is an integer, \code{centers} rows
  of \code{x} are randomly chosen as initial values.

  The algorithm stops, if no cluster center has changed during the last
  iteration or the maximum number of iterations (given by
  \code{iter.max}) is reached.

  If \code{verbose} is TRUE, for each iteration the number of the
  iteration and the numbers of cluster indices which have
  changed since the last iteration is given.

  If \code{method} is 0, the distance between the cluster cneter and the
  data points is the Euclidian distance (ordinary kmeans
  algorithm). Otherwise the distance between the cluster cneter and the
  data points is the sum of the absolute values of the distances of the
  coordinates.
}
\value{
  \code{kmeans} returns an object of class "cluster".
  \item{centers}{The cluster centers.}
  \item{changes}{The number of changes performed in each iteration
    step.}
  \item{cluster}{Vector containing the indices of the clusters where
    the data is mapped.}
  \item{error}{The error made when mapping the data points onto their
    cluster centers.}
  \item{initcenters}{The inital cluster centers.}
  \item{iter}{The number of iterations performed.}
  \item{method}{The method applied.}
  \item{ncenters}{The number of cluster centers.}
  \item{size}{The number of data points in each cluster.}
}
\author{Friedrich Leisch and Andreas Weingessel}
\seealso{\code{\link{plot.cluster}}, \code{\link{predict.cluster}}} 
\examples{
# a 2-dimensional example
x<-rbind(matrix(rnorm(100,sd=0.3),ncol=2),
         matrix(rnorm(100,mean=1,sd=0.3),ncol=2))
cl<-kmeans(x,2,20,verbose=TRUE)
plot(cl,x)   

# a 3-dimensional example
x<-rbind(matrix(rnorm(150,sd=0.3),ncol=3),
         matrix(rnorm(150,mean=1,sd=0.3),ncol=3),
         matrix(rnorm(150,mean=2,sd=0.3),ncol=3))
cl<-kmeans(x,6,20,verbose=TRUE)
plot(cl,x)

# assign classes to some new data
y<-rbind(matrix(rnorm(33,sd=0.3),ncol=3),
         matrix(rnorm(33,mean=1,sd=0.3),ncol=3),
         matrix(rnorm(3,mean=2,sd=0.3),ncol=3))
ycl<-predict(cl, y)
plot(cl,y)
}
\keyword{cluster}

