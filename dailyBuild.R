dailyBuild <- function (){
  
  startTime <- Sys.time()
  
  source('playerRoster.R')
  playerRoster()
  
  source('playerBios.R')
  playerBios()

  source('playerGameLog.R')
  playerGameLog()
  
  source("playerAverages.R")
  playerAverages()
  
  endTime <- Sys.time()
  
  endTime - startTime
}
