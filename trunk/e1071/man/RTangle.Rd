\name{RTangle}
\alias{RTangle}
\title{R Driver for Stangle}
\description{
  A driver for \code{\link{Stangle}} that extracts R code chunks.
}
\synopsis{
RTangle()
RTangle()$setup(file, output, chunknames=TRUE)
}
\arguments{
  \item{file}{Name of noweb file.}
  \item{output}{Name of output file, default is to remove extension \file{.nw},
    \file{.Rnw} or \file{.Snw} and to add extension \file{.R}. Any
    directory names in \code{file} are also remogved such that the output
    is created in the current working directory.}
  \item{chunknames}{By default, code chunks are seperated by comment
    lines specifying the names and numbers of the code chunks. If
    \code{FALSE}, only the code chunks without any decorating comments
    are extracted.}
}
\author{Friedrich Leisch}
\seealso{\code{\link{Sweave}}, \code{\link{RWeaveLatex}}}
\keyword{utilities}
