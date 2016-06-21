# DFS_MLB
Files used for making predictions for baseball daily fantasy sports.

**playerRoster.R**  
  This is a file that scrapes a list of all the players currently in MLB.  
  Saves new and backup Player Roster.  
  Saves new and backup Player ID Key.  
  Output is any changes between old and new roster.  
  Unfortunately, there is no feature for Designated Hitters. 

**MLBGameLog.Rds**  
	`hr`  
	`game_type`  
	`game_number`  
	`sac`  
	`game_day`  
	`rbi`  
	`lob`  
	`opponent`  
	`opponent_short`  
	`bb`  
	`ave`  
	`slg`  
	`opp_score`  
	`ops`  
	`hbp`  
	`d`  
	`team_abbrev`  
	`so`  
	`game_date`  
	`sport`  
	`sf`  
	`game_pk`  
	`team`  
	`league`  
	`h`  
	`cs`  
	`obp`  
	`t`  
	`ao`  
	`r`  
	`go_ao`  
	`sb`  
	`opponent_abbrev`  
	`opponent_league`  
	`PLAYER_ID`  
	`ibb`  
	`ab`  
	`team_result`  
	`opponent_id`  
	`team_id`  
	`home_away`  
	`team_score`  
	`go`  
	



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



  
**MLBPlayerIDKey.Rds**  
  `PLAYER_ID` The numeric code assined to each player by MLB.  
  `PLAYER_NAME` The name as listed by the data source.  
  `PLAYER_NAME_CLEAN` The name of the player cleaned up and standardized to make matching easier.  
  `SOURCE` Website were the `PLAYER_NAME` was pulled from.
