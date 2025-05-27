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
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game ) VALUES('$USERNAME', 0, 0)")
else
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate the secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

# Prompt user
echo -e "\nGuess the secret number between 1 and 1000:"

# Start guessing loop
while true; do
  read NUMBER
echo $SECRET_NUMBER
  # Validate input
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if (( NUMBER < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( NUMBER > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
     echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      
    # Update stats in the database
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    $PSQL "UPDATE users SET games_played=$GAMES_PLAYED + 1 WHERE username='$USERNAME'"
    
     # Update best_game if this is a new record
     if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
       $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'"
     fi
    
    break
  fi
done
