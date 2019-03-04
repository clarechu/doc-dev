#!/usr/bin/env bash

rm -rf _book 

gitbook build       

echo 

docker build -t git-book .

docker tag git-book clarechu/git-book:1.0

docker push clarechu/git-book:1.0