
kmeans <- function (x, centers, iter.max=100, verbose=FALSE, method=0)
{
    
  xrows<-dim(x)[1]
  xcols<-dim(x)[2]

  if (is.matrix(centers))   # initial values are given
      ncenters <- dim(centers)[1]
  else
    {                   # take centers random vectors as initial values
      ncenters <- centers
      centers <- x[rank(runif(xrows))[1:ncenters],]
    }

  initcenters <- centers
  dist <- matrix(0,xrows,ncenters)
  pos <- as.factor(1:ncenters)   # necessary for empty clusters
  rownames(centers) <- pos

  iter <- integer(1)
  changes <- integer(iter.max)
  cluster <- integer(xrows)
  clustersize <- integer(ncenters)

  retval <- .C("kmeans",
               xrows = as.integer(xrows),
               xcols = as.integer(xcols),
               x = as.double(x),
               ncenters = as.integer(ncenters),
               centers = as.double(centers),
               cluster = as.integer(cluster),
               iter.max = as.integer(iter.max),
               iter = as.integer(iter),
               changes = as.integer(changes),
               clustersize = as.integer(clustersize),
               verbose = as.integer(verbose),
               method = as.integer(method))


  centers <- matrix(retval$centers,
                    ncol=xcols, dimnames=dimnames(initcenters))
  cluster <- retval$cluster + 1

### removed error computation because very very slow
#  if (method == 0)
#    error <- mean(sqrt((apply(((x-centers[cluster,])^2),1,sum))))
#  else
#    error <- mean(apply((abs(x-centers[cluster,])),1,sum))
  
  retval <- list (centers = centers,
                  initcenters = initcenters,
                  ncenters = ncenters,
                  cluster = cluster,
                  size = retval$clustersize,
                  iter = retval$iter - 1,
                  changes = retval$changes,
#                  error = error,
                  method = method)
                  


  class(retval)<-"cluster"
  return(retval)
}


