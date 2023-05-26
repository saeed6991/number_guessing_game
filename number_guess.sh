#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USER
USER_CHECK=$($PSQL "SELECT user_id FROM users WHERE username='$USER';")

if [[ -z $USER_CHECK ]]
then
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) values('$USER', 1, 0);")
  echo "Welcome, $USER! It looks like this is your first time here."
  BEST_GAME_SCORE=0
else
  BEST_GAME_SCORE=$($PSQL "SELECT best_game FROM users WHERE username='$USER';")
  NUMBER_OF_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER';")
  echo "Welcome back, $USER! You have played $NUMBER_OF_GAMES_PLAYED games, and your best game took $BEST_GAME_SCORE guesses."
  NUMBER_OF_GAMES_PLAYED=$(( NUMBER_OF_GAMES_PLAYED + 1 ))
  INSERT_NUMBER_OF_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$NUMBER_OF_GAMES_PLAYED WHERE username='$USER';")
fi

echo "Guess the secret number between 1 and 1000:"
LOOP='TRUE'
IF_INT='FALSE'
NUMBER_OF_GUESSES=0
while (( $LOOP == 'TRUE' ))
do
  while (( $IF_INT == 'FALSE' ))
  do
    read GUESS
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
    if [[ $GUESS =~  ^[0-9]+$ ]]
    then
      IF_INT='TRUE'
      break
    else
      echo "That is not an integer, guess again:"
    fi
  done
  if [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -gt $NUMBER ]] 
  then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME_SCORE ]]
    then
      INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USER';")
    elif [[ $BEST_GAME_SCORE == 0 ]]
    then
      INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USER';")
    fi
    LOOP='FALSE'
    break
  fi
done

