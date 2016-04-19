# DFS_MLB
Files used for making predictions for baseball daily fantasy sports.

**DKDailyValues.R**  
This file takes the daily csv provided by Draftkings and cleans it up for use in the team creating algorithm.  For players listed with two possible positions, that entry is copied and listed twice, once for each position. 
Example:  

| POS  | PLAYER_NAME |
| ------------- | ------------- |
| 1B/C  | John Doe  |  

Becomes  

| POS  | PLAYER_NAME |
| ------------- | ------------- |
| C  | John Doe  |  
| 1B  | John Doe  |  


**ESPNProjections.R**  
Scrapes the projection data from the ESPN fantasy baseball site.  A new file is created each day it’s called. 

**playerRoster.R**  
  This is a file that scrapes a list of all the players currently in MLB. 
  Saves new and backup Player Roster.  
	Saves new and backup Player ID Key.  
	Output is any changes between old and new roster.  
  Unfortunately, there is no feature for Designated Hitters. 

**MLBPlayerIDKey.Rds**  
  `PLAYER_ID` The numeric code assined to each player by MLB.  
  `PLAYER_NAME` The name as listed by the data source.  
  `PLAYER_NAME_CLEAN` The name of the player cleaned up and standardized to make matching easier.  
  `SOURCE` Website were the `PLAYER_NAME` was pulled from.
  
**MLBPlayerRoster.Rds**  
	`position`  
	`team_abbrev`  
	`PLAYER_NAME`  
	`name_display_roster`  
	`league`  
	`sport_code`  
	`name_display_last_first`  
	`name_first`  
	`position_id`  
	`team_code`  
	`PLAYER_ID`  
	`name_last`  
	`team_id`  
	`active_sw`  
	`team_full`  
	`PLAYER_NAME_CLEAN`  


**fuzzyMatch.R**  
This script is called when a name isn’t found in the MLBPlayerIDKey.Rds file.  This script needs improvement, but it should work for now.   

  

