
STRUCTURE_FACTOR=false
TMP_PATH="."
INTERATIONS=1000
MAX_K=1000
EXPONENTIAL=false
HEAVISIDE=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-check)
            julia -t auto main.jl 
            shift
            ;;
        -t|--threads)
            THREADS="-t $2"
            shift 2
            ;;
        -R|--Range)
            RANGE_min="$2"
            RANGE_max="$3"
            RANGE_step="$4"
            shift 4
            ;;
        -D|--Density)
            DENSITY="$2"
            shift 2
            ;;
        -S|--StructureFactor)
            STRUCTURE_FACTOR=true
            shift
            ;;
        -P|--Path)
            TMP_PATH="$2"
            shift 2
            ;;
        -I|--Interations)
            INTERATIONS="$2"
            shift 2
            ;;
        -mk|--max-k)
            MAX_K="$2"
            shift 2
            ;;
        -exp|--exponential-distribution)
            EXPONENTIAL=true
            shift
            ;;
        -G|--Gaussian)
            HEAVISIDE=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            ;;
    esac
done

if [ -z "$DENSITY" ] && ([ -z "$RANGE_min" ] || [ -z "$RANGE_max" ] || [ -z "$RANGE_step" ]); then
    echo "No density argument provided"
    exit 1
fi




if [ -z "$RANGE_min" ]; then 
    echo "julia $THREADS main.jl $DENSITY $STRUCTURE_FACTOR $TMP_PATH $INTERATIONS $MAX_K $EXPONENTIAL $HEAVISIDE"
    julia $THREADS main.jl $DENSITY $STRUCTURE_FACTOR $TMP_PATH $INTERATIONS $MAX_K $EXPONENTIAL $HEAVISIDE | tee -a $TMP_PATH/log_$DENSITY-${INTERATIONS}_$STRUCTURE_FACTOR-$MAX_K.txt
else
    for density in $(seq $RANGE_min $RANGE_step $RANGE_max); do
        echo "-> julia $THREADS main.jl $density $STRUCTURE_FACTOR $TMP_PATH $INTERATIONS $MAX_K $EXPONENTIAL $HEAVISIDE"
        julia $THREADS main.jl $density $STRUCTURE_FACTOR $TMP_PATH $INTERATIONS $MAX_K $EXPONENTIAL $HEAVISIDE | tee -a $TMP_PATH/log_${INTERATIONS}_$density-$STRUCTURE_FACTOR-$MAX_K.txt

        wait
    done
fi