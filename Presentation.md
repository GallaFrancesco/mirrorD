# mirrorD

## Presentation

mirrorD aims to be a simple, decentralized and automated way of managing mirrors of local directories in a distributed environment.

### Functionalities

* The user is able to create a root directory which is then kept synchronized with a series of mirrors defined in an appropriate config file.
* The user is also able to manage existing directories by adding them to a list of desired paths, which are automatically managed by the program.

### Creation

The creation of a synchronized directory is performed in the simplest way possible: a command creates the directory, adding it to the list of desired paths, and creates a config file inside it which manages the mirrors (**should we manage different protocols of synchronization? (https, ssh, etc)**)

### Configuration

Configuration management follows the UNIX/Linux approach.

* One system-wide config file (under /etc/mirrord/) which can be overridden or modified by:
* User-defined configuration files (under $HOME/.config/mirrord/)
* A config file unique to each root directory (inside the directory)

The configuration files are JSON encoded.

### Protocols and Authentication

User authentication can be enabled or disabled by means of the configuration files. The protocol used to manage root directories is HTTPS.

### Why HTTPS

The choice of the https protocol is mainly driven by its certificate / authentication capabilities, the possibility of having a clear and simple REST interface and the wide number of tools avaiable. Furthermore, the possibility of having a web server simplifies the management of multiple mirrors for the same root directory, and makes it accessible even from restricted networks.

### Structure

The program is divided in two main parts:

* A web server, which runs continuously as a daemon. It can manage multiple root directories as endpoints, and update them when a modification occours on one of the mirrors. 

* A client or user interface, which is provided via command line. It is used to start and stop the server and allows the user to create, add or remove directories from the list of desired paths. It also allows the user to modify the configuration files. 

The client-server architecture here described is present on each machine which acts as a mirror, but no mirror acts as a master of the others. 
