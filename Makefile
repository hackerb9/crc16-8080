all:  crc16-bytewise.bin crc16-bitwise.bin crc16-pushpop.bin  crc16 

# These are just the CRC-16 routine assembled, but _not_ part of a usable program.
crc16-bytewise.bin: crc16-bytewise.asm 
	asmx -e -w -C8080 -b0 crc16-bytewise.asm && mv crc16-bytewise.asm.bin crc16-bytewise.bin

crc16-bitwise.bin: crc16-bitwise.asm 
	asmx -e -w -C8080 -b0 crc16-bitwise.asm && mv crc16-bitwise.asm.bin crc16-bitwise.bin

crc16-pushpop.bin: crc16-pushpop.asm 
	asmx -e -w -C8080 -b0 crc16-pushpop.asm && mv crc16-pushpop.asm.bin crc16-pushpop.bin


# This is a C program for checking that the CRC-16 is being calculated correctly. 
crc16: adjunct/crc16xmodem.h adjunct/crc16.c
	gcc -Wall -g -o $@ $+


clean:
	rm crc16*.bin crc16-*.lst \
	   crc16 *~ 2>/dev/null || true




