#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Get user info from database
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
  # New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Returning user
  IFS="|" read DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo -e "\nWelcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Prompt user
echo -e "\nGuess the secret number between 1 and 1000:"

# Guessing loop
while true; do
  read GUESS

  # Validate guess
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "\nThat is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))
echo $SECRET_NUMBER
  if (( GUESS < SECRET_NUMBER )); then
    echo -e "\nIt's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update stats
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    UPDATE_STATE=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

    # Update best_game if it's better or not set
    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      UPDATE_NUMBERS=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
    fi

    break
  fi
done
