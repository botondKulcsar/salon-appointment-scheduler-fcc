#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
    if [[ $1 ]]
        then
        echo -e "\n$1"
        else
        echo -e "Welcome to My Salon, how can I help you?\n"
    fi

    #get services
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
    
    #if no services found
    if [[ -z $SERVICES ]]
        then
        echo "Sorry, we offer no services for the moment."

    else
        #list services
        echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
        do
            echo "$SERVICE_ID) $SERVICE_NAME"
        done

        read SERVICE_ID_SELECTED
        #if input is not a number
        if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
            then
            #send to main menu
            MAIN_MENU "That is not a valid service number. Please choose a valid one from the list below:"

        else
        #check if service is  listed
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        
        #if service name does not exist
        if [[ -z $SERVICE_NAME ]]
            then
            MAIN_MENU "I could not find that service. What would you like today?"

        else
            #get customer info
            echo -e "\nWhat's your phone number?"
            read CUSTOMER_PHONE

            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

            #if customers doesn't exist
            if [[ -z $CUSTOMER_NAME ]]
                then
                #get new customer name
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME

                #insert new customer
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            fi

            #get customer_id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            
            echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
            read SERVICE_TIME

            #if invalid time given
            #if [[]]
                #then
            #fi

            #insert data into appointments
            INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            
            echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
        fi
    fi
}

MAIN_MENU