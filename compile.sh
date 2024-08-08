# Kompilierungsskript für die Bachelorarbeit 2024 von Tom Folgmann.
#

# <----------------- Variablen ----------------->
# 
work_dir="$BA24/main"
main_file="$work_dir/main.tex"
output_dir="$work_dir/Kompilierung/pdflatex"
tmp_header_file="$work_dir/Inhalt/Numerik/CodeWrapper.tex"

code_files=(
	"$work_dir/Inhalt/Numerik/TestOZ/test.jl"
	"$work_dir/Inhalt/Numerik/TestOZ/Schallgeschwindigkeit_Modul.jl"
	"$work_dir/Inhalt/Numerik/TestOZ/Max-Min-Modul.jl"
	"$work_dir/Inhalt/Numerik/TestOZ/runsim.sh"
)

title="StudiesOfERMmodelswithcorrelateddisorder"

now=$(date +"%Y-%m-%d_%H-%M-%S")
logfile_name="$work_dir/Kompilierung/compile_logs/pdfcompile_${now}.log"

logfile_count=$(ls -1q "$work_dir/Kompilierung/compile_logs/"pdfcompile_*.log | wc -l | tr -d ' ')

compile_lock_file=/tmp/compile_lock_file

# >----------------- Terminalausgabe, init ----------------->
echo "\033[1;34mKompilierungsskript für die Bachelorarbeit 2024 von Tom Folgmann.\033[0m\n"
echo "\033[1;34mTitel:\033[0m $title"
echo "\033[1;34mJahr:\033[0m 2024"
echo "\033[1;34mAutor:\033[0m Tom Folgmann\n"
echo "\033[1;34mKompiliervorgang No.:\033[0m $logfile_count" 

echo "***********************************************"

echo "\033[1;34mArbeitsverzeichnis:\033[0m $work_dir"
echo "\033[1;34mAusgabeverzeichnis:\033[0m $output_dir"
echo "\n***********************************************"
echo "\033[1;34mHauptdatei:\033[0m $main_file"
echo "\033[1;34mLogdatei:\033[0m $logfile_name"

# <----------------- Flagvariablen ----------------->
pdfflag=false
openflag=false
bibflag=false
exportflag=false

# <----------------- Flags ----------------->
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-e|--export)
			if [ $pdfflag = true ]; then
				echo "Fehler: -pdf und -e können nicht gleichzeitig verwendet werden."
				exit 1
			fi
			exportflag=true
			shift
			;;
		-pdf)
			if [ $exportflag = true ]; then
				echo "Fehler: -pdf und -e können nicht gleichzeitig verwendet werden."
				exit 1
			fi
			pdfflag=true
			shift
			;;
		-bib)
			bibflag=true
			shift
			;;
		-o|--open)
			openflag=true
			shift
			;;
		*)
			echo "Unknown flag: $1"
			exit 1
			;;
	esac
done

# >-----------------  Funktionen ----------------->
#
function rotating_wait() {
	local pid=$1
	local delay=0.75
	local spinstr='|/-\'
	while [ -f $compile_lock_file ]; do
		local temp=${spinstr#?}
		printf " [%c]  " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
	echo "-> erledigt."
}

function prepare_code_appendix() {
	rm "$tmp_header_file"

	cat "$work_dir/Inhalt/Numerik/CodeWrapperHeader.tex" >> "$tmp_header_file"

	# -> Füge Code zu CodeWrapper.tex hinzu
	for code_file in "${code_files[@]}"; do
    	echo "\\\\begin{mdframed}[backgroundcolor=black!4, topline=false, bottomline=false, rightline=false, leftline=false]" >> "$tmp_header_file"
	    echo "    \\\\begin{lstlisting}[language=Julia,basicstyle=\\small]" >> "$tmp_header_file"
	
	    cat "$code_file" >> "$tmp_header_file"
	
	    echo "    \\end{lstlisting}" >> "$tmp_header_file"
	    echo "\\end{mdframed}" >> "$tmp_header_file"
	done


	echo "\\end{document}" >> "$tmp_header_file"
}

function compile_pdf() {
	(
		cd "$work_dir"

		

		pdflatex -output-directory="$output_dir" -interaction=nonstopmode  main.tex >> "$logfile_name"
	)
}

function compile_bib() {
	bibtex "$output_dir/main" 
}



# <----------------- Kompilierung ----------------->
if [ $pdfflag = true ]; then
	echo "\n***********************************************"
	echo "\033[1;34mKompilierung wird gestartet...\033[0m"

	touch $compile_lock_file

	rotating_wait &

	compile_pdf

	rm $compile_lock_file
	sleep 1 												# Warte auf das Ende von rotating_wait

	echo "\n***********************************************"
	echo "\033[1;34mKompilierung beendet.\033[0m"
	mv "$output_dir/main.pdf" "$work_dir/BA2024-${title}.pdf"
fi

if [ $bibflag = true ]; then
	echo "\n***********************************************"
	echo "\033[1;34mBibliographie wird kompiliert...\033[0m"

	touch $compile_lock_file

	rotating_wait &

	compile_bib

	rm $compile_lock_file
	sleep 1 												# Warte auf das Ende von rotating_wait

	echo "\n***********************************************"
	echo "\033[1;34mBibliographie kompiliert.\033[0m"
fi

if [ $exportflag = true ]; then
	echo "\n***********************************************"
	echo "\033[1;34mExportiere Bachelorarbeit...\033[0m"

	touch $compile_lock_file

	rotating_wait &

	compile_pdf
	compile_bib
	compile_pdf
	compile_pdf

	rm $compile_lock_file
	sleep 1 												# Warte auf das Ende von rotating_wait

	echo "\n***********************************************"
	echo "\033[1;34mExport abgeschlossen.\033[0m"
	mv "$output_dir/main.pdf" "$work_dir/BA2024-${title}.pdf"
fi


if [ $openflag = true ]; then
	echo "\n***********************************************"
	echo "\033[1;34mÖffne PDF...\033[0m"
	open "$work_dir/BA2024-${title}.pdf"
fi