#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Vaciar las tablas antes de insertar nuevos datos
echo $($PSQL "TRUNCATE TABLE games, teams")

# Leer el archivo games.csv línea por línea
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Omitir la primera línea (encabezados)
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipos en la tabla teams si no existen
    WINNER_INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING")
    OPPONENT_INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING")

    # Obtener los IDs de los equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insertar el juego en la tabla games
    GAME_INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    
    # Mensaje opcional para depuración
    if [[ $GAME_INSERT_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR - $ROUND: $WINNER ($WINNER_GOALS) vs $OPPONENT ($OPPONENT_GOALS)"
    fi
  fi
done
