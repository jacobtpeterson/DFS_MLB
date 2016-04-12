DKDailyValues <- function (){
  
  library (dplyr)
  library (stringr)
  
  site <- "DraftKings"
  
  keyDF <- readRDS("MLBPlayerIDKey.Rds")
  keyDF <- select(keyDF,PLAYER_NAME_CLEAN, PLAYER_ID)
  
  signature=function(x){
    sig=paste(sort(unlist(strsplit(tolower(x)," "))),collapse='')
    return(sig)
  }
  
  today <- as.character(Sys.Date())  
  
  todayCVS <- paste("./DK-Salary-Data/DKSal_", today, ".csv", sep = "" )
  todayDF <- read.csv(todayCVS)
  
  # Rename columns 
  todayDF <- dplyr::rename(todayDF, POS = Position, PLAYER_NAME = Name, TODAY_SALARY = Salary, TEAM = teamAbbrev)
  
  # Uppercase Team Names
  todayDF$TEAM <- toupper(todayDF$TEAM)
  
  # Create PLAYER_NAME_CLEAN column
  # dkDataDF <- left_join(gameLogDF, playerDF, by = "PLAYER_ID")
  todayDF$PLAYER_NAME_CLEAN <- str_replace_all(todayDF$PLAYER_NAME, "([.'-])", "")
  todayDF$PLAYER_NAME_CLEAN <- str_replace_all(todayDF$PLAYER_NAME_CLEAN, "([,])", "")
  todayDF$PLAYER_NAME_CLEAN <- tolower(todayDF$PLAYER_NAME_CLEAN)
  todayDF$PLAYER_NAME_CLEAN <- sapply(todayDF$PLAYER_NAME_CLEAN, signature)
  
  # Mathc DF with oldKey by PLAYER_NAME_CLEAN
  tempDataDF <- left_join(todayDF, keyDF, by = "PLAYER_NAME_CLEAN")
  
  # if non matches
  # Call fuzzyMatch(dataDF = dkDataDF)
  if (sum(is.na(tempDataDF$PLAYER_ID)==T)>0){
    source("fuzzyMatch.R")
    keyDF <- fuzzyMatch(dataDF = todayDF ,site)
    keyDF <- select(keyDF,PLAYER_NAME_CLEAN, PLAYER_ID)
  }
  
  todayDF <- left_join(todayDF, keyDF, by = "PLAYER_NAME_CLEAN")
  
  # rds <- "NBATodaysData"
  fileRDS <- paste("./DK Salary Data/DKSal", today, ".Rds", sep = "" )
  # saveOut(rds)
  # fileRDS <- paste(rds, ".Rds", sep = "" )
  saveRDS(todayDF, file = fileRDS)
  
  
  todayDF
  
}
    
