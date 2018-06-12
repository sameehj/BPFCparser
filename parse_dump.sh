#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--section)
    SECTION="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--object-file)
    OBJECTFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    HELPMENU=true
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


if [[ -v HELPMENU ]] || ! [[ -v OBJECTFILE ]]; then
    printf "This script can be used to create a c-array in 'struct bpf_insn' compatible format out of a bpf object file. The script uses llvm-objdump for dumping the 64 bit bpf command in hex fromat and awk to align them in comma separated format according to the following sizing:\n\
* 8 bit opcode\n\
* 4 bit destination register (dst)\n\
* 4 bit source register (src)\n\
* 16 bit offset\n\
* 32 bit immediate (imm)\n\
The parameters to the script that should be provided are section name and object file name using the following flags:\n\
* -s|--section\n\
* -o|--object-file\n"
    exit
fi

if [[ -v SECTION ]]; then
    SECTION="--section $SECTION"
fi

llvm-objdump -S --disassemble-all --print-imm-hex $SECTION $OBJECTFILE  | awk '{n=split($0,a,"\t"); if(n==3){split(a[2],b," "); print "{0x"b[1]" ,0x"substr(b[2],2,1)" ,0x"substr(b[2],1,1)" ,0x"b[4]b[3]", 0x"b[8]b[7]b[6]b[5]"},"} next;}'
