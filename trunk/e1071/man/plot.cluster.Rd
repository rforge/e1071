\name{plot.cluster}
\title{Plot Clustered Data}
\usage{
plot.cluster(clobj, x, centers=TRUE, initcenters=TRUE)
}
\alias{plot.cluster}
\arguments{
 \item{clobj}{Object returned by a clustering algorithm such as
   \code{\link{kmeans}}}
 \item{x}{Data matrix}
 \item{centers}{Mark cluster centers with \code{"X"} (for 2-dimensional
   data only)}
 \item{initcenters}{Mark initial cluster centers with \code{"+"} (for
   2-dimensional data only)}}
}
\description{
  Plot the data using different colors for each cluster. If \code{x} has
  more than 2 columns, a \code{\link{pairs}} plot is produced.
}
\author{Friedrich Leisch and Andreas Weingessel}
\seealso{\code{\link{kmeans}}, \code{\link{predict.cluster}}}}
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
\keyword{hplot}
\keyword{cluster}





