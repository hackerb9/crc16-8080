all:  crc16-bytewise.bin crc16-bitwise.bin crc16-pushpop.bin \
	CRC16.CO CRCBIT.CO CRCPSH.CO crc16 


# These are just the CRC-16 routine assembled, but not part of a usable program.
crc16-bytewise.bin: crc16-bytewise.asm 
	asmx -e -w -C8080 -b0 crc16-bytewise.asm && mv crc16-bytewise.asm.bin crc16-bytewise.bin

crc16-bitwise.bin: crc16-bitwise.asm 
	asmx -e -w -C8080 -b0 crc16-bitwise.asm && mv crc16-bitwise.asm.bin crc16-bitwise.bin

crc16-pushpop.bin: crc16-pushpop.asm 
	asmx -e -w -C8080 -b0 crc16-pushpop.asm && mv crc16-pushpop.asm.bin crc16-pushpop.bin


# These are the executables for the Kyotronic Sisters (Model T computers)

CRC16.CO: modelt-bytewise.asm modelt-driver.asm crc16-bytewise.asm
	asmx -e -w -b60000 modelt-bytewise.asm && mv modelt-bytewise.asm.bin CRC16.CO
	cp -p CRC16.CO ../VirtualT/ || true

CRCBIT.CO: modelt-bitwise.asm modelt-driver.asm crc16-bitwise.asm
	asmx -e -w -b60000 modelt-bitwise.asm && mv modelt-bitwise.asm.bin CRCBIT.CO
	cp -p CRCBIT.CO ../VirtualT/ || true

CRCPSH.CO: modelt-pushpop.asm modelt-driver.asm crc16-pushpop.asm
	asmx -e -w -b60000 modelt-pushpop.asm && mv modelt-pushpop.asm.bin CRCPSH.CO
	cp -p CRCPSH.CO ../VirtualT/ || true

# This is a C program for checking that the CRC-16 is being calculated correctly. 
crc16: adjunct/crc16xmodem.h adjunct/crc16.c
	gcc -Wall -g -o $@ $+


clean:
	rm modelt-*.lst modelt-*.bin \
	   crc16*.bin crc16-*.lst CRC*.CO \
	   crc16 *~ 2>/dev/null || true




