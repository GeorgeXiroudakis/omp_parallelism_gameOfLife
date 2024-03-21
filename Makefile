CC = gcc
CCFLAGS = -g -fopenmp

all:ask2

ask2: src/ask2.c
	$(CC) $< -o $@ $(CCFLAGS)

clean:
	@ -rm -f ask2 *.txt 
