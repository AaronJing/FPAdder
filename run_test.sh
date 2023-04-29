#!/bin/bash

CC=g++
CFLAGS="-DUNSIGNED"

$CC $CFLAGS unfpadder.c -o unfpadder
./unfpadder
sbt testOnly