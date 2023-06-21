#!/bin/bash

# Source database connection details
SOURCE_HOST="127.0.0.1"
SOURCE_PORT="3306"
SOURCE_USER="freddy"
SOURCE_PASSWORD=""
SOURCE_DATABASE="testing_source"

# Destination database connection details
DESTINATION_HOST="127.0.0.1"
DESTINATION_PORT="3306"
DESTINATION_USER="freddy"
DESTINATION_PASSWORD=""
DESTINATION_DATABASE="testing_destination"

TABLE_NAME="User"

transport_table_data() {
  SOURCE_CONNECTION=$(mysql --host="$SOURCE_HOST" --port="$SOURCE_PORT" --user="$SOURCE_USER" --password="$SOURCE_PASSWORD" --database="$SOURCE_DATABASE" --batch --skip-column-names -e "SELECT * FROM $TABLE_NAME")

  if [ -z "$SOURCE_CONNECTION" ]; then
    echo "Failed to retrieve data from the source database."
    exit 1
  COLUMN_NAMES=$(echo "$SOURCE_CONNECTION" | awk -F'\t' '{print $1}' | tr '\n' ',' | sed 's/,$//')

  INSERT_STATEMENT="INSERT INTO $TABLE_NAME ($COLUMN_NAMES) VALUES"

  VALUES=$(echo "$SOURCE_CONNECTION" | awk -F'\t' '{$1=""; print substr($0, 2)}' | tr '\n' ',' | sed 's/,$//')

  mysql --host="$DESTINATION_HOST" --port="$DESTINATION_PORT" --user="$DESTINATION_USER" --password="$DESTINATION_PASSWORD" --database="$DESTINATION_DATABASE" --execute="$INSERT_STATEMENT ($VALUES)"

  if [ $? -eq 0 ]; then
    echo "Table data for '$TABLE_NAME' has been transported from the source database to the destination database."
  else
    echo "Failed to insert data into the destination database."
  fi
}

transport_table_data
