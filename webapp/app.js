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
});

app.get('/', (req, res) => res.sendFile(path.join(__dirname + '/ui' + '/index.html')));

app.get('/audiobooks', (req, res) => {
    connection.query('SELECT * FROM audiobook AS audibook', function (err, rows, fields) {
        if (err) {
            console.log('Error executing query');
            return res.send();
        }

        console.log(rows);
        res.setHeader('Content-Type', 'text/html');
        res.write('<h1>Audiobooks</h1>');
        res.write('<br>');
        res.write('<table style = "width:100%">');

        res.write('<tr>');
        res.write('<th>ISBN</th>');
        res.write('<th>Title</th>');
        res.write('<th>Narrator ID</th>');
        res.write('<th>Running Time</th>');
        res.write('<th>Age Rating</th>');
        res.write('<th>Purchase Price</th>');
        res.write('<th>Publisher Name</th>');
        res.write('<th>Date Published</th>');
        res.write('<th>Audio File</th>');

        for (var i = 0; i < rows.length; i++) {
            res.write('<tr>');
            res.write('<th>' + rows[i].ISBN + '</th>');
            res.write('<th>' + '<a href = "http://localhost:3000/' + rows[i].title + '">' + rows[i].title + '</a>'  + '</th>');
            res.write('<th>' + rows[i].narrator_id + '</th>');
            res.write('<th>' + rows[i].running_time + '</th>');
            res.write('<th>' + rows[i].age_rating + '</th>');
            res.write('<th>' + rows[i].purchase_price + '</th>');
            res.write('<th>' + rows[i].publisher_name + '</th>');
            res.write('<th>' + rows[i].published_date + '</th>');
            res.write('<th>' + rows[i].audiofile + '</th>');
        }
        res.write('</tr>')
        res.send();
        return;
    });
});

app.get('/reviews', (req, res) => res.sendFile(path.join(__dirname + '/ui' + '/reviews.html')));

app.use(function(req, res, next) {
    var url = require('url');
    var queryUrl = url.parse(req.url, true);
    var queryStr = unescape(queryUrl.path);
    queryStr = queryStr.replace("/", "");

    connection.query(`SELECT * FROM audiobook_reviews WHERE (SELECT ISBN FROM audiobook WHERE audiobook.title = ${mysql.escape(queryStr)}) = audiobook_reviews.ISBN`, function(err, rows){
            if (err) {
                console.log(queryStr);
                res.status(404);
                res.sendFile(path.join(__dirname + '/ui' + '/404.html'));
            }

            res.setHeader('Content-Type', 'text/html');

            if (rows.length == 0) {
                res.write('<h1>No reviews for ' + queryStr + '.</h1>');
                res.send();
            } else {
                res.write('<h1>Reviews for ' + queryStr + '</h1>');
                res.write('<br>');
                res.write('<table style = "width:100%">');

                res.write('<tr>');
                res.write('<th>Customer ID</th>');
                res.write('<th>ISBN</th>');
                res.write('<th>Rating</th>');
                res.write('<th>Review Title</th>');
                res.write('<th>Comment</th>');
                res.write('<th>Verified</th>');

                for (var i = 0; i < rows.length; i++) {
                    res.write('<tr>');
                    res.write('<th>' + rows[i].customer_id + '</th>');
                    res.write('<th>' + rows[i].ISBN + '</th>');
                    res.write('<th>' + rows[i].rating + '</th>');
                    res.write('<th>' + rows[i].title + '</th>');
                    res.write('<th>' + rows[i].comment + '</th>');
                    if (rows[i].verified == 1) {
                        res.write('<th>Yes</th>');
                    } else {
                        res.write('<th>No</th>');
                    }
                }
                res.write('</tr>')
                res.send();
            }
        });
});

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
