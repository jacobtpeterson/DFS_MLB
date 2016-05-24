dailyBuild <- function (){
  
  
  source('playerRoster.R')
  playerRoster()
  
  source('playerBios.R')
  playerBios()

  source('playerGameLog.R')
  playerGameLog()
  
  source("playerAverages.R")
  playerAverages()
  
}