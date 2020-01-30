read.fh.special <- function(fname) {
  inp <- readLines(fname, ok=TRUE, warn=FALSE)
  
  ## Get start and end positions of headers and data blocks
  header.begin <- grep("^HEADER:$", inp)
  header.end <- grep("^DATA:(Tree|Single)$", inp)
  n <- length(header.end)
  if(n == 0) {
    stop('file has no data in "Tree" or "Single" formats')
  }
  ## For each data block in one of the supported formats, find the
  ## corresponding header block
  header.taken <- logical(length(header.begin))
  for (i in seq_len(n)) {
    n.preceding <- sum(header.begin < header.end[i] - 1)
    if (n.preceding == 0 || header.taken[n.preceding]) {
      stop("invalid file: HEADER and DATA don't match")
    } else {
      header.taken[n.preceding] <- TRUE
    }
  }
  if (!all(header.taken)) {
    warning("more HEADER blocks than DATA blocks in supported formats")
  }
  ## For each data block in one of the supported formats, find the
  ## following header block (or end of file)
  data.end <- numeric(n)
  for (i in seq_len(n-1)) {
    tmp <- header.begin[header.begin > header.end[i]]
    data.end[i] <- tmp[1]
  }
  tmp <- header.begin[header.begin > header.end[n]]
  if (length(tmp) > 0) {
    data.end[n] <- tmp[1]
  } else {
    data.end[n] <- length(inp) + 1
  }
  ## Forget headers that are not used by the data blocks
  header.begin <- header.begin[header.taken]
  
  ## Get essential metadata from headers
  species = character(n)
  pith = character(n)
  waldkante = character(n)
  Comment = character(n)
  
  keycodes <- character(n)
  start.years <- numeric(n)
  end.years <- numeric(n)
  
  for (i in seq_len(n)) {
    this.header <- inp[(header.begin[i]+1):(header.end[i]-1)]
    ##############
    #extended
    ## get species
    this.species <- sub("Species=", "", fixed=TRUE,
                        x=grep("^Species=", this.header, value=TRUE))
    if (length(this.species) != 1) {
      string2 <- gettext('number of "Species" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      species[i] <- this.species
    }
    
    ## get pith
    this.pith <- sub("Pith=", "", fixed=TRUE,
                     x=grep("^Pith=", this.header, value=TRUE))
    if (length(this.pith) != 1) {
      string2 <- gettext('number of "Pith" lines is not 1',
                         domain="R-dplR")
      pith[i] = NA
      #stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
      #    string2, domain=NA)
    } else {
      pith[i] <- this.pith
    }
    
    ## get waldkante
    this.waldkante <- sub("WaldKante=", "", fixed=TRUE,
                          x=grep("^WaldKante=", this.header, value=TRUE))
    if (length(this.waldkante) != 1) {
      string2 <- gettext('number of "waldkante" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      waldkante[i] <- this.waldkante
    }
    
    ## get comment
    this.Comment <- sub("Comment=", "", fixed=TRUE,
                        x=grep("^Comment=", this.header, value=TRUE))
    if (length(this.Comment) != 1) {
      string2 <- gettext('number of "Comment" lines is not 1',
                         domain="R-dplR")
      Comment[i] = NA
      #stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
      #string2, domain=NA)
    } else {
      Comment[i] <- this.Comment
    }
    
    
    ##############
    #standard
    ## get keycode (= series id)
    this.keycode <- sub("KeyCode=", "", fixed=TRUE,
                        x=grep("^KeyCode=", this.header, value=TRUE))
    if (length(this.keycode) != 1) {
      string2 <- gettext('number of "KeyCode" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", as.character(i), domain="R-dplR"),
           string2, domain=NA)
    } else {
      keycodes[i] <- this.keycode
    }
    ## get start year
    this.start.year <- sub("DateBegin=", "", fixed=TRUE,
                           x=grep("^DateBegin=", this.header, value=TRUE))
    if (length(this.start.year) != 1) {
      string2 <- gettext('number of "DateBegin" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", keycodes[i], domain="R-dplR"),
           string2, domain=NA)
    } else {
      start.years[i] <- as.numeric(this.start.year)
    }
    ## get end year
    this.end.year <- sub("DateEnd=", "", fixed=TRUE,
                         x=grep("^DateEnd=", this.header, value=TRUE))
    if (length(this.end.year) != 1) {
      string2 <- gettext('number of "DateEnd" lines is not 1',
                         domain="R-dplR")
      stop(gettextf("in series %s: ", keycodes[i], domain="R-dplR"),
           string2, domain=NA)
    } else {
      end.years[i] <- as.numeric(this.end.year)
    }
  }
  
  
  ####
  #extend data
  ## get info data to data.frame
  #span <- c(1:6)
  #info.df <- data.frame(NA, nrow = length(keycodes), ncol = length(span))
  #rownames(info.df) <- keycodes
  #colnames(info.df) <- c("species", "pith","waldkante", "Comment", "start.years", "end.years")
  
  info.df = data.frame(species, pith, waldkante, Comment, start.years, end.years)
  rownames(info.df) = keycodes
  info.df
}
