\name{Sweave}
\alias{Sweave}
\alias{Stangle}
\title{Automatic Generation of Reports Using Noweb}
\description{
  \code{Sweave} provides a flexible framework for mixing text and S code
  for automatic report generation. The basic idea is to replace the S
  code with it's output, such that the final document only contains the
  text and the output of the statistical anlysis. 
}
\usage{
Sweave(file, output=NULL, driver=RWeaveLatex(), ...)
Stangle(file, output=NULL, driver=RTangle(), ...)
}
\arguments{
  \item{file}{Name of noweb file.}
  \item{output}{Name of output file, default depends on driver (e.g., a
    LaTeX driver will typically replace the noweb extension with \file{.tex}.}
  \item{driver}{The actual workhorse, see details below.}
  \item{\dots}{Further arguments passed to the driver's setup function.}
}
\section{Main Idea}{
  Automatic generation of reports by mixing word processing markup (like
  latex) and S code. The S code gets replaced by it's output (text or
  graphs) in the final markup file. This allows to re-generate a report
  if the input data change and documents the code to reproduce the
  analysis in the same file that also produces the report.  ESS/noweb
  form a perfect authoring environment for people already using AUCtex
  for writing their docs and ESS for interacting with an S engine,
  because ess-noweb simply combines both in one single file. There is
  almost no need to learn any new tools.
}
\section{Design}{
  Run an S engine on a noweb file and replace appropriate chunks by
  either a verbatim version of the text output or an included graphics
  file. The output has all code chunks replaced by their respective
  output, e.g., a plain latex file plus eps files of the graphs.  To
  make the complete system modular, we use different drivers for text
  markup/computing engines combinations. Unfortunately we will need
  different drivers for different S engines, because all we need are
  \code{eval} and the graphics devices, and these are one of the few places
  where the various S engines have some differences. The example driver
  \code{\link{RWeaveLatex}} combines \R and LaTeX.
}
\section{Chunks}{
  Sweave uses the chunk names to differentiate the contents of the
  chunks. Chunk names are of the form \code{X.Y:Z} where X marks the S dialect,
  Y an optional submode and Z an optional label.

  Valid values for \code{X} currently are
  \itemize{
    \item{S}{code that every S engine understands}
    \item{R}{R specific code (should be ignored by Splus)}
    \item{S3}{S version 3 specific code (should be ignored by R and
      newer versions of Splus)}
    \item{S4}{S version 4 specific code (should be ignored by R and
      older versions of Splus)}
  }
  
  Valid values for \code{Y} are
  \itemize{
    \item{hide}{ouput goes to terminal (because it will usually be
      unexpected) and not placed in final report}
    \item{fig}{the code creates a graph}
  }
  
  Each driver decides which code chunks it can handle and ignores all
  other code chunks.
}
\section{Using Scalars in Text}{
  There is limited support for using the values of S objects in
  text chunks. Any occurrence of \code{\\Sexpr\{expr\}} is replaced by the
  string resulting from coercing the value of the expression \code{expr}
  to a character vector; only the first element of this vector is
  used. E.g., \code{\\Sexpr\{sqrt(9)\}} will be replaced
  by the string \code{3} (without any quotes).

  The expression is
  evaluated in the same environment as the code chunks, hence one can
  access all objects defined in the code chunks which have appeared
  before the expression and were not ignored. The expression may contain
  any valid S code, only curly brackets are not allowed. This is not
  really a limitation, because more complicated computations can be
  easily done in a hidden code chunk and the result then be used inside
  \code{\\Sexpr\{\}}. 
}
\section{Tangling versus Weaving}{
  \code{Sweave} combines the documentation and code chunks together
  (or their output) into a single document. \code{Stangle} extracts only
  the code from the noweb file creating a valid S source file (that can
  be run using \code{\link{source}}). Code inside \code{\\Sexpr\{\}}
  statements is ignored by \code{Stangle}.

  \code{Stangle} is just a
  frontend to \code{Sweave} using a simple driver by default, which
  discards the documentation and concatenates all code chunks the
  current S engine understands. Code 
}   
\author{Friedrich Leisch}
\seealso{\code{\link{RWeaveLatex}}}
\examples{
testfile <- system.file(file.path("Sweave","test1.Rnw"),
                        package="e1071devel")
## create a LaTeX file
Sweave(testfile)

## create an S source file from the code chunks
Stangle(testfile)
## which can be simply sourced
source("test1.R")
}
\keyword{utilities}

