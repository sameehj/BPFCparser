## Rationale

I have wasted many hours searching for a tool that can be used to accomplish this task but I have found none. So I've decided to write this scriptand it turns out to be easy when you know how :)

## Instruction encoding

An eBPF program is a sequence of 64-bit instructions. This project assumes each
instruction is encoded in host byte order, but the byte order is not relevant
to this spec.

All eBPF instructions have the same basic encoding:

    msb                                                        lsb
    +------------------------+----------------+----+----+--------+
    |immediate               |offset          |src |dst |opcode  |
    +------------------------+----------------+----+----+--------+

From least significant to most significant bit:

 - 8 bit opcode
 - 4 bit destination register (dst)
 - 4 bit source register (src)
 - 16 bit offset
 - 32 bit immediate (imm)

Most instructions do not use all of these fields. Unused fields should be
zeroed.


## Object file generation:
Usually compiling the code for bpf code can be done by using the following command:

clang -I path/to/iproute2/include -O2 -emit-llvm -c bpf_program.c -o - | llc -march=bpf -filetype=obj -o bpf_program.o

## C-style array generation:
The parse_dump script takes as an input a compiled object file and obtionally a section name and outputs a c-array style which can be used for initializing an array of the "struct bpf_insn" structure.

struct bpf_insn {<br/>
	__u8	code;		/* opcode */<br/>
	__u8	dst_reg:4;	/* dest register */<br/>
	__u8	src_reg:4;	/* source register */<br/>
	__s16	off;		/* signed offset */<br/>
	__s32	imm;		/* signed immediate constant */<br/>
};
