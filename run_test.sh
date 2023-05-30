#!/bin/bash

CC=g++
CFLAGS="-DMUL"

$CC $CFLAGS unfpadder.c -o unfpadder
# rm saved_test
# ./unfpadder
sbt "testOnly unsignedfpadder.unsignedfpmul"