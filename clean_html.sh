#!/usr/bin/bash

egrep  -v '[\{\}\>\*]' $1 > $1.html-clean
egrep     '[\{\}\>\*]' $1 > $1.html-dirty