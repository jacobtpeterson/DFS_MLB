playerAverages <- function () {
  
  library(dplyr)
  library (rowr)
  gameLogDF <- readRDS("./data/MLBGameLog.Rds")
#   playerAves <- data.frame()
  playerAves <- readRDS("./data/MLBPlayerAves.Rds")
  newGameLogDF <- anti_join(gameLogDF, playerAves[,1:dim(gameLogDF)[2]])
  
  aves <- function (x){
    gameDayDF <- newCGameLogDF[x,]
    # gameDayDF <- gameLogDF[x,]
    
    myDF <- filter(gameLogDF, game_date < gameDayDF$game_date)
    playerDF <- filter(myDF, myDF$PLAYER_ID == gameDayDF$PLAYER_ID)
    
    if(dim(playerDF)[1] ==0) {
      seasonDF <- playerDF
      homeAwayDF <- playerDF
      opponentDF <- playerDF
    } else {
      seasonDF <- playerDF
      homeAwayDF <- filter(playerDF, home_away == gameDayDF$home_away)
      opponentDF <- filter(playerDF, opponent == gameDayDF$opponent)
    }
    
    dataFrames <- list(seasonDF, homeAwayDF, opponentDF)
    splitBys <- list("season", "home_away", "opponent")
    splits <- list(dataFrames, splitBys)
    splitDF <- data.frame()
    splitDF <- 0
    
    for (y in 1:3){
      numDF <- splits[[1]][[y]][sapply(splits[[1]][[y]],is.numeric)]
      aveDF <- summarise_each(numDF, funs(mean))
      colnames(aveDF) <- paste("ave", colnames(aveDF),"vs",splits[[2]][[y]] , sep = "_")
      splitDF <- cbind(splitDF,aveDF)
    }
    splitDF <- select(splitDF, -splitDF)
    splitDF <- cbind(gameDayDF, splitDF)
    splitDF
  }

  playerAvesNew <- lapply(c(1:dim(newGameLogDF)[1]), aves)
  # playerAvesNew <- lapply(c(1:dim(gameLogDF)[1]), aves)
  
  playerAvesNew <- bind_rows(playerAvesNew)
  playerAves <- rbind(playerAves, playerAvesNew)
  saveRDS(playerAves , "./data/MLBPlayerAves02.Rds")
  # playerAves
}
  