playerBios <- function (){
  
  # library (XML)
  library (rvest)
  library (stringr)
  library(dplyr)
  
  # Load existing player bio
  playerBioDF <- readRDS("MLBPlayerBios.Rds")
  # Load full player roster
  roster <- readRDS("MLBPlayerIDKey.Rds")
  roster <- dplyr::select(roster, PLAYER_ID)
  # Some players are listed twice if they play multiple positions
  roster <- unique(roster)
  roster <- dplyr::filter(roster, PLAYER_ID > 0)
  # Find players with missing bio information
  roster <- anti_join(roster, playerBioDF, by = "PLAYER_ID")
  delta <- length(roster$PLAYER_ID)
  # I just like to know how many new players there are in a day
  print (delta)
  
  myData <- data.frame()
  while (delta > 0){
  
    # I was having connection issues with this script.  
    # Anytime I ran too many players at a time, I would fail to connect and the 
    # # script would fail. 
    # This is now made to run for 100 players at a time and then save.
    # It should only be a problem at the beginning of the year or the first time
    # # the script's run.
    
    rosterHead <- head(roster, 100)
    
    bios <- function (x){
      url <- paste ("http://m.mlb.com/player/",x, sep = "")
      url_content <- read_html(url)
      url_nodes <- html_nodes(url_content, xpath = '//*[(@id = "quick-stats")]//li')
      url_text <- html_text(url_nodes)
      
      url_text <- str_replace_all(url_text, "\\n", " ")
      url_text <- str_replace_all(url_text, " $", "")
      url_text <- str_replace_all(url_text, "^ ", "")
      
      playerDF <- data.frame()
      
      # Record PLAYER_ID
      playerDF[1,1] <- x
      
      # Find Born text
      if (sum(str_detect(url_text, "Born:"))){
      playerDF[1,2] <- url_text[str_detect(url_text, "Born:")]
      playerDF[1,2] <- str_replace(playerDF[1,2], '.*\\: ', "")
        } else {playerDF[1,2] <- NA}
    
      # Find Draft text
      if (sum(str_detect(url_text, "Draft:"))){
      playerDF[1,3] <- url_text[str_detect(url_text, "Draft:")]
      playerDF[1,3] <- str_replace(playerDF[1,3], '.*\\: ', "")
      } else {playerDF[1,3] <- NA}
      
      # Find College text
      if (sum(str_detect(url_text, "College:"))){
      playerDF[1,4] <- url_text[str_detect(url_text, "College:")]
      playerDF[1,4] <- str_replace(playerDF[1,4], '.*\\: ', "")
      } else {playerDF[1,4] <- NA}
      
      # Find Debut text
      if (sum(str_detect(url_text, "Debut:"))){
      playerDF[1,5] <- url_text[str_detect(url_text, "Debut:")]
      playerDF[1,5] <- str_replace(playerDF[1,5], '.*\\: ', "")
      } else {playerDF[1,5] <- NA}
      
      # Find Last Game text
      if (sum(str_detect(url_text, "Last Game:"))){
      playerDF[1,6] <- url_text[str_detect(url_text, "Last Game:")]
      playerDF[1,6] <- str_replace(playerDF[1,6], '.*\\: ', "")
      } else {playerDF[1,6] <- NA}
      
      
      # print(x)
      playerDF
      }
    
    # Apply the function bios() to the list of player Ids. 
    myData <- lapply(rosterHead$PLAYER_ID, bios)
    myData <- myData[ ! sapply(myData, is.null) ]
    
    # Messy DF
    myData <- bind_rows(myData)
    
    # Column names
    playerCols <- c("PLAYER_ID","born", "draft", "COLLEGE", "DEBUT", "LAST_GAME")
    colnames(myData) <- playerCols
    
    # Pull birthdate from Born
    myData$BIRTHDATE <- as.Date(str_extract(myData$born, '\\d+\\/\\d+\\/\\d+'), format = "%m/%d/%Y")
    
    #Pull city of birth from born
    myData$BIRTH_CITY <- str_replace(myData$born, "(^.*in )", "")
    myData$BIRTH_CITY <- str_replace(myData$BIRTH_CITY, "(, .*$)", "")
    
    #Pull state or country of birth from born
    myData$BIRTH_STATE <- str_replace(myData$born, "(^.*\\, )", "")
    
    #Pull draft_year from draft
    myData$DRAFT_YEAR <- str_extract(myData$draft, '\\d{4}')
    myData$DRAFT_YEAR <- as.numeric(myData$DRAFT_YEAR)
    
    #Pull draft_team from draft
    myData$DRAFT_TEAM <- str_replace(myData$draft, "^\\d{4}, ", "")
    myData$DRAFT_TEAM <- str_replace(myData$DRAFT_TEAM, "(, .*$)", "")
    
    #Pull draft_round from draft
    myData$DRAFT_ROUND <- str_extract(myData$draft, "\\d+[snrt][tdh]")
    myData$DRAFT_ROUND <- str_replace(myData$DRAFT_ROUND, "[snrt][tdh]", "")
    myData$DRAFT_ROUND <- as.numeric(myData$DRAFT_ROUND)
    
    #Pull draft_round_overall from draft
    myData$DRAFT_ROUND_OVERALL <- str_extract(myData$draft, "\\(.*\\)")
    myData$DRAFT_ROUND_OVERALL <- str_extract(myData$DRAFT_ROUND_OVERALL, "\\d+")
    myData$DRAFT_ROUND_OVERALL <- as.numeric(myData$DRAFT_ROUND_OVERALL)
    
    # Clean up dates for debut and last game
    myData$DEBUT <- as.Date(myData$DEBUT, format = "%B%d,%Y")
    myData$LAST_GAME <- as.Date(myData$LAST_GAME, format = "%m/%d/%Y")
    
    # Remove now redundant born and draft
    myData <- dplyr::select(myData, -born, -draft)
    
    # Bind old player bio info to new player bio info
    myData <- rbind(playerBioDF, myData)
      
    saveRDS(myData, "MLBPlayerBios.Rds")
    print(length(myData$PLAYER_ID))
    
    playerBioDF <- myData
    
    roster <- anti_join(roster, playerBioDF, by = "PLAYER_ID")
    delta <- length(roster$PLAYER_ID)
    
    myData
    }
  myData
}