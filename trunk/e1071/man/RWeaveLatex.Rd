\name{RWeaveLatex}
\alias{RWeaveLatex}
\title{R/LaTeX Driver for Sweave}
\description{
  A driver for \code{\link{Sweave}} that translates R code chunks in
  LaTeX files.
}
\synopsis{
RWeaveLatex()
RWeaveLatex()$setup(file, output, pdf=TRUE, eps=TRUE, width=6, height=6)
}
\arguments{
  \item{file}{Name of noweb file.}
  \item{output}{Name of output file, default is to remove extension \file{.nw},
  \file{.Rnw} or \file{.Snw} and to add extension \file{.tex}. Any
  directory names in \code{file} are also remogved such that the output
  is created in the current working directory.}
  \item{pdf}{Create PDF graphics (for use by pdflatex)?}
  \item{eps}{Create EPS graphics (for use by normal latex)?}
  \item{width}{Width of graphics.}
  \item{height}{Height of graphics.}
}
\author{Friedrich Leisch}
\seealso{\code{\link{Sweave}}}
\keyword{utilities}
