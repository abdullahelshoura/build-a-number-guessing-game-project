#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(($RANDOM%1000+1))

CHECK_USER (){
	echo -e "\nEnter your username:" 
	read USERNAME

	USER_EXIST=$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")
  
	if [[ -z $USER_EXIST ]]
	then
    INSERT_USER=$($PSQL "INSERT INTO players (username, games_played, best_game) VALUES ('$USERNAME', 0, 0)")			
		echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  else
		echo $USER_EXIST | while IFS="|" read ID USERNAME GAMES_PLAYED BEST_GAME
		do
		  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
		done		
	fi			
}

GAME (){
	echo -e "\nGuess the secret number between 1 and 1000: " 
	read GUSSED_NUMBER
	NOG=1

	while [[ $GUSSED_NUMBER -ne $SECRET_NUMBER ]]
	do
		if [[ ! $GUSSED_NUMBER =~ ^[0-9]+$ ]]
		then 
			echo -e "\nThat is not an integer, guess again: " 
			read GUSSED_NUMBER
		elif [[ $GUSSED_NUMBER > $SECRET_NUMBER ]]
		then
			echo -e "\nIt's lower than that, guess again: " 
			read GUSSED_NUMBER
		elif [[ $GUSSED_NUMBER < $SECRET_NUMBER ]]
		then 
			echo -e "\nIt's higher than that, guess again: " 
			read GUSSED_NUMBER
		fi
		NOG=$(( $NOG + 1 ))
	done
	
	echo -e "\nYou guessed it in $NOG tries. The secret number was $SECRET_NUMBER. Nice job!"

	return $NOG

}

UPDATE () {
	GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
	GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
	INSERT_NEW_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
	
	BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'") 
	if [[ $NOG < $BEST_GAME || $BEST_GAME == 0 ]]
	then
		INSERT_NOG=$($PSQL "UPDATE players SET best_game = $NOG WHERE username='$USERNAME'")
	fi
}
CHECK_USER
GAME
UPDATE
