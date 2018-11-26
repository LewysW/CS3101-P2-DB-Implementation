// Used express tutorials on official website
//https://expressjs.com/en/starter/hello-world.html
const express = require('express')
const app = express()
const port = 3000
var path = require('path');

//https://expressjs.com/en/guide/database-integration.html#mysql
var mysql = require('mysql')
var connection = mysql.createConnection({
  host     : 'locw.host.cs.st-andrews.ac.uk',
  user     : 'locw',
  password : 'p2wi5qYWZf!tu7',
  database : 'locw_bookstream'
});

connection.connect( function(err) {
    if (err) {
        console.log('Error connecting to DB');
        throw err;
    }

    console.log('Connection established');
}

);

connection.query('SELECT * FROM audiobook AS audibook', function (err, rows, fields) {
    if (err) {
        console.log('Error executing query');
        throw err;
    }

    console.log(rows);
    for (var i = 0; i < rows.length; i++) {
        console.log(rows[i].title);
    };
});

connection.end(function(err) {

});

app.get('/', (req, res) => res.sendFile(path.join(__dirname + '/ui' + '/index.html')));

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
