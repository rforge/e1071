Sweave <- function(file, output=NULL,
                   driver=RWeaveLatex(), ...)
{
    if(is.character(driver))
        driver <- get(driver, mode="function")()
    else if(is.function(driver))
        driver <- driver()
    
    drobj <- driver$setup(file, output, ...)
    
    text <- scan(file=file, sep="\n", what="", quiet=TRUE,
                 blank.lines.skip=FALSE)
    
    mode <- "doc"
    chunkname <- ""
    chunknr <- 0
    chunk <- NULL
    
    for(line in text){
        if(any(grep("^@", line))){
            if(mode=="doc"){
                driver$writedoc(drobj, chunk)
                mode <- "doc"
            }
            else{
                driver$runcode(drobj, chunk, chunkname, chunknr)
                mode <- "doc"
            }
            chunk <- NULL
        }
        else if(any(grep("^<<.*>>=", line))){
            if(mode=="doc"){
                driver$writedoc(drobj, chunk)
                mode <- "code"
            }
            else{
                driver$runcode(drobj, chunk, chunkname, chunknr)
                mode <- "code"
            }
            chunk <- NULL
            chunkname <- sub("^<<(.*)>>=.*", "\\1", line)
            chunknr <- chunknr+1
        }
        else
          chunk <- paste(chunk, line, sep="\n")
    }
    if(mode=="doc") driver$writedoc(drobj, chunk)
    else driver$runcode(drobj, chunk, chunkname, chunknr)

    driver$finish(drobj)
}
                
RWeaveLatex <- function()
{
    list(setup = function(file, output, echo=TRUE, stylepath=TRUE,
                          pdf=TRUE, eps=TRUE, width=6, height=6)
     {
         if(is.null(output)){
             prefix <- basename(sub("\\.[rsRS]?nw$", "", file))
             output <- paste(prefix, "tex", sep=".")
         }
         else{
             prefix <- basename(sub("\\.tex$", "", output))
         }
         cat("Writing to file", output, "\n")
         output <- file(output, open="w+")
         
         if(stylepath)
             styfile <- file.path(system.file("Sweave",
                                              package="e1071devel"),
                                  "Sweave")
         else
             styfile <- "Sweave"

         list(prefix=prefix, output=output,
              pdf=pdf, eps=eps, width=width, height=height,
              styfile=styfile, echo=echo)
     },
         
         runcode = function(object, chunk, chunkname, chunknr)
     {		
         submode <- "ignore"
         if(any(grep("^[RS].hide(:.*)?", chunkname))){
             submode <- "hide"
         }
         else if(any(grep("^[RS].fig(:.*)?", chunkname))){
             submode <- "fig"
         }
         else if(any(grep("^[RS](:.*)?$", chunkname))){
             submode <- "show"
         }
         
         if(submode=="ignore"){
             cat("code chunk ", chunknr, " <<",
                 chunkname, ">>: ignore\n", sep="")
             return(0)
         }
         else if(submode == "hide"){
             cat("code chunk ", chunknr, " <<",
                 chunkname, ">>: output to console\n", sep="")
             eval(parse(text=chunk), envir=.GlobalEnv)
         }
         else if(submode == "show"){
             cat("code chunk ", chunknr, " <<",
                 chunkname, ">>: output to file\n", sep="")
             if(object$echo){
                 chunkexps <- parse(text=chunk)
                 for(ce in chunkexps){
                     cat("\\begin{Sinput}\nR> ",
                         paste(deparse(ce), collapse="\n+  "),
                         "\n\\end{Sinput}\n",
                         file=object$output, append=TRUE, sep="")
                     tmpcon <- textConnection("output", "w")
                     sink(file=tmpcon)
                     eval(ce, envir=.GlobalEnv)
                     sink()
                     close(tmpcon)
                     if(length(output)>0)
                         cat("\\begin{Soutput}\n",
                             paste(output,collapse="\n"),
                             "\n\\end{Soutput}\n",
                             file=object$output, append=TRUE, sep="")
                 }
             }
             else{
                 tmpcon <- textConnection("output", "w")
                 sink(file=tmpcon)
                 eval(parse(text=chunk), envir=.GlobalEnv)
                 sink()
                 close(tmpcon)
                 if(length(output)>0)
                     cat("\\begin{Soutput}\n",
                         paste(output,collapse="\n"),
                         "\n\\end{Soutput}\n",
                         file=object$output, append=TRUE, sep="")
             }
         }
         else if(submode=="fig"){
             cat("code chunk ", chunknr, " <<",
                 chunkname, ">>: create ", sep="")
             file <- paste(object$prefix,
                           formatC(chunknr, flag="0", width=3),
                           sep="-fig")
             if(object$pdf){
                 cat("pdf ")
                 pdf(file=paste(file, "pdf", sep="."),
                     width=object$width, height=object$height)
                 eval(parse(text=chunk), envir=.GlobalEnv)
                 dev.off()
             }
             if(object$eps){
                 cat("eps")
                 postscript(file=paste(file, "eps", sep="."),
                            width=object$width, height=object$height,
                            paper="special",
                            horizontal=FALSE)
                 eval(parse(text=chunk), envir=.GlobalEnv)
                 dev.off()
             }
             cat("\n")
             cat("\\includegraphics{", file, "}\n", sep="",
                 file=object$output, append=TRUE)
         }
         return(0)
     },
         
         writedoc = function(object, chunk)
     {
         chunk <- gsub("\\\\begin\\{document\\}",
                       paste("\\\\usepackage{",
                             object$styfile,
                             "}\n\\\\begin{document}", sep=""),
                       chunk)
         while((pos <-  regexpr("\\\\Sexpr{([^}]*)}", chunk)) >0)
         {
             cmd <- substr(chunk, pos+7, pos-2+attr(pos, "match.length"))
             cat("text chunk Sexpr:", cmd, "= ")
             val <- as.character(eval(parse(text=cmd), envir=.GlobalEnv))
             cat(val, "\n")
             chunk <- sub("\\\\Sexpr{[^}]*}", val, chunk)
         }
         
         cat(chunk, "\n", file=object$output, append=TRUE)
         return(0)
     },

         finish = function(object)
     {
         close(object$output)
     })

}
            
            
Stangle <- function(file, output=NULL, driver=RTangle(), ...){
    Sweave(file=file, output=output, driver=driver, ...)
}
            
RTangle <-  function()
{
    list(setup = function(file, output, chunknames=TRUE)
     {
         if(is.null(output)){
             prefix <- basename(sub("\\.[rsRS]?nw$", "", file))
             output <- paste(prefix, "R", sep=".")
         }
         cat("Writing to file", output, "\n")
         output <- file(output, open="w+")
         
         list(output=output, chunknames=chunknames)
     },
         
         runcode = function(object, chunk, chunkname, chunknr)
     {		
         submode <- "ignore"
         if(any(grep("^[RS].hide(:.*)?", chunkname))){
             submode <- "hide"
         }
         else if(any(grep("^[RS].fig(:.*)?", chunkname))){
             submode <- "fig"
         }
         else if(any(grep("^[RS](:.*)?$", chunkname))){
             submode <- "show"
         }

         if(submode!="ignore"){
             if(object$chunknames)
                 cat("### chunk number ", chunknr,
                     ": ", chunkname, "\n",
                     chunk,"\n\n", 
                     "###################################################\n\n",
                     file=object$output, append=TRUE, sep="")
             else
                 cat(chunk,"\n\n", 
                     file=object$output, append=TRUE, sep="")
             return(0)
         }
     },
         
         writedoc = function(object, chunk, chunkname, chunknr)
     {
         return(0)
     },

         finish = function(object)
     {
         close(object$output)
     })
    
}

               
    
