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

3. Now you are ready to run the project.

-To start the server, run the following script in the root folder:

```
ruby lib/my_memcached.rb
```

You should get an output similar to this:

```
SERVER RUNNING
LISTENING TO REQUESTS...
```

-You can access the server with the custom client provided

```
ruby lib/client.rb
```

You should get an output similar to this:

```
TYPE COMMAND (X to exit)
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






