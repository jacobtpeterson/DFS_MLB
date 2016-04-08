# DFS_MLB
Files used for making predictions for baseball daily fantasy sports.

**playerRoster.R**  
  This is a file that scrapes a list of all the players currently in MLB.  
  Unfortunately, there is no feature for Designated Hitters.  
  It also creates the basic Player ID Key.  
  
**MLBPlayerIDKey.Rds**  
  `PLAYER_ID` The numeric code assined to each player by MLB.  
  `PLAYER_NAME` The name as listed by the data source.  
  `PLAYER_NAME_CLEAN` The name of the player cleaned up and standardized to make matching easier.  
  `SOURCE` Website were the `PLAYER_NAME` was pulled from.
