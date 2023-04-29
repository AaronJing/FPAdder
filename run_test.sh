#!/bin/bash

CC=g++
CFLAGS="-DUNSIGNED"

$CC $CFLAGS unfpadder.c -o unfpadder
rm saved_test
./unfpadder
sbt testOnly