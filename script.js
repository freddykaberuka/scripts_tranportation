const mysql = require('mysql');

// Create a connection to the source database
const sourceConnection = mysql.createConnection({
  host: 'source_host',
  user: 'source_user',
  password: 'source_password',
  database: 'source_database',
});

// Create a connection to the destination database
const destinationConnection = mysql.createConnection({
  host: 'destination_host',
  user: 'destination_user',
  password: 'destination_password',
  database: 'destination_database',
});

// Specify the source and destination table names
const sourceTable = 'source_table_name';
const destinationTable = 'destination_table_name';

// Connect to the source database
sourceConnection.connect((sourceError) => {
  if (sourceError) {
    console.error('Error connecting to source database:', sourceError);
    return;
  }

  // Connect to the destination database
  destinationConnection.connect((destinationError) => {
    if (destinationError) {
      console.error('Error connecting to destination database:', destinationError);
      return;
    }

    // Fetch the data from the source table
    sourceConnection.query(`SELECT * FROM ${sourceTable}`, (fetchError, data) => {
      if (fetchError) {
        console.error('Error fetching data from source table:', fetchError);
        closeConnections();
        return;
      }

      // Clear the destination table
      destinationConnection.query(`TRUNCATE TABLE ${destinationTable}`, (truncateError) => {
        if (truncateError) {
          console.error('Error truncating destination table:', truncateError);
          closeConnections();
          return;
        }

        // Insert the data into the destination table
        const insertQueries = data.map((row) => `INSERT INTO ${destinationTable} VALUES (${row.join(', ')})`);
        const insertQuery = insertQueries.join(';');

        destinationConnection.query(insertQuery, (insertError) => {
          if (insertError) {
            console.error('Error inserting data into destination table:', insertError);
          } else {
            console.log('Data transfer completed successfully!');
          }

          closeConnections();
        });
      });
    });
  });
});

// Function to close the database connections
function closeConnections() {
  sourceConnection.end();
  destinationConnection.end();
}
