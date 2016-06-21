oldPlayerAverages <- function () {
  
  library(dplyr)
  library(TTR)
  library (rowr)
  library(RcppRoll)
  
  league <- "MLB"
  baseFileName <- "GameLog"
  gameLogs <- list.files("./data/", paste("\\d{4}", baseFileName, sep = ""))
  
  fileNames <- paste("./data/", gameLogs, sep = "")
  
  # fileNames <- fileNames[[1]]
  gameLogDF <- lapply(fileNames, readRDS)
  
  gameLogDF <- bind_rows(gameLogDF)
  
  # Columns Class
  # charactors to factors
  facts <- sapply(gameLogDF,is.character)
  gameLogDF[facts]<-lapply(gameLogDF[facts],factor)
  
  
  numCols <- colnames(gameLogDF[sapply(gameLogDF,is.numeric)]) 
  
  numColsAve <- setNames(numCols, paste0(numCols, "_ave"))
  numColsHomeAway <- setNames(numCols, paste0(numCols, "_ave_vs_home_away"))
  numColsOpponent <- setNames(numCols, paste0(numCols, "_ave_vs_opponent"))
  
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsAve)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, opponent) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsOpponent)
  gameLogDF <- gameLogDF %>% group_by(PLAYER_ID, home_away) %>% arrange(game_day)%>% mutate_each_(funs(roll_meanr(.,6)), numColsHomeAway)
  
  saveRDS(gameLogDF , "./data/MLBOldPlayerAves.Rds")
  
  
}