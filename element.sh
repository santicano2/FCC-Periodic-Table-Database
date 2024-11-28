#!/bin/bash

# Check if an argument is provided
if [[ $# -eq 0 ]]; then
    echo "Please provide an element as an argument."
    exit 0
fi

# PostgreSQL connection variable
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if the input is a number
if [[ "$1" =~ ^[0-9]+$ ]]; then
    # If input is a number, query by atomic number
    ELEMENT_QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                   FROM elements e 
                   JOIN properties p ON e.atomic_number = p.atomic_number 
                   JOIN types t ON p.type_id = t.type_id 
                   WHERE e.atomic_number = $1;"
else
    # If input is not a number, query by symbol or name
    ELEMENT_QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                   FROM elements e 
                   JOIN properties p ON e.atomic_number = p.atomic_number 
                   JOIN types t ON p.type_id = t.type_id 
                   WHERE e.symbol = '$1' OR e.name = '$1';"
fi

# Execute query
RESULT=$($PSQL "$ELEMENT_QUERY")

# Check if element exists
if [[ -z $RESULT ]]; then
    echo "I could not find that element in the database."
    exit 0
fi

# Parse result
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT <<< "$RESULT"

# Output formatted result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."