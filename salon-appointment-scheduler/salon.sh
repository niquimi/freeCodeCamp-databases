#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  
  # Fetch and display services without headers and additional formatting
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Read the services and format the output correctly
  echo "$SERVICES" | while IFS='|' read SERVICE_ID NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # Check if input is a valid service number
  if ! [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ $SERVICE_ID_SELECTED -lt 1 || $SERVICE_ID_SELECTED -gt 5 ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU # Call the function again to allow re-selection
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CLIENT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's/^\(.\)/\L\1/')

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    CLIENT_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SET_APPOINTMENT_RESPONSE=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CLIENT_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
