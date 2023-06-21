#!/bin/bash

source_database="testing_source"
destination_database="testing_destination"
source_table="User"
destination_table="Users"

mysqldump "$source_database" "$source_table" > datatable.sql
mysql "$destination_database" < datatable.sql
rm datatable.sql

echo "Data transfer completed successfully!"
# mapping
column_mappings=(
  "UserID:user_id"
  "LastName:names"
  "Address:address"
)

column_list=""
select_columns=""
i=0
for mapping in "${column_mappings[@]}"; do
  source_column=$(echo "$mapping" | cut -d':' -f1)
  destination_column=$(echo "$mapping" | cut -d':' -f2)
  column_list+=" $destination_column,"
  select_columns+=" $source_column,"
  ((i++))
done
column_list=${column_list%,}
select_columns=${select_columns%,}
mysql "$source_database" -e "SELECT $select_columns FROM $source_table" | \
while IFS=$'\t' read -r -a row; do
  insert_query="INSERT INTO $destination_table ($column_list) VALUES ("
  for ((i=0; i<${#row[@]}; i++)); do
    insert_query+=" '${row[$i]}',"
  done
  insert_query=${insert_query%,}
  insert_query+=" )"
  mysql "$destination_database" -e "$insert_query"
done

echo "Data transfer completed with manual column mapping!"
