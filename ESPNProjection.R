ESPNPredictions <- function () {

  # Nessasary Libraries
  library (XML)
  library(stringr)
  library (dplyr)
  library (reshape2)
  
  league <- "MLB"
  site <- "ESPN"  
  
  keyRDS <- paste(league, "PlayerIDKey.Rds", sep = "")
  keyDF <- readRDS(keyRDS)
  keyDF <- select(keyDF, PLAYER_NAME_CLEAN, PLAYER_ID)
  
  signature=function(x){
    sig=paste(sort(unlist(strsplit(tolower(x)," "))),collapse='')
    return(sig)
  }
  
  # Target Site http://games.espn.go.com/flb/tools/projections?&slotCategoryGroup=1&startIndex=0
  myDF <- do.call('rbind',lapply(paste0("http://games.espn.go.com/flb/tools/projections?&slotCategoryGroup=1&startIndex="
                  ,seq(0,1640,40)), function(x){ readHTMLTable(x, header = TRUE, 
                  as.data.frame=TRUE, stringsAsFactors=FALSE)$playertable_0}))
  colnames(myDF) <- myDF[1,]
  myDF <- dplyr::filter(myDF, myDF[,1] != "RNK")
  myDF <- dplyr::filter(myDF, myDF[,3] != "--")
  
  
  myDF[,1] <- as.numeric(myDF[,1])
  myDF[,3] <- as.numeric(myDF[,3])
  myDF[,4] <- as.numeric(myDF[,4])
  myDF[,5] <- as.numeric(myDF[,5])
  myDF[,6] <- as.numeric(myDF[,6])
  myDF[,7] <- as.numeric(myDF[,7])
  
  myDF[,8:9] <- colsplit(myDF[,2], ",", c("PLAYER_NAME","OTHER"))
  
  startDF <- myDF[grep("^.+(S)$", myDF$OTHER), ]
  startDF$START = 1
  myDF <- full_join(myDF, startDF)
  
  dtdDF <- myDF[grep("^.+(DL15)$", myDF$OTHER), ]
  dtdDF$DL = 1
  myDF <- full_join(myDF, dtdDF)
  
  dtdDF <- myDF[grep("^.+(DL60)$", myDF$OTHER), ]
  dtdDF$DL = 2
  myDF <- full_join(myDF, dtdDF)
  
  dtdDF <- myDF[grep("^.+(DTD)$", myDF$OTHER), ]
  dtdDF$DTD = 1
  myDF <- full_join(myDF, dtdDF)
  
  myDF[is.na(myDF$START),10] <- 0
  myDF[is.na(myDF$DL),11] <- 0
  myDF[is.na(myDF$DTD),12] <- 0
  
  # Create PLAYER_NAME_CLEAN column
  myDF$PLAYER_NAME_CLEAN <- str_replace_all(myDF$PLAYER_NAME, "([.'-])", "")
  myDF$PLAYER_NAME_CLEAN <- str_replace_all(myDF$PLAYER_NAME_CLEAN, "([*])", "")
  myDF$PLAYER_NAME_CLEAN <- str_replace_all(myDF$PLAYER_NAME_CLEAN, "([,])", "")
  myDF$PLAYER_NAME_CLEAN <- tolower(myDF$PLAYER_NAME_CLEAN)
  myDF$PLAYER_NAME_CLEAN <- sapply(myDF$PLAYER_NAME_CLEAN, signature)
  
  # Mathc DF with oldKey by PLAYER_NAME_CLEAN
  tempDF <- left_join(myDF, keyDF)
  
  # if non matches
  # Call fuzzyMatch(dataDF = myDF)
  if (sum(is.na(tempDF$PLAYER_ID)==T)>0){
    source("fuzzyMatch.R")
    keyDF <- fuzzyMatch(dataDF = myDF, site)
    keyDF <- select(keyDF,PLAYER_NAME_CLEAN, PLAYER_ID)
  }
  
  myDF <- left_join(myDF, keyDF)

  rds <- paste("./data/", league, site, "Projections_",Sys.Date(), ".Rds", sep = "" )
  
  saveRDS(myDF, file = rds)
  
  myDF
  
  }
