all:  crc16-bytewise.bin crc16-bitwise.bin crc16-pushpop.bin crc16.co crcbit.co crcpsh.co


# These are just the CRC-16 routine assembled, but not part of a usable program.
crc16-bytewise.bin: crc16-bytewise.asm 
	asmx -e -w -C8080 -b0 crc16-bytewise.asm && mv crc16-bytewise.asm.bin crc16-bytewise.bin

crc16-bitwise.bin: crc16-bitwise.asm 
	asmx -e -w -C8080 -b0 crc16-bitwise.asm && mv crc16-bitwise.asm.bin crc16-bitwise.bin

crc16-pushpop.bin: crc16-pushpop.asm 
	asmx -e -w -C8080 -b0 crc16-pushpop.asm && mv crc16-pushpop.asm.bin crc16-pushpop.bin


# These are the executables for the Kyotronic Sisters (Model T computers)

crc16.co: modelt-bytewise.asm modelt-driver.asm crc16-bytewise.asm
	asmx -e -w -b60000 modelt-bytewise.asm && mv modelt-bytewise.asm.bin crc16.co
	cp -p crc16.co ../VirtualT/crc16.co

crcbit.co: modelt-bitwise.asm modelt-driver.asm crc16-bitwise.asm
	asmx -e -w -b60000 modelt-bitwise.asm && mv modelt-bitwise.asm.bin crcbit.co
	cp -p crcbit.co ../VirtualT/crcbit.co

crcpsh.co: modelt-pushpop.asm modelt-driver.asm crc16-pushpop.asm
	asmx -e -w -b60000 modelt-pushpop.asm && mv modelt-pushpop.asm.bin crcpsh.co
	cp -p crcpsh.co ../VirtualT/crcpsh.co

clean:
	rm modelt-*.lst modelt-*.bin crc16*.bin crc16-*.lst crc*.co *~ 2>/dev/null || true




