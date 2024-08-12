#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#echo $($PSQL "TRUNCATE customers,appointments")
ALL_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY name")
SHOW_MENU(){
echo "$ALL_SERVICES" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done
}
SHOW_MENU
echo "Quel service voulez-vous?"
read SERVICE_ID_SELECTED
SERVICE_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")

if [[ -z $SERVICE_AVAIL ]] 
then
echo "No service exist of this number."
SHOW_MENU
else
#check customer data
echo "Veuillez rentrer votre téléphone: "
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]] 
then
  echo "Quel est votre nom?"
  read CUSTOMER_NAME
  NEW_CUSTO_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
fi
CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //g')
echo "$CUSTOMER_NAME_FORMATTED"
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME_FORMATTED'")
CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | sed 's/ //g')
echo "$CUSTOMER_ID_FORMATTED"
echo "A quelle heure souhaitez-vous réserver?"
read SERVICE_TIME

NEW_APPOINTS_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID_FORMATTED,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'" | sed 's/ //g')
echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
fi