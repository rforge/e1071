plot.cluster <- function(clobj, x, centers=TRUE, initcenters=TRUE,
                         color=rainbow(clobj$ncenters),...){

  
  x <- as.matrix(x)
  
  cl <- predict(clobj, x)

  
  if(dim(x)[2]>2){
    pairs(x, col=color[cl$cluster], ...)
    }
  else{
    plot(x, col=color[cl$cluster], ...)
    if(centers)
      points(cl$centers, pch="X",col=color)
    if(initcenters)
      points(cl$initcenters, pch="+",col=color)
  }
}


print.cluster <- function (clobj)
  {
    if (clobj$method == 0)
      methodname <- "Mean Square Error"
    else
      methodname <- "Mean Absolute Error"

    if (!is.null(clobj$iter))
      cat("\n                            Clustering on Training Set\n\n\n")
    else
      cat("\n                              Clustering on Test Set\n\n\n")
    
    cat("Number of Clusters: ", clobj$ncenters, "\n")
    cat("Sizes  of Clusters: ", clobj$size, "\n\n")

    if (!is.null(clobj$iter))
      {
        if (clobj$iter < length(clobj$changes))
          cat("Algorithm converged after", clobj$iter, "iterations.\n")
        else
          cat("Algorithm did not converge after", clobj$iter, "iterations.\n")
        cat("Changes:", clobj$changes[1:clobj$iter], "\n\n")
      }
    cat("Method:", methodname, "\n")
#    cat("Error: ", clobj$error, "\n")
  }


predict.cluster <- function(clobj, x){

  xrows<-dim(x)[1]
  xcols<-dim(x)[2]
  ncenters <- clobj$ncenters
  cluster <- integer(xrows)
  clustersize <- integer(ncenters)
  

  if(dim(clobj$centers)[2] != xcols){
    stop("Number of variables in cluster object and x are not the same!")
  }

  
  retval <- .C("assign",
               xrows = as.integer(xrows),
               xcols = as.integer(xcols),
               x = as.double(x),
               ncenters = as.integer(ncenters),
               centers = as.double(clobj$centers),
               cluster = as.integer(cluster),
               clustersize = as.integer(clustersize),
               method = as.integer(clobj$method))

  cluster <- retval$cluster + 1
  
#  if (retval$method == 0)
#    error <- mean(sqrt((apply(((x-clobj$centers[cluster,])^2),1,sum))))
#  else
#    error <- mean(apply((abs(x-clobj$centers[cluster,])),1,sum))
   

  clobj$initcenters <- NULL
  clobj$iter <- NULL
  clobj$changes <- NULL
#  clobj$error <- error
  clobj$cluster <- cluster
  clobj$size <- retval$clustersize

  return(clobj)
}


