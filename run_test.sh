#!/bin/bash

CC = g++
CFLAGS = -DNOROUND
TARGET = unfpadder
SRC = unfpadder.c

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

test: $(TARGET)
	./$(TARGET)
	sbt "testOnly unsignedfpadder.unsignedfpadder16"

clean:
	rm -f $(TARGET)