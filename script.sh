#!/bin/bash

source_database="testing_source"
destination_database="testing_destination"
source_table="User"
destination_table="Users"

mysqldump "$source_database" "$source_table" > datatable.sql
mysql "$destination_database" < datatable.sql
rm datatable.sql

echo "Data transfer completed successfully!"

mysql "$destination_database" -e "INSERT INTO $destination_table SELECT * FROM $source_table"
