oldPlayerAverages <- function () {
  
  library(dplyr)
  library(TTR)
  library (rowr)
  library(RcppRoll)
  
  league <- "MLB"
  baseFileName <- "GameLog"
  
  # Find all historic game log data save to file and create one large dataframe  
  gameLogs <- list.files("./data/", paste("\\d{4}", baseFileName, sep = ""))
  fileNames <- paste("./data/", gameLogs, sep = "")
  gameLogDF <- lapply(fileNames, readRDS)
  gameLogDF <- bind_rows(gameLogDF)
  
  # Column Classes 
  # Characters to factors
  facts <- sapply(gameLogDF,is.character)
  gameLogDF[facts]<-lapply(gameLogDF[facts],factor)
  
  # The averages will be found over all numeric columns.
  numCols <- colnames(gameLogDF[sapply(gameLogDF,is.numeric)]) 
  numColsAve <- setNames(numCols, paste0(numCols, "_ave"))
  numColsHomeAway <- setNames(numCols, paste0(numCols, "_ave_vs_home_away"))
  numColsOpponent <- setNames(numCols, paste0(numCols, "_ave_vs_opponent"))
  
  # dplyr script to run the rolling mean over all numeric values
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsAve)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, opponent) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsOpponent)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, home_away) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsHomeAway)
  
  # Save final dataframe
  saveRDS(gameLogDF , "./data/MLBOldPlayerAves.Rds")
  
}
