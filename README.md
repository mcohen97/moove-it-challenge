# Memcached Implementation

This is an implementation of Memcached cache server, built in Ruby.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

In order to run the project locally, the following dependencies must be installed:
(If using Linux, you can use the shell commands provided)

- Ruby
The runtime for running programs written in Ruby.

```
sudo apt-get install ruby-full
```

- Bundler
A dependency manager for Ruby.

```
gem install bundler
```


### Installing

1. Download or clone the repository.

2. Install the project's dependencies.

In the root directory open the terminal and execute the following command:

```
bundle install
```

3. Edit the .env file in the root folder, and configure the environment variables: Port number, thread pool size and length of purge interval.

```
PORT = ...
THREAD_POOL_SIZE = ...
KEYS_PURGE_INTERVAL = ...
```

4. Now you are ready to run the project.

-To start the server, run the following script in the root folder:

```
ruby lib/server/my_memcached.rb
```

You should get an output similar to this:

```
SERVER RUNNING
LISTENING TO REQUESTS...
```

-You can access the server with the demo client provided

```
ruby lib/client/example_client.rb
```

You should get an output similar to this:

```
TYPE COMMAND (X to exit)
```

-If you prefer using the console, you are welcome to connect to the server via telnet:

```
telnet <Server IP Address> <Server port number>
```

## Commands
Here is a list of the available commands, and samples for the demo client.

#### Storage commands

-set

set <key> <flags> <exptime> <bytes> [noreply]\r\n

```
set key1 4 60 5\r\ndata1\r\n
```

-add

add <key> <flags> <exptime> <bytes> [noreply]\r\n

```
add key2 4 60 5\r\ndata2\r\n
```

-replace

replace <key> <flags> <exptime> <bytes> [noreply]\r\n

```
replace key2 4 60 5\r\ndata3\r\n
```

-append

append <key> <flags> <exptime> <bytes> [noreply]\r\n

```
append key1 4 60 5\r\ndata1\r\n
```

-prepend

prepend <key> <flags> <exptime> <bytes> [noreply]\r\n

```
prepend key2 7 60 5\r\ndata2\r\n
```

-cas

cas <key> <flags> <exptime> <bytes> <cas unique> [noreply]\r\n

```
cas key2 3 60 5 1\r\ndata2\r\n
```


#### Retrieval commands

- <key>* means one or more key strings separated by whitespace.

-get

get <key>*

```
get key1 key2
```

-gets

gets <key>*

```
gets key1 key2
```

## Running the tests

To run the unit tests, run the following command in the root directory.

```
ruby -Itest test/all_tests.rb
```

## Built With

* [Ruby](https://www.ruby-lang.org/en/documentation/) - The programming language used.
* [Bundler](https://bundler.io/) - Dependency Management.


## Authors

* **Marcel Cohen** - *Initial work* - [mcohen97](https://github.com/mcohen97)






