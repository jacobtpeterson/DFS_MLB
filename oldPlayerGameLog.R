oldPlayerGameLog <- function (season = "2015"){
  # Use this code to pull client side data file from multiple pages
  
  # Necessary Libraries
  library(RJSONIO)
  library(reshape)
  library(dplyr)
  # We use RJSONIO here becuase it can turn "NULL" into "NA" rather then 
  # skipping it this can cause the data to get stacked wrong when making a matrix
  
  # Global Variables
  league <- "MLB"
  baseFileName <- "GameLog"
  fileName <- paste("./data/",league, season, baseFileName, ".Rds", sep = "")
  print(season)
  print(Sys.time())
  # Load full list of active players
  roster <- readRDS("MLBPlayerRoster.Rds")
  oldRoster <- readRDS("MLBHistoricPlayerRoster.Rds")
  roster <- rbind(roster, oldRoster)
  roster <- dplyr::select(roster, PLAYER_ID)
  # Some players are listed twice if they play multiple positions
  roster <- unique(roster)
  # roster <- head(roster, 10) # Use for debugging
  allPlayers <- function (x){
    # Target URL
    playerURL <- paste("http://m.mlb.com/lookup/json/named.sport_hitting_game_log_composed.bam?",
                       "game_type=%27R%27&league_list_id=%27mlb%27&player_id=",
                       x,"&season=", season, "&sit_code=%271%27&sit_code=%272%27&sit_code=",
                       "%273%27&sit_code=%274%27&sit_code=%275%27&sit_code=%276%27&sit_code=",
                       "%277%27&sit_code=%278%27&sit_code=%279%27&sit_code=%2710%27&sit_code=",
                       "%2711%27&sit_code=%2712%27", sep = "")
    # Go to any single player's page 
    # http://m.mlb.com/player/643603/tyler-white 
    # Click "Ctrl+Shift+I" 
    # Click "Network"
    # Scroll down to "Stats" and click on "GAME LOGS"
    # In the inspection window click on the last "NAME" to find the json URL
    
    # JSON file from URL
    playerJSON <- fromJSON(playerURL, nullValue = "NA")
    # Results 
    if (playerJSON$sport_hitting_game_log_composed$sport_hitting_game_log$queryResults[2]!=0){
      playerList <- unlist(playerJSON$sport_hitting_game_log_composed$sport_hitting_game_log$queryResults$row)
      # Turns the list of lists into one long vector
      # 3rd sublist under the 1st list under playerJSON$resultSets
      if (length(playerJSON$sport_hitting_game_log_composed$sport_hitting_game_log$queryResults$row[[1]])==1){
        # Players with only one game have a differently nested JSON
        columns <- length(playerJSON$sport_hitting_game_log_composed$sport_hitting_game_log$queryResults$row)
      } else {
        columns <- length(playerJSON$sport_hitting_game_log_composed$sport_hitting_game_log$queryResults$row[[1]])
      }
      playerDF <- data.frame(matrix(playerList, ncol=columns, byrow = TRUE))
      # Unlists playerList and turn it into a matrix with 45 columns and stacks everything by row
      # Column Names 
      playerCols <- names(playerList[1:columns])
      colnames(playerDF) <- playerCols
      playerDF
    }
  } 
  # Apply the scraping function to the roster of active players
  playerDF <- lapply(roster$PLAYER_ID, allPlayers)
  # Turn the list into one big dataframe
  playerDF <- playerDF[ ! sapply(playerDF, is.null) ]
  # Messy DF
  playerDF <- bind_rows(playerDF) 
  # Rename Columns
  playerDF <- dplyr::rename(playerDF, PLAYER_ID = player_id)
  
  # Columns Class
  # Characters to factors
  facts <- c(3,8,9,19,24:26,35,36,37,40,41,42,43)
  playerDF[,facts]<-lapply(playerDF[,facts],factor)
  
  # Characters to number
  nums <- c(1,4,6,7,10,12:18,20,23,27:34,38,39,44,45)
  playerDF[nums] <- lapply(playerDF[nums], as.numeric)
  
  # Set proper date formats
  playerDF$game_day <- paste(playerDF$game_day, "2016", sep = " ")
  playerDF$game_day <- as.Date(playerDF$game_day, format = "%b %d")
  playerDF$game_date <- as.Date(playerDF$game_date)
  
  # Set NAs to 0
  playerDF[is.na(playerDF)]<-0
  
  # Tidy DF
  # Save df as Rds
  saveRDS(playerDF, file = fileName)
}
