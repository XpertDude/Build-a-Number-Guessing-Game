#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo "Enter your username:"
read USERNAME

# Get user info from the database
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

# Check if user exists
if [[ -z $USER_INFO ]]; then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # Insert user into database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Parse values
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo -e "\nGuess the secret number between 1 and 1000:"
read NUMBER
if [[ $NUMBER > $SECRET_NUMBER ]]; then 
echo -e "\nIt's lower than that, guess again:"
else
echo -e "\nIt's higher than that, guess again:"
fi