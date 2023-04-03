# NodeHostingApp
This Flask web application allows users to install, manage, and monitor services (called nodes) on a system running systemd. The main features of the app include:

Listing all nodes in a table, with information such as name, node, index, status (loaded, active, uptime), status message, and associated controls.
Installing a new node by specifying the brand, username, email, password, and node number.
Stopping, restarting, and deleting individual nodes.
Stopping and restarting all nodes simultaneously.
The app also includes a search function to filter nodes by username.

To be able to "run" a node and receive rewards, it is required to own a node license. More information can be found here:
[Introducing Connect](https://web.connectunited.com/r/003711/video/v2)

[Connect Explainer Video](https://web.connectunited.com/r/003711/video)

### Sign up for a free account here:
[Create Your Free Connect Account](https://web.connectunited.com/r/003711)

## Application Routes
The Flask app has several routes that handle different actions:

* /: Displays an overview of all nodes and their state.
* /install: Installs a new node based on the information the user provided.
* /delete/<brand>/<user>/<int:nodeindex>: Deletes a node based on the brand, username, and node number.
* /stop/<service_name>: Stops a service based on the service name.
* /restart/<service_name>: Restarts a service based on the service name.
* /disable/<service_name>: Disables a service based on the service name.
* /restartall: Restarts all nodes.
* /stopall: Stops all nodes.

## HTML Template
In addition to the Flask app, there is an HTML file that contains forms for adding and managing nodes, a table displaying all nodes and their state, and a search field for filtering nodes by username. JavaScript functions are included for filtering nodes by username and search value.

## Getting Started
To run the Node Manager Flask app, follow these steps:

## Clone the repository to your local machine.
Install the required dependencies: Flask and dateutil.
Run the Flask app by executing python app.py in your terminal.
Open a web browser and navigate to http://localhost:5000 to access the Node Manager web application.
Contributing
If you'd like to contribute to this project, please create a fork of the repository, make your changes, and submit a pull request.

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.