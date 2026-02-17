##
## EPITECH PROJECT, 2026
## My_jenkins
## File description:
## app
##

import flask

app = flask.Flask(__name__)
@app.route("/")
def hello():
    return "Hello World!"


@app.route("/greet/<name>")
def greet(name):
    return f"Hello, {name}!"

@app.route("/admin")
def admin():
    return flask.jsonify({"message": "Welcome to the admin panel!"}), 403

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081, debug=True)
