playerAverages <- function () {
  
  library(dplyr)
  library(TTR)
  library (rowr)
  library(RcppRoll)
  
  league <- "MLB"
  baseFileName <- "GameLog"
  saveFileName <- "PlayerAves"
  gameLogDF <- readRDS(paste("./data/", league, baseFileName, ".Rds", sep = ""))
  lastYear <- as.character(as.numeric(format(Sys.Date(), "%Y")) - 1)
  oldGameLog <- readRDS(paste("./data/", league, lastYear, baseFileName, ".Rds", sep = ""))
  
  gameLogDF <- bind_rows(gameLogDF, oldGameLog)
  
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
  
  gameLogDF <- filter(gameLogDF, game_day > max(oldGameLog$game_date))
  
  saveFilePath <- paste("./data/", league, saveFileName, ".Rds", sep = "")
  saveRDS(gameLogDF , saveFilePath)
  
  
}
  