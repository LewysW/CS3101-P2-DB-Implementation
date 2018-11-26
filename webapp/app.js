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

//Connect to database
connection.connect( function(err) {
    if (err) {
        console.log('Error connecting to DB');
        throw err;
    }

    console.log('Connection established');
});

//Sends index page to user
app.get('/', (req, res) => res.sendFile(path.join(__dirname + '/ui' + '/index.html')));

//Sends results of q1 view to user
app.get('/customers', (req, res) =>  {
    connection.query('SELECT * FROM q1', function(err, rows, fields) {
        //If error then return
        if (err) {
            console.log('Error executing query');
            return res.send();
        }
        //Otherwise construct page for view q2 and send to user
        res.setHeader('Content-Type', 'text/html');
        res.write('<h1>Customers</h1>');
        res.write('<br>');
        res.write('<table style = "width:100%">');
        res.write('<tr>');
        res.write('<th>Customer ID</th>');
        res.write('<th>Full Name</th>');
        res.write('<th>Email Address</th>');
        res.write('<th>Number of Books Purchased</th>');
        res.write('<th>Total Amount Spent</th>');
        res.write('</tr>')

        for (var i = 0; i < rows.length; i++) {
            res.write('<tr>');
            res.write('<th>' + rows[i].customer_id + '</th>');
            res.write('<th>' + rows[i].full_name + '</th>');
            res.write('<th>' + rows[i].email_address + '</th>');
            res.write('<th>' + rows[i].books_purchased +'</th>');
            res.write('<th>' + rows[i].total_spent + '</th>');
            res.write('</tr>')
        }
        return res.send();
    });
});

//Sends results of q2 view to user
app.get('/not_purchased', (req, res) =>  {
    connection.query('SELECT * FROM q2', function(err, rows, fields) {
        //If error then return
        if (err) {
            console.log('Error executing query');
            return res.send();
        }
        //Otherwise construct page for view q2 and send to user
        res.setHeader('Content-Type', 'text/html');
        res.write('<h1>Not Yet Purchased</h1>');
        res.write('<br>');
        res.write('<table style = "width:100%">');
        res.write('<tr>');
        res.write('<th>ISBN</th>');
        res.write('<th>Title</th>');
        res.write('</tr>')

        for (var i = 0; i < rows.length; i++) {
            res.write('<tr>');
            res.write('<th>' + rows[i].ISBN + '</th>');
            res.write('<th>' + rows[i].title + '</th>');
            res.write('</tr>')
        }
        return res.send();
    });
});

//Sends results of q3 view to user
app.get('/contributor_purchases', (req, res) =>  {
    connection.query('SELECT * FROM q3', function(err, rows, fields) {
        //If error then return
        if (err) {
            console.log('Error executing query');
            return res.send();
        }
        //Otherwise construct results of view q3 and send to user as html
        res.setHeader('Content-Type', 'text/html');
        res.write('<h1>Contributor Purchases</h1>');
        res.write('<br>');
        res.write('<table style = "width:100%">');
        res.write('<tr>');
        res.write('<th>Customer ID</th>');
        res.write('<th>Full Name</th>');
        res.write('<th>Works contributed to and purchased</th>');

        for (var i = 0; i < rows.length; i++) {
            res.write('<tr>');
            res.write('<th>' + rows[i].customer_id + '</th>');
            res.write('<th>' + rows[i].full_name + '</th>');
            res.write('<th>' + rows[i].bought_and_contributed_to+ '</th>');
            res.write('</tr>')
        }
        return res.send();
    });
});

//Displays all audiobooks in the database to the user
app.get('/audiobooks', (req, res) => {
    connection.query('SELECT * FROM audiobook', function (err, rows, fields) {
        var contributor;
        connection.query('SELECT contributor')

        //If an error occurs return.
        if (err) {
            console.log('Error executing query');
            return res.send();
        }

        //Otherwise construct page with audiobook data and send to user
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
        res.write('</tr>')

        for (var i = 0; i < rows.length; i++) {
            res.write('<tr>');
            res.write('<th>' + rows[i].ISBN + '</th>');
            res.write('<th>' + '<a href = "http://localhost:3000/reviews/' + rows[i].title + '">' + rows[i].title + '</a>'  + '</th>');
            res.write('<th>' + rows[i].narrator_id + '</th>');
            res.write('<th>' + rows[i].running_time + '</th>');
            res.write('<th>' + rows[i].age_rating + '</th>');
            res.write('<th>$' + rows[i].purchase_price + '</th>');
            res.write('<th>' + rows[i].publisher_name + '</th>');
            res.write('<th>' + rows[i].published_date + '</th>');
            res.write('<th>' + rows[i].audiofile + '</th>');
            res.write('</tr>')
        }
        return res.send();
    });
});

/*
Checks if request for a review, if not returns 404 page.
If request is for a review, checks to see if there are any reviews for request audiobook
and returns the reviews if there are, returning message to user if there are not
*/
app.use(function(req, res, next) {
    var url = require('url');
    var queryUrl = url.parse(req.url, true);
    var queryStr = unescape(queryUrl.path);

    //Checks if not a request for a review, if so returns 404 page
    if (queryStr.startsWith('/reviews/') == false) {
        console.log(queryStr);
        res.status(404);
        return res.sendFile(path.join(__dirname + '/ui' + '/404.html'));
    }

    //Removes preceding string from request audiobook
    queryStr = queryStr.replace("/reviews/", "");

    //Queries database for all reviews of requested audiobook
    connection.query(`SELECT * FROM audiobook_reviews WHERE (SELECT ISBN FROM audiobook WHERE audiobook.title = ${mysql.escape(queryStr)}) = audiobook_reviews.ISBN`, function(err, rows){
            //If query is empty or error occurs then return page with message.
            if (rows.length == 0 || err) {
                res.setHeader('Content-Type', 'text/html');
                res.write('<h1>There are currently no reviews for "' + queryStr + '"</h1>');
                return res.send();
            }

            //Otherwise build HTML page with review content for audio book
            res.setHeader('Content-Type', 'text/html');
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
            res.write('</tr>')

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
                res.write('</tr>')
            }
            return res.send();
        });
});

app.listen(port, () => console.log(`Listening on port ${port}!`))
