#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

TRUCATE_RESULT=$($PSQL "TRUNCATE games, teams CASCADE")

function insert_team_in_teams_table {
  local TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
  echo $TEAM_ID

  if [[ -z $TEAM_ID ]]
  then
    local INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
      echo $TEAM_ID
    fi
  fi
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID=$(insert_team_in_teams_table "$WINNER")
    OPPONENT_ID=$(insert_team_in_teams_table "$OPPONENT")

    INSERT_GAME_RESULT=$($PSQL "
      INSERT INTO games(
        year, round, winner_id, opponent_id, winner_goals, opponent_goals
      ) VALUES(
        $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
      )
    ")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Was inserted a new game"
    fi
  fi
done