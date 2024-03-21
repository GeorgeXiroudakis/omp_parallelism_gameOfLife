#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define ALIVE '*'
#define DEAD  ' '


typedef struct gridChell{
	char value;
	char nextValue;
}gridChell_t;


gridChell_t **grid;
long int gridRows, gridColumns;


void readGrid(FILE *file){
	char chell;

	//get the grid dimantions
	if(fscanf(file, "%ld %ld", &gridRows, &gridColumns) != 2){
		perror("Wrong init state file format first row must be the dimentions of the grid\n");
		exit(EXIT_FAILURE);
	}
	
	grid = malloc(gridRows * sizeof(gridChell_t *));
    if (grid == NULL) {
        perror("Memory allocation failed");
        exit(EXIT_FAILURE);
    }

	
	  
	for(long i = 0; i < gridRows; i++){
		grid[i] = malloc(gridColumns * sizeof(gridChell_t));
		if (grid[i] == NULL) {
			perror("Memory allocation failed");
			exit(EXIT_FAILURE);
		}
	}



	for (long int i = 0; i < gridRows; i++) {
		for (long int j = 0; j < gridColumns; j++) {
			do {
				if (fscanf(file, "%c", &chell) != 1) {
					perror("Error reading grid cell");
					exit(EXIT_FAILURE);
				}
			}while (chell != DEAD && chell != ALIVE);
			grid[i][j].value = chell;
		}
	}
		

	

}


int alive_neighbors(int row, int column){
	int count = 0;
	
	for(int i = row - 1; i <= row + 1; i++){
		for(int j = column - 1; j <= column + 1; j++){
			if(i < 0 || i >= gridRows || j < 0 || j >= gridColumns || (i == row && j == column))continue;
			if(grid[i][j].value == ALIVE)count++;
		}
	}

	return count;
}


void simulate_life(int repetitions){
	int aliveNeighbors;
	
	#pragma omp parallel shared(grid, gridRows, gridColumns) private(aliveNeighbors)
	{
		for(int k = 0; k < repetitions; k++){

//			printf("%d\n", k);
			#pragma omp for collapse(2) private(aliveNeighbors)
			for(int i = 0; i < gridRows; i++){
				for(int j = 0; j < gridColumns; j++){
					aliveNeighbors = alive_neighbors(i,j);

					//if the chell is alive
					if(grid[i][j].value == ALIVE){
						if(aliveNeighbors  < 2 || aliveNeighbors > 3)grid[i][j].nextValue = DEAD;
						else grid[i][j].nextValue = ALIVE;
					}else{
						//the chell is dead
						if(aliveNeighbors ==  3)grid[i][j].nextValue = ALIVE;
						else grid[i][j].nextValue = DEAD;
					}
				}
			}
			
			//after traversing all the grid we update the values before the next round
			//we put a barier to stop syncronize the thread for the next round
			//#pragma omp barrier //i think threre is no need as the for has buid in barier
			
			#pragma omp for collapse(2)
			for(int i = 0; i < gridRows; i++){
				for(int j = 0; j < gridColumns; j++){
					grid[i][j].value = grid[i][j].nextValue;
				}
			}
		}
	}	

}



void printGrid_in_file(char *filename) {
	FILE *file = fopen(filename, "w");
    for (long int i = 0; i < gridRows; i++) {
		fprintf(file, "|");
        for (long int j = 0; j < gridColumns; j++) {
            fprintf(file, "%c|", grid[i][j].value);
        }
        fprintf(file, "\n");
    }

	fclose(file);
}


int main(int argc, char **argv){
	FILE *initStateFile;

	if(argc != 4){
        perror("Wrong call\ncall with 3 command line argument (the filepath of the initialstate, num of generations to simulate, output file)\n");
        exit(EXIT_FAILURE);
    }

	initStateFile = fopen(argv[1],"r");
	if(initStateFile == NULL){
        perror("Coundn't open file of the initial state\n");
        exit(EXIT_FAILURE);
    }
	
	readGrid(initStateFile);

	simulate_life(atoi(argv[2]));
	
	printGrid_in_file(argv[3]);

	fclose(initStateFile);

	return 0;
}
