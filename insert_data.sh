#! /bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables to clear existing data
$PSQL <<EOF
TRUNCATE TABLE games, teams;
EOF

# Insert unique team names into teams table
awk -F ',' 'NR>1{print $3"\n"$4}' games.csv | sort | uniq | \
while read -r team; do
  $PSQL <<EOF
INSERT INTO teams (name) VALUES ('$team');
EOF
done

# Insert data from games.csv into the games table
tail -n +2 games.csv | \
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  winner_id=$($PSQL -t -c "SELECT team_id FROM teams WHERE name='$winner';")
  opponent_id=$($PSQL -t -c "SELECT team_id FROM teams WHERE name='$opponent';")
  $PSQL <<EOF
INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);
EOF
done
