\name{bclust}
\alias{bclust}
\alias{hclust.bclust}
\alias{plot.bclust}
\alias{centers.bclust}
\alias{clusters.bclust}
\title{Bagged Clustering}
\usage{
bclust(x, centers=2, iter.base=10, minsize=0,
       dist.method="euclidian",
       hclust.method="average", base.method="kmeans",
       base.centers=20, verbose=TRUE,
       final.kmeans=FALSE, docmdscale=FALSE,
       resample=TRUE, weights=NULL, maxcluster=base.centers, ...)
hclust.bclust(bcobj, x, centers, dist.method=bcobj$dist.method,
              hclust.method=bcobj$hclust.method, final.kmeans=FALSE,
              docmdscale = FALSE, maxcluster=bcobj$maxcluster)
plot.bclust(bcobj, maxcluster=bcobj$maxcluster, main)
centers.bclust(bcobj, n)
clusters.bclust(bcobj, n, x=NULL)
}
\arguments{
 \item{x}{Matrix of inputs.}
 \item{centers}{Number of clusters to create.}
 \item{iter.base}{Number of runs of the base cluster algorithm.}
 \item{minsize}{Minimum number of points in a base cluster.}
 \item{dist.method}{Distance method used for the hierarchical
     clustering, see \code{\link{dist}} for available distances.}
 \item{hclust.method}{Linkage method used for the hierarchical
     clustering, see \code{\link{hclust}} for available methods.}
 \item{base.method}{Partitioning cluster method used as base algorithm.}
 \item{base.centers}{Number of centers used in each repetition of the
     base method.}
 \item{verbose}{Output status messages.}
 \item{final.kmeans}{If \code{TRUE}, a final kmeans step is performed
     using the output of the bagged clustering as initialization.}
 \item{\dots}{Optional arguments top be passed to the base method.}
}
\description{
    Cluster the data in \code{x} using the bagged clustering
    algorithm. A partitioning cluster algorithm such as
    \code{\link{kmeans}} is run repeatedly on bootstrap samples from the
    original data. The resulting cluster centers are then combined using
    the hierarchical cluster algorithm \code{\link{hclust}}.
}
\details{
    First, \code{iter.base} bootstrap samples of the original data in
    \code{x} are created by drawing with replacement. The base cluster
    method is run on each of these samples with \code{base.centers}
    centers. The \code{base.method} must be the name of a partitioning
    cluster function returning a list with the same components as the
    return value of \code{\link{kmeans}}.

    This results in a collection of \code{iter.base *
	base.centers} centers, which are subsequently clustered using
    the hierarchical method \code{\link{hclust}}. Base centers with less
    than \code{minsize} points in there respective partitions are removed
    before the hierarchical clustering.

    The resulting dendrogram is then cut to produce \code{centers}
    clusters. Hence, the name of the argument \code{centers} is a little
    bit misleading as the resulting clusters need not be convex, e.g.,
    when single linkage is used. The name was chosen for compatibility 
    with standard partitioning cluster methods such as
    \code{\link{kmeans}}.

    A new hierarchical clustering (e.g., using another
    \code{hclust.method}) re-using previous base runs can be
    performed by running \code{hclust.bclust} on the return value of
    \code{bclust}. 
}
\value{
    \code{bclust} and \code{hclust.bclust} return objects of class
    \code{"bclust"} including the components 
    \item{hclust}{Return value of the hierarchical clustering of the
	collection of base centers (Object of class \code{"hclust"}).}
    \item{cluster}{Vector with indices of the clusters the inputs are
	assigned to.}
    \item{centers}{Matrix of centers of the final clusters. Only useful,
	if the hierarchical clustering method produces convex clusters.}
    \item{allcenters}{Matrix of all \code{iter.base * base.centers}
	centers found in the base runs.}
}
\author{Friedrich Leisch}
\references{
  Friedrich Leisch. Bagged clustering. Working Paper 51, SFB ``Adaptive
  Information Systems and Modeling in Economics and Management
  Science'', August 1999. \url{http://www.ci.tuwien.ac.at/~leisch}}
\seealso{\code{\link{hclust}}, \code{\link{kmeans}},
  \code{\link{boxplot.bclust}}}
\keyword{multivariate}
\keyword{cluster}
\examples{
data(iris)
bc1 <- bclust(iris[,1:4], 3, base.centers=5)
plot(bc1)
}

