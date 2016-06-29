dataCleanUp <- function() {
  
  # This script is intended to clean up missing data in the playerAverages() function.   
  # NAs where created when the roll_mean() function didn't have a large enough number of games 
  ## to average over.
  # NAs will be replaced by the cumulative mean. 
  
  library(dplyr)
  library(RcppRoll)
  library(zoo)
  
  # Set variables to select the files to be cleaned. 
  league <- "MLB"
  baseFileName <- "GameLog"
  saveFileName <- "PlayerAves"
  lastYear <- as.character(as.numeric(format(Sys.Date(), "%Y")) - 1)
  
  # Load the nessasary files. 
  gameLogDF <- readRDS(paste("./data/", league, baseFileName, ".Rds", sep = ""))
  oldGameLogDF <- readRDS(paste("./data/", league, lastYear, baseFileName, ".Rds", sep = ""))
  playerAveDF <- readRDS(paste("./data/",league ,saveFileName, ".Rds", sep = ""))
  
  # Game logs from last year are added to the dataset.  
  # This allows averaging over more games in the beginning of the season
  gameLogDF <- bind_rows(gameLogDF, oldGameLogDF)
  facts <- sapply(gameLogDF,is.character)
  gameLogDF[facts]<-lapply(gameLogDF[facts],factor)
  
  # Averaging is done over every numeric column.
  # The averages will be sorted by; full season, home vs away, vs each opponent.
  numCols <- colnames(gameLogDF[sapply(gameLogDF,is.numeric)]) 
  numColsAve <- setNames(numCols, paste0(numCols, "_ave"))
  numColsHomeAway <- setNames(numCols, paste0(numCols, "_ave_vs_home_away"))
  numColsOpponent <- setNames(numCols, paste0(numCols, "_ave_vs_opponent"))
  
  # dplyr script to find each player's cumulative average as sorted by the aforementioned factors
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID) %>% arrange(game_day)%>% mutate_each_(funs(cumsum(.) / seq_along(.)), numColsAve)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, opponent) %>% arrange(game_day)%>% mutate_each_(funs(cumsum(.) / seq_along(.)), numColsOpponent)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, home_away) %>% arrange(game_day)%>% mutate_each_(funs(cumsum(.) / seq_along(.)), numColsHomeAway)
  
  # Filter out last seasons data.
  gameLogDF <- filter(gameLogDF, game_date > max(oldGameLogDF$game_date))
  playerAveDF <- filter(playerAveDF, game_date > max(oldGameLogDF$game_date))
  
  # Replace the NAs with corresponding data from the cumulative average data frame. 
  # First the gameLogDF needed to be coerced to a matrix, 
  ## then all columns are set to numeric (this will set factor columns to numeric too, but NAs 
  ## are only located in the numeric columns so this shouldn't be a problem. 
  playerAveDF[is.na(playerAveDF)] <-as.matrix(sapply(gameLogDF, as.numeric))[is.na(playerAveDF)]
  
  #Save the player averages as a new file. 
  saveRDS(playerAveDF, paste("./data/",league ,saveFileName , "NoNAs.Rds", sep = "" ))

}
