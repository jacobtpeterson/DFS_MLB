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
  
  # Add PLAYER_ID information to today's data
  todayDF <- left_join(todayDF, keyDF, by = "PLAYER_NAME_CLEAN")
  
  
  # Split players with 2 positions into one row per position. 
  twoPOS <- todayDF[ str_detect(todayDF$POS, "\\/"),]
  firstPOS <- twoPOS
  firstPOS$POS <- str_replace(firstPOS$POS, "\\/.*$", "")
  secondPOS <- twoPOS
  secondPOS$POS <- str_replace(secondPOS$POS, "^.*\\/", "")
  todayDF <- anti_join(todayDF, twoPOS)
  todayDF <- rbind(todayDF, firstPOS, secondPOS)
  
  
  # Save out the updated Draftkings file. 
  fileRDS <- paste("./DK-Salary-Data/DKSal_", today, ".Rds", sep = "" )
  saveRDS(todayDF, file = fileRDS)
  
}
    
