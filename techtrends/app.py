import sqlite3

from flask import Flask, jsonify, json, render_template, request, url_for, redirect, flash
import logging
from datetime import datetime
from werkzeug.exceptions import abort

# Function to get a database connection.
# This function connects to database with the name `database.db`
def get_db_connection():
    connection = sqlite3.connect('database.db')
    connection.row_factory = sqlite3.Row

    app.config['CONNECTION_TOTAL'] += 1

    return connection

# Function to get a post using its ID
def get_post(post_id):
    connection = get_db_connection()
    post = connection.execute('SELECT * FROM posts WHERE id = ?',
                        (post_id,)).fetchone()
    connection.close()
    return post

# Function to display log
def log(msg):
    dt = datetime.now()
    app.logger.info(dt.strftime('%m/%d/%Y, %H:%M:%S, {}'.format(msg)))

# Define the Flask application
app = Flask(__name__)
app.config['SECRET_KEY'] = 'your secret key'
app.config['POST_TOTAL'] = 0
app.config['CONNECTION_TOTAL'] = 0

logging.basicConfig(level=logging.DEBUG)

# Define the main route of the web application 
@app.route('/')
def index():
    connection = get_db_connection()
    posts = connection.execute('SELECT * FROM posts').fetchall()
    connection.close()

    app.logger.error("this is an error")
    return render_template('index.html', posts=posts)

# Define how each individual article is rendered 
# If the post ID is not found a 404 page is shown
@app.route('/<int:post_id>')
def post(post_id):
    post = get_post(post_id)
    if post is None:
        log("A non-existing article is accessed and a 404 page is returned.")
        return render_template('404.html'), 404
    else:
        log("Article '{}' retrieved!".format(post['title']))
        return render_template('post.html', post=post)

# Define the About Us page
@app.route('/about')
def about():
    log('The "About Us" page is retrieved')
    return render_template('about.html')

# Define the post creation functionality 
@app.route('/create', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']

        if not title:
            flash('Title is required!')
        else:
            connection = get_db_connection()
            connection.execute('INSERT INTO posts (title, content) VALUES (?, ?)',
                         (title, content))
            connection.commit()
            connection.close()

            log("Article '{}' has been created".format(title))
            return redirect(url_for('index'))

    return render_template('create.html')

# Metrics endpoint 
@app.route('/metrics')
def metrics():
    response = json.dumps({ 
        "db_connection_count": app.config['CONNECTION_TOTAL'] , 
        "post_count": app.config['POST_TOTAL']
        }
    ) 

    return response, 200, {'Content-Type': 'application/json'}

# Healthz endpoint 
@app.route('/healthz')
def healthz():
    response = json.dumps(
        { "result": " OK - healthy", }
    ) 

    return response, 200, {'Content-Type': 'application/json'}

# start the application on port 3111
if __name__ == "__main__":
   app.run(host='0.0.0.0', port='3111')
