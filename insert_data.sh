#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  #Check if it is the first line
  if [[ $YEAR != year ]]
  then

    #Inserting Winner into teams table
    #Check if the team is already there by using SELECT. Then check if what is returned empty
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      #Insert the team into the database. Store the result of query into database
      INSERT_WTEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      #Check if result shows insert. If so, display message.
      if [[ $INSERT_WTEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $WINNER
      fi
      #Then run the select query again and store it in the variable (which will be used for foreign referencing in the games table)
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    #Inserting Opponent into teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OTEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OTEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    #Insert Year into games table
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, opponent_goals, winner_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $OGOALS, $WGOALS)")
    if [[ $INSERT_GAMES_RESULT == 'INSERT 0 1' ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER $OPPONENT $WGOALS $OGOALS
    fi
  fi
done