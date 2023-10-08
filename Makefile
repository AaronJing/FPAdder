CC = g++
CFLAGS = -DUNSIGNED
TARGET = unfpadder
SRC = unfpadder.c

.PHONY: all clean test_gen

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

test_gen: $(TARGET)
	# rm saved_test
	./$(TARGET)

test:
	sbt "testOnly unsignedfpadder.unsignedfpadder16"

clean:
	rm -f $(TARGET)