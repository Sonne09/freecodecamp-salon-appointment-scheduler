#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
 if [[ $1 ]]
 then
   echo -e "\n$1"
 fi
# get available services
 SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
 # if not found
 if [[ -z $SERVICES ]]
 then
   echo "Sorry, we do not have the selected service available"
 # if found
 else
   echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
   do
     echo "$SERVICE_ID) $NAME"
   done
 # get selected service
 read SERVICE_ID_SELECTED
 # if the choice is not a number
   if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
   then
   # send to main menu
     MAIN_MENU "Sorry, that is not a valid service number"
   else
     SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
     # if not available
     if [[ -z $SELECTED_SERVICE ]]
     then
     # send to main menu
       MAIN_MENU "I could not find that service. What would you like today?"
     else
     # get customer info
       echo -e "\nWhat's your phone number?"
       read CUSTOMER_PHONE
       CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
       # if customer doesn't exist already
         if [[ -z $CUSTOMER_NAME ]]
         then
         echo -e "\nI don't have a record for that phone number, what's your name?"
         read CUSTOMER_NAME
         INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
         SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
         # get the apointment time
         echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
         read SERVICE_TIME
         # insert into appointments
         CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
         INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
         echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
       # if already exist
       else
       # get the service name and appoint time
       SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
       echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
       read SERVICE_TIME
       # update the appointment table
       CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
       INSERT_APPOINT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
       echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
       fi
     fi
   fi
 fi
}
MAIN_MENU
