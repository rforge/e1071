Sweave <- function(file, output=NULL,
                   keepcode=FALSE, driver="RWeaveLatex", ...)
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
    
    if(is.character(driver))
        driver <- get(driver, mode="function")
    
    text <- scan(file=file, sep="\n", what="", quiet=TRUE,
                 blank.lines.skip=FALSE)
    cat("", file=output)
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
                    cat(line, "\n", sep="", file=output, append=TRUE)
                mode <- "code"
                chunk <- sub("^<<(.*)>>=.*", "\\1", line)
                chunknr <- chunknr+1
            }
            else if(any(grep("^@", line))){
                if(keepcode)
                    cat(line, "\n", sep="", file=output, append=TRUE)
            }
            else{
                line <- gsub("\\\\begin\\{document\\}",
                             paste("\\\\usepackage{",
                                   file.path(system.file("Sweave",
                                                         package="fl"),
                                             "Sweave"),
                                   "}\n\\\\begin{document}", sep=""),
                     line)
                cat(line, "\n", sep="", file=output, append=TRUE)
            }
        }
        else if(mode == "code"){
            if(keepcode)
                cat(line, "\n", sep="", file=output, append=TRUE)
                
            if(any(grep("^@", line))){
                driver(cmd, chunk, chunknr, prefix, output, ...)
                cmd <- NULL
                mode <- "doc"
            }
            else
                cmd <- paste(cmd, line, sep="\n")
        }
    }       
}
                
RWeaveLatex <- function(cmd, chunk, chunknr, prefix, output,
                            pdf=TRUE, eps=TRUE, width=6, height=6)
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
            cat("\\begin{Soutput}\n", file=output, append=TRUE)
            sink(file=output, append=TRUE)
        }
        eval(parse(text=cmd), envir=.GlobalEnv)
        if(submode=="show"){
            sink()
            cat("\\end{Soutput}\n", file=output, append=TRUE)
        }
    }
    else if(submode=="fig"){
        cat("code chunk ", chunknr, " <<",
            chunk, ">>: create ", sep="")
        file <- paste(prefix, formatC(chunknr, flag="0", width=3),
                      sep="-fig")
        if(pdf){
            cat("pdf ")
            pdf(file=paste(file, "pdf", sep="."), width=width, height=height)
            eval(parse(text=cmd), envir=.GlobalEnv)
            dev.off()
        }
        if(eps){
            cat("eps")
            postscript(file=paste(file, "eps", sep="."),
                       width=width, height=height, paper="special",
                       horizontal=FALSE)
            eval(parse(text=cmd), envir=.GlobalEnv)
            dev.off()
        }
        cat("\n")
        cat("\\includegraphics{", file, "}\n", sep="",
            file=output, append=TRUE)
    }
    return(0)
}
            
            
            
            

               
    
