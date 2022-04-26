#!/usr/bin/env bash

# start and daemonize a Rails server process
bundle exec rails server --daemon

# generate load
./tester
