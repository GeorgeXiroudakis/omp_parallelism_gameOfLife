#!/bin/bash

#set the Benchmark parameters
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

NUM_OF_GENERATIONS=0
NUM_OF_THREADS=0
INPUTFILE=""
OUTPUTFILE=""
COMMAND=""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

total_time=0
time_100_1=()
time_1000_1=()
time_100_2=()
time_1000_2=()


echo -e "\n${CYAN}statritng serial test${NC}\n"
$SERIAL_MAKE_INSTRACTION

# iterate through the two sample grids
for ((k=1; k<=NUM_OF_SAMPLE_GRIDS; k++)); do
	INPUTFILE="testfiles/glid$k.txt"
#		INPUTFILE="testfiles/my"
	OUTPUTFILE="Serialresults$k.txt"
	echo -e "\n${YELLOW}stating test of grid$k.txt ${NC}\n"
	
	# iterate through the different generation options (100, 1000)
	for ((l=NUM_GENERATION_START; l<=NUM_GENERATION_END; l = l * NUM_GENERATION_MULTIPLIER)); do
		NUM_OF_GENERATIONS=$l
		echo -e "${BLUE}starting test of grid$k.txt with $NUM_OF_GENERATIONS generations ${NC}"
		
		# iterate through the num of runs
		 total_time=0
		for ((i=1; i<=$NUM_OF_RUNS; i++)); do
		    COMMAND="./$SERIAL_EXCECUTABLE $INPUTFILE $NUM_OF_GENERATIONS $OUTPUTFILE"
		    echo -e "${RED}running $COMMAND ${NC}"
		    time_output=$(LC_NUMERIC=en_US.UTF-8 time -p $COMMAND 2>&1)
		    
		    real_time=$(echo "$time_output" | grep real | awk '{print $2}')

		    # Convert the real time to float
		    real_time_float=$(echo $real_time | tr -d '[:alpha:]')

		    total_time=$(echo "$total_time + $real_time_float" | bc -l)

		    echo "RUN $i Real time : $real_time_float seconds"
		done
		
		average_time=$(echo "scale=2; $total_time / $NUM_OF_RUNS" | bc -l)
		echo -e "${GREEN}Average SERIAL time of $INPUTFILE and $NUM_OF_GENERATIONS generations: $average_time seconds ${NC}\n"
	done
done
$SERIAL_CLEAN_INSTRACTION


echo -e "\n${CYAN}statritng paraler test${NC}\n"
$MAKE_INSTRACTION

# iterate throu number of threads
for ((t=THREAD_COUT_STAR; t<=THREAD_COUT_END; t++)); do
	export OMP_NUM_THREADS=$t
	NUM_OF_THREADS=$t
	echo -e "\n\n${MAGENTA}starting test with $t threads ${NC}\n"	
	
	# iterate through the two sample grids
	for ((k=1; k<=NUM_OF_SAMPLE_GRIDS; k++)); do
		INPUTFILE="testfiles/glid$k.txt"
#		INPUTFILE="testfiles/my"
		OUTPUTFILE="result$k.txt"
		echo -e "\n${YELLOW}stating test of grid$k.txt ${NC}\n"
		
		# iterate through the different generation options (100, 1000)
		for ((l=NUM_GENERATION_START; l<=NUM_GENERATION_END; l = l * NUM_GENERATION_MULTIPLIER)); do
			NUM_OF_GENERATIONS=$l
			echo -e "${BLUE}starting test of grid$k.txt with $NUM_OF_GENERATIONS generations ${NC}"
			
			# iterate through the num of runs
			 total_time=0
			for ((i=1; i<=$NUM_OF_RUNS; i++)); do
			    COMMAND="./$EXCECUTABLE $INPUTFILE $NUM_OF_GENERATIONS $OUTPUTFILE"
			    echo -e "${RED}running $COMMAND ${NC}"
			    time_output=$(LC_NUMERIC=en_US.UTF-8 time -p $COMMAND 2>&1)
			    
			    real_time=$(echo "$time_output" | grep real | awk '{print $2}')

			    # Convert the real time to float
			    real_time_float=$(echo $real_time | tr -d '[:alpha:]')

			    total_time=$(echo "$total_time + $real_time_float" | bc -l)

			    echo "RUN $i Real time : $real_time_float seconds"
			done
			
			average_time=$(echo "scale=2; $total_time / $NUM_OF_RUNS" | bc -l)
			echo -e "${GREEN}Average time of $INPUTFILE with $NUM_OF_GENERATIONS generations and $NUM_OF_THREADS threads: $average_time seconds ${NC}\n"

			
			 if [ $l -eq 100 ] && [ $k -eq 1 ]; then
    				time_100_1[$t]="$average_time"
			elif [ $l -eq 1000 ] && [ $k -eq 1 ]; then
    				time_1000_1[$t]="$average_time"
			fi

			if [ $l -eq 100 ] && [ $k -eq 2 ]; then
   				 time_100_2[$t]="$average_time"
			elif [ $l -eq 1000 ] && [ $k -eq 2 ]; then
    				time_1000_2[$t]="$average_time"
			fi
			
		done
	done
done

for ((t=1; t<=$THREAD_COUT_END; t++)); do
    if [ "${time_100_1[$t]}" != "0" ] && [ "${time_100_2[$t]}" != "0" ]; then
    		speedup_100_1=$(echo "scale=2; (${time_100_1[0]}/${time_100_1[$t]}) * 100" | bc -l)
    		speedup_100_2=$(echo "scale=2; (${time_100_2[0]}/${time_100_2[$t]}) * 100" | bc -l)
	else
    		speedup_100_1="Undefined (divisor is zero)"
    		speedup_100_2="Undefined (divisor is zero)"
	fi

	if [ "${time_1000_1[$t]}" != "0" ] && [ "${time_1000_2[$t]}" != "0" ]; then
    		speedup_1000_1=$(echo "scale=2; (${time_1000_1[0]}/${time_1000_1[$t]}) * 100" | bc -l)
    		speedup_1000_2=$(echo "scale=2; (${time_1000_2[0]}/${time_1000_2[$t]}) * 100" | bc -l)
	else
    		speedup_1000_1="Undefined (divisor is zero)"
    		speedup_1000_2="Undefined (divisor is zero)"
	fi

    echo "Average speedup for $((t)) thread(s) in grid1 (100 generations): $speedup_100_1%"
    echo "Average speedup for $((t)) thread(s) in grid1 (1000 generations): $speedup_1000_1%"
    echo "Average speedup for $((t)) thread(s) in grid2 (100 generations): $speedup_100_2%"
    echo "Average speedup for $((t)) thread(s) in grid2 (1000 generations): $speedup_1000_2%"
done

$CLEAN_INSTRACTION




