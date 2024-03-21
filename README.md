# hw2

# Game of life
The "Game of Life" is a cellular automaton devised by John Conway in 1970. 
It's a zero-player game simulating a two-dimensional world where cells evolve based on simple rules. 
Each cell can be alive or dead in a given generation, and its state in the next generation depends on the states of its neighboring cells.

Rules:
- Any live cell with fewer than two live neighbors dies, as if by loneliness.
- Any live cell with more than three live neighbors dies, as if by overcrowding.
- Any live cell with two or three live neighbors survives.
- Any dead cell with exactly three live neighbors becomes a live cell.

## Configuration/Constants
before running the progma set the environment variable OMP_NUM_THREADS with the derised number of thread you want the 
progamm to use depending on the machine (e.x. OMP_NUM_THREADS=4)


## Dependencies
- `stdio.h`: Standard Input and Output library.
- `stdlib.h`: Standard library providing memory allocation functions.
- `omp.h`:  openmp used for making the progam parallel


## Execution
1. In the same directory as the Makefile run make
2. Run the executable with 3 comantline argument the path of the datafile, the number of generation to simulate
and the name of the output file. 
(e.x. ./ask2 <input_file> <num_generations> <output_file>
3. The program will simulate the Game of life and output the grid to the ouput file given by comand line argument 3.



## Implementation
- the progrma read the dimantions form the file
- mallocs enoght space to store the grid as a 2d array
- stores the starting grid in the array
- for each generation for each shell after finding how many alive neighores it gots, according to that 
we decide if it is goint to be alive or dead in the next round and we store that in the nextValue
- an the end of the generation the value field is updated with the newValue

## Performance

to mesure the persormance on your system there is included a benchmark (a bash script Benchmark.sh) that can be configured with the veriables:
- EXCECUTABLE=
- MAKE_INSTRACTION=
- CLEAN_INSTRACTION=
- SERIAL_EXCECUTABLE=
- SERIAL_MAKE_INSTRACTION=
- SERIAL_CLEAN_INSTRACTION=
- THREAD_COUT_STAR=
- THREAD_COUT_END=
- NUM_OF_SAMPLE_GRIDS=
- NUM_OF_RUNS=
- NUM_GENERATION_START=
- NUM_GENERATION_END=
- NUM_GENERATION_MULTIPLIER=

the script will firstly run the serial program with all the inputs and the generation sizes NUM_OF_RUNS times 
and calculate the average.

then it runs the parallel program  with all the treads inputs and generations specified NUM_OF_RUNS times

finaly it prrits the speedup of the threads != 1 sompaired to the thread 1 for each compination (thsi is currently a little
broken :(  but the speed ups where caclucalted manualy at the end of the file
 
NOTE: i sugest to cat the benchamrkres file in the termila so the color codes are properly displayed

in the benchmarkres file included are the results of runing it in my machine with the params set to:
EXCECUTABLE="ask2"
MAKE_INSTRACTION="make"
CLEAN_INSTRACTION="make clean"
SERIAL_EXCECUTABLE="ask2_Serial"
SERIAL_MAKE_INSTRACTION="gcc src/ask2.c -o ask2_Serial"
SERIAL_CLEAN_INSTRACTION="rm ask2_Serial"
THREAD_COUT_STAR=1
THREAD_COUT_END=4
NUM_OF_SAMPLE_GRIDS=2
NUM_OF_RUNS=5
NUM_GENERATION_START=100
NUM_GENERATION_END=1000
NUM_GENERATION_MULTIPLIER=10

