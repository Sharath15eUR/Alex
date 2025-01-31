#!/bin/bash

echo "" > errors.log 

search() {
    local dir="$1"
    local keyword="$2"
    
    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' not found." | tee -a errors.log
        exit 1
    fi
    
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            search "$file" "$keyword"
        elif [[ -f "$file" ]]; then
            if grep -q "$keyword" "$file" 2>/dev/null; then
                echo "Keyword '$keyword' found in: $file"
            fi
        fi
    done
}

show_help() {
    cat << EOF
Options:
  -d <directory>  Directory to search.
  -k <keyword>    Keyword to search.
  -f <file>       File to search directly.
  --help          Display the help menu.
EOF
}

validate_inputs() {
    local keyword="$1"
    local file="$2"
    
    if [[ -n "$file" && ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist." | tee -a errors.log
        exit 1
    fi
    
    if [[ -z "$keyword" || ! "$keyword" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Invalid or empty keyword." | tee -a errors.log
        exit 1
    fi
}

while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -) case "$OPTARG" in
               help) show_help; exit 1 ;;
               *) echo "Invalid option: --$OPTARG" | tee -a errors.log; exit 1 ;;
           esac ;;
        ?) echo "Invalid option: -$OPTARG" | tee -a errors.log; exit 1 ;;
    esac
done

if [[ -z "$keyword" ]]; then
    echo "Error: Keyword is required." | tee -a errors.log
    exit 1
fi

validate_inputs "$keyword" "$file"

if [[ -n "$directory" ]]; then
    search "$directory" "$keyword"
elif [[ -n "$file" ]]; then
    grep --color=always "$keyword" "$file"
else
    echo "Error: Either -d (directory) or -f (file) must be specified." | tee -a errors.log
    exit 1
fi
