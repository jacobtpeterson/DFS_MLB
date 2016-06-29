playerRoster <- function(season = "2016", active = "Y") {
  # Use this code to pull client side data file from a single page
  
  # Nessasary Libraries
  library(dplyr)
  library(stringr)
  library(RJSONIO)
  # We use RJSONIO here because it can turn "NULL" into "NA" rather then 
  # skipping it, causing the data to get stacked wrong when making a matrix
  
  # Global Variables
  year <- as.numeric(season)
  league <- "MLB"
  
  if (active == "Y"){
    baseFile <- "PlayerRoster"
  } else {
    baseFile <- "HistoricPlayerRoster"
  }
  
  # The MLB website has a position code for each of the 9 positions.
  # Unfortunately, Designated Hitter isn't one of them
  position <- c(1:9)
  
  # Called functions
  # A function used to clean a player's name making matching between data sources easier
  signature=function(x){
    sig=paste(sort(unlist(strsplit(tolower(x)," "))),collapse='')
    return(sig)
  } 
  
  # A function used to load an existing data file, and save it as a back up
  backup = function (league, baseFile){
    fileName <- paste(league, baseFile, ".Rds", sep = "")
    oldDF <- readRDS(fileName)
    backupFileName <- paste(league, baseFile, "_BACKUP.Rds", sep = "")
    saveRDS(oldDF, backupFileName)
    oldDF
  }
  
  # Loading the original Player Roster and saving a backup
  oldRoster <- backup(league, baseFile)
  
  # Pulls the basic roster information for every player by position
  allPositions <- function (x){
    # Target URL
    playerURL <- paste("http://mlb.mlb.com/lookup/json/named.search_player_all_pos",
                       ".bam?sport_code=%27mlb%27&active_sw=%27",active,"%27&position=%27",
                       x,"%27", sep = "")
    # Original Website: http://mlb.mlb.com/mlb/players/?tcid=nav_mlb_players 
    # Select "Pitcher" from "Search by Position" dropdown
    # Click "Ctrl+Shift+I" 
    # Click "Network"
    # Click "Go" next to "Picher" in the browser
    # Position = 1:9
    # JSON file from URL
    playerJSON <- fromJSON(playerURL, nullValue = "NA")
    # Results 
    playerList <- unlist(playerJSON$search_player_all_pos$queryResults$row)
    # Turns the list of lists into one long vector
    # 3rd sublist under the 1st list under playerJSON$resultSets
    columns <- length(playerJSON$search_player_all_pos$queryResults$row[[1]])
    # Messy DF
    playerDF <- data.frame(matrix(playerList, ncol=columns, byrow = TRUE))
    # Unlists playerList and turn it into a matrix with 12 columns and stacks everything by row
    # Column Names 
    playerCols <- names(playerList[1:columns])
    colnames(playerDF) <- playerCols
    print(x)
    # 2rd sublist under the 1st list under playerJSON$resultSets
    playerDF
  } 
  # Apply the scraping function to each of the 9 positions
  playerDF <- lapply(position, allPositions)
  # Turn the list into one big dataframe
  playerDF = Reduce(function(...) merge(..., all=T), playerDF)
  # Rename columns 
  playerDF <- dplyr::rename(playerDF, PLAYER_NAME = name_display_first_last
                            , PLAYER_ID = player_id)
  # Create PLAYER_NAME_CLEAN column for each dataset
  playerDF$PLAYER_NAME_CLEAN <- str_replace_all(playerDF$PLAYER_NAME, "([.'-])", "")
  playerDF$PLAYER_NAME_CLEAN <- str_replace_all(playerDF$PLAYER_NAME_CLEAN, "([,])", "")
  playerDF$PLAYER_NAME_CLEAN <- tolower(playerDF$PLAYER_NAME_CLEAN)
  playerDF$PLAYER_NAME_CLEAN <- sapply(playerDF$PLAYER_NAME_CLEAN, signature)
  
  # Update Key
  # Pull up old key and save a backup
  keyDF <- backup(league, "PlayerIDKey")
  
  # Create new key from full player roster
  newKey <- select(playerDF, PLAYER_ID, PLAYER_NAME, PLAYER_NAME_CLEAN)
  newKey$SOURCE = league
  
  # Merge the two keys
  keyDF <- full_join(keyDF, newKey)
  # Save the new key 
  saveRDS(keyDF, paste(league, "PlayerIDKey", ".Rds", sep = ""))
  # Save out new Roster file
  saveRDS(playerDF, paste(league, baseFile, ".Rds", sep = ""))
  # Find any changes in the leagues roster from the last time this function was run
  rosterUpdates <- anti_join(oldRoster, playerDF)
  updatesFileName <- paste(league, "PlayerRoster_UPDATES.Rds", sep = "")
  oldUpdates <- readRDS(updatesFileName)
  oldUpdates <- rbind(oldUpdates, rosterUpdates)
  saveRDS(oldUpdates, updatesFileName)
  
  rosterUpdates
}
