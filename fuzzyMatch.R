fuzzyMatch <- function (dataDF, site){
  
  library (dplyr)
  
  oldKeyDF <- readRDS("MLBPlayerIDKey.Rds")
  fullRosterDF <- readRDS("MLBPlayerRoster.Rds")
  fullRosterDF <- select(fullRosterDF, PLAYER_ID, PLAYER_NAME, PLAYER_NAME_CLEAN)
  
  # Find unmatched names in the old key
  unmatchedKeyDF <- anti_join(oldKeyDF, dataDF, by = "PLAYER_NAME_CLEAN")
  
  # Find unmatched names in the data
  unmatchedDataDF <- anti_join(dataDF, oldKeyDF, by = "PLAYER_NAME_CLEAN")
  unmatchedDataDF <- distinct(select(unmatchedDataDF, PLAYER_NAME, PLAYER_NAME_CLEAN))
  
  # Add source variable
  unmatchedDataDF$SOURCE <- site
  
  # USe fuzzy logic to match the two
  PLAYER_ID <- data.frame()
  
  for(i in 1:dim(unmatchedDataDF)[1]){
    for(x in seq(0.1,0.9,length=9)){
      hit <- agrep(unmatchedDataDF[i,1], unmatchedKeyDF[,3], max.distance = x)
      if(length(hit) == 0){
        next()
      }else{
        PLAYER_ID[i,1] <- unmatchedKeyDF[hit[1],1]
        break()
      }
    }
  }
  
  unmatchedDataDF <- cbind(PLAYER_ID, unmatchedDataDF)
  
  colnames(unmatchedDataDF)[1] <- "PLAYER_ID" 
  
  tempKeyDF <- rbind(unmatchedKeyDF, unmatchedDataDF)
  
  wrongID <- NULL
  View(fullRosterDF)
  newKeyDF <- data.frame()
  # Compare names of the two and confirm
  # For each name in the unmatched dataframe
  # Print all the names with the same ID
  # Ask for the name with the wrong ID
  # If there are none, hit enter and it will move to the next player on the list
  # Else, ask for the proper ID for that player, this cab be found on the fullRosterDF
  
#   FOR each subset
  for (i in 1:dim(unmatchedDataDF)[1]){
    #   Display subset
    checkSet <- dplyr::filter(tempKeyDF, PLAYER_ID == unmatchedDataDF[i,1])
    print(checkSet)
    #   Prompt: "Mistake?"
    #   mistake <- input
    confirm <- "N"
    confirm <- readline("Is this correct? [y/n]: ")
    #   WHILE mistake
    newCheckSet <- checkSet
    while (confirm != "y"){
      #   enter the row of the mistake
      wrongID <- NULL
      wrongID <- readline("Enter Row(s) of incorrect mathces :")
      wrongID <- as.numeric(unlist(strsplit(wrongID, ",")))
      #   enter proper value
      correctID <- readline("Enter proper ID(s) :")
      correctID <- as.numeric(unlist(strsplit(correctID, ",")))
      #   display subset
      
      for (j in 1:length(wrongID)){
        # creat new subset
        newCheckSet[wrongID[j],1] <- correctID[j]
        wrongPlayer <- filter(tempKeyDF, PLAYER_ID == unmatchedDataDF[i,1])[wrongID, 2][j]
        correctPlayer <- filter(fullRosterDF, PLAYER_ID == correctID[j])[[2]]
        print (paste("Replce [", wrongPlayer, "] with [", correctPlayer, "]?", sep = ""))
        }
      #   display new subset
      print("-----------And Create This Updated Set-----------")
      print(newCheckSet)
      #   mistake <- False
      #   Prompt: "Mistake?"
      #   mistake <- input
      confirm <- readline("Is this correct? [y/n]: ")
    }
    #   save subset
    newKeyDF <- rbind(newKeyDF, newCheckSet)
    #   move to next subset
  }  
  newKeyDF <- rbind(newKeyDF, oldKeyDF)
  newKeyDF <- distinct(newKeyDF)
  # save out old key with date
  oldKeyFileName <- paste("MLBPlayerIDKey_", Sys.Date(), ".Rds", sep = "")
  saveRDS(oldKeyDF, file = oldKeyFileName)
  saveRDS(newKeyDF, file = "MLBPlayerIDKey.Rds" )
  # save new key as old key file
  newKeyDF  
}  
