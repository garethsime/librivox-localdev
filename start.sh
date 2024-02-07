#!/bin/bash

docker run --rm -it -v "$(pwd)"/librivox-catalog:/librivox/www/librivox.org/catalog librivox-local
