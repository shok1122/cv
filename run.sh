#!/bin/bash

docker run -it -v .:/root --rm shok1122/ruby:3.2.2 ruby run.rb index > index.html
docker run -it -v .:/root --rm shok1122/ruby:3.2.2 ruby run.rb funding > funding.html
