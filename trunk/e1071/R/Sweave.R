Sweave <- function(file, output=NULL,
                   keepcode=FALSE, driver=RWeaveLatex(), ...)
{
    if(is.character(driver))
        driver <- get(driver, mode="function")()
    
    drobj <- driver$setup(file, output, keepcode, ...)
    
    text <- scan(file=file, sep="\n", what="", quiet=TRUE,
                 blank.lines.skip=FALSE)
    cat("", file=drobj$output)
    mode <- "doc"
    submode <- "hide"
    chunk <- ""
    chunknr <- 0
    cmd <- NULL
    
    ## sink(paste(prefix, "out", sep="."))
    ## on.exit(sink())
    
    for(line in text){
        if(mode == "doc"){
            if(any(grep("^<<.*>>=", line))){
                if(keepcode)
                    cat(line, "\n", sep="", file=drobj$output, append=TRUE)
                mode <- "code"
                chunk <- sub("^<<(.*)>>=.*", "\\1", line)
                chunknr <- chunknr+1
            }
            else if(any(grep("^@", line))){
                if(keepcode)
                    cat(line, "\n", sep="", file=drobj$output, append=TRUE)
            }
            else{
                line <- driver$extras(drobj, line)
                cat(line, "\n", sep="", file=drobj$output, append=TRUE)
            }
        }
        else if(mode == "code"){
            if(keepcode)
                cat(line, "\n", sep="", file=drobj$output, append=TRUE)
                
            if(any(grep("^@", line))){
                driver$run(drobj, cmd, chunk, chunknr)
                cmd <- NULL
                mode <- "doc"
            }
            else
                cmd <- paste(cmd, line, sep="\n")
        }
    }       
}
                
RWeaveLatex <- function()
{
    list(setup = function(file, output, keepcode,
                          pdf=TRUE, eps=TRUE, width=6, height=6)
     {
         if(is.null(output)){
             prefix <- basename(sub("\\.[rsRS]?nw$", "", file))
             extension <- sub(".*\\.([^\\.]*)$", "\\1", file)
             if(keepcode)
                 output <- paste(prefix, "proc", extension, sep=".")
             else
                 output <- paste(prefix, "tex", sep=".")
         }
         else{
             prefix <- sub("\\.tex$", "", output)
             output <- paste(prefix, ".tex", sep="")
             prefix <- basename(prefix)
         }
         
         list(prefix=prefix, output=output,
              pdf=pdf, eps=eps, width=width, height=height,
              styfile=file.path(system.file("Sweave",
                                package="e1071devel"), "Sweave"))
     },
         
         run = function(object, cmd, chunk, chunknr)
     {
         submode <- "ignore"
         if(any(grep("^[RS].hide(:.*)?", chunk))){
             submode <- "hide"
         }
         else if(any(grep("^[RS].fig(:.*)?", chunk))){
             submode <- "fig"
         }
         else if(any(grep("^[RS](:.*)?$", chunk))){
             submode <- "show"
         }
         
         if(submode=="ignore"){
             cat("code chunk ", chunknr, " <<",
                 chunk, ">>: ignore\n", sep="")
             return(0)
         }
         else if(submode %in% c("show", "hide")){
             cat("code chunk ", chunknr, " <<",
                 chunk, ">>\n", sep="")
             if(submode=="show"){
                 cat("\\begin{Soutput}\n", file=object$output, append=TRUE)
                 sink(file=object$output, append=TRUE)
             }
             eval(parse(text=cmd), envir=.GlobalEnv)
             if(submode=="show"){
                 sink()
                 cat("\\end{Soutput}\n", file=object$output,
                     append=TRUE)
             }
         }
         else if(submode=="fig"){
             cat("code chunk ", chunknr, " <<",
                 chunk, ">>: create ", sep="")
             file <- paste(object$prefix,
                           formatC(chunknr, flag="0", width=3),
                           sep="-fig")
             if(object$pdf){
                 cat("pdf ")
                 pdf(file=paste(file, "pdf", sep="."),
                     width=object$width, height=object$height)
                 eval(parse(text=cmd), envir=.GlobalEnv)
                 dev.off()
             }
             if(object$eps){
                 cat("eps")
                 postscript(file=paste(file, "eps", sep="."),
                            width=object$width, height=object$height,
                            paper="special",
                            horizontal=FALSE)
                 eval(parse(text=cmd), envir=.GlobalEnv)
                 dev.off()
             }
             cat("\n")
             cat("\\includegraphics{", file, "}\n", sep="",
                 file=object$output, append=TRUE)
         }
         return(0)
     },

         extras = function(object, line){
             gsub("\\\\begin\\{document\\}",
                  paste("\\\\usepackage{",
                        object$styfile,
                        "}\n\\\\begin{document}", sep=""), line)
         })
    
}
            
            
            
            

               
    
