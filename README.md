# DFS_MLB
Files used for making predictions for baseball daily fantasy sports.

**DKDailyValues.R**  
This file takes the daily csv provided by Draftkings and cleans it up for use in the team creating algorithm.  For players listed with two possible positions, that entry is copied and listed twice, once for each position.  

Example:  

| POS  | PLAYER_NAME |
| ------------- | ------------- |
| 1B/C  | John Doe  |  

Becomes:   

| POS  | PLAYER_NAME |
| ------------- | ------------- |
| 1B  | John Doe  |  
| C  | John Doe  |  

**ESPNProjections.R**  
Scrapes the projection data from the ESPN fantasy baseball site.  A new file is created each day it’s called. 

**playerRoster.R**  
  This is a file that scrapes a list of all the players currently in MLB.  
  Saves new and backup Player Roster.  
  Saves new and backup Player ID Key.  
  Output is any changes between old and new roster.  
  Unfortunately, there is no feature for Designated Hitters. 

**MLBGameLog.Rds**  
	`hr` Home Runs  
	`game_type`  
	`game_number`  
	`sac` Sacrafice Bunts  
	`game_day`  
	`rbi` Runs Batted In  
	`lob` Left on Base  
	`opponent`  
	`opponent_short`  
	`bb` Bases on Balls  
	`ave` Batting Average  
	`slg` Sluggin Percentage  
	`opp_score` Opponent Teams Score  
	`ops` On-Base Plus Slugging  
	`hbp` Hit by Pitch  
	`d` Doubles  
	`team_abbrev`  
	`so` Strike Outs  
	`game_date`  
	`sport`  
	`sf` Sacrafice Flys  
	`game_pk`  
	`team` Player's Team  
	`league`  
	`h` Hits  
	`cs` Caught Stealing  
	`obp` On Base Percentage  
	`t` Tripples  
	`ao` Fly Outs  
	`r` Runs  
	`go_ao` Ground Out Fly Out Ratio  
	`sb` Stolen Bases  
	`opponent_abbrev`  
	`opponent_league`  
	`PLAYER_ID`  
	`ibb` Intentional Bases on Balls  
	`ab` At Bats  
	`team_result`  
	`opponent_id`  
	`team_id`  
	`home_away`  
	`team_score`  
	`go` Ground Outs  
	
**MLBHistoricPlayerRoster.Rds**  
Data on every player to have played MLB.  
Same file formate as **MLBPlayerRoster.Rds**  

**MLBPlayerBios.Rds** 
Basic biographical data on every player to have played MLB.  
	`PLAYER_ID`  
	`COLLEGE`  
	`DEBUT`  
	`LAST_GAME`  
	`BIRTHDATE`  
	`BIRTH_CITY`  
	`BIRTH_STATE`  
	`DRAFT_YEAR`  
	`DRAFT_TEAM`  
	`DRAFT_ROUND`  
	`DRAFT_ROUND_OVERALL`

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

**dailyBuild.R**  
Morning script used to update all the rds files with new game data.  
Runs **playerRoster.R** to look for changes to the leuges roster.  
Runs **playerBios.R** adding new players bio information to **MLBPlayerBios.Rds**.  
Runs **playerGameLog.R** gathering all the gamelog information for each player.  
Runs **playerAverages.T** calculating the rolling averages for every numeric value in **playerGameLog.R**.  
Prints Sys.time() as a check to see how long the scipt took to run.  

**fuzzyMatch.R**  
This script is called when a name isn’t found in the MLBPlayerIDKey.Rds file. This script needs improvement, but it should work for now.

**oldPlayerAves.R**  

**oldPlayerGameLog.R**

**playerAverages.Rr**

**playerBios.R**  

**playerGameLog.R**  

**playerRoster.R**  


