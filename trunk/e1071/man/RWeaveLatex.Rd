\name{RWeaveLatex}
\alias{RWeaveLatex}
\title{R/LaTeX Driver for Sweave}
\description{
  A driver for \code{\link{Sweave}} that translates R code chunks in
  LaTeX files.
}
\synopsis{
RWeaveLatex()
RWeaveLatex()$setup(file, output, echo=TRUE, stylepath=TRUE,
                    pdf=TRUE, eps=TRUE, width=6, height=6)
}
\arguments{
  \item{file}{Name of noweb file.}
  \item{output}{Name of output file, default is to remove extension \file{.nw},
  \file{.Rnw} or \file{.Snw} and to add extension \file{.tex}. Any
  directory names in \code{file} are also remogved such that the output
  is created in the current working directory.}
  \item{echo}{By default S commands are echoed to the output file, if
    \code{FALSE}, only their output is included.}
  \item{stylepath}{If \code{TRUE}, a hard path to the file \file{Sweave.sty}
    installed with this package is set, if \code{FALSE}, only
    \code{\\usepackage\{Sweave\}} is written. The hard path makes the
    TeX file less
    portable, but avoids the problem of installing the current
    version of \file{Sweave.sty} to some place in your TeX input path.}
  \item{pdf}{Create PDF graphics (for use by pdflatex)?}
  \item{eps}{Create EPS graphics (for use by normal latex)?}
  \item{width}{Width of graphics.}
  \item{height}{Height of graphics.}
}
\author{Friedrich Leisch}
\seealso{\code{\link{Sweave}}, \code{\link{RTangle}}}
\keyword{utilities}
