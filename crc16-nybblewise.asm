;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CRC-16 (Xmodem polynomial)
;;; Calculate checksum of BC bytes at addr DE and put result in HL.
;;; Parameters:
;;; 	HL is current (or initial) checksum
;;; 	DE: Address to start checksumming (0 for ROM)
;;;     BC: Length of buffer to checksum (8000H for 32K ROM)
;;; Result is in HL.
CRC16:
	LXI H, 0     ; HL: Checksum initialized to 0 (for XMODEM style CRC-16)

;;; Call CRC16_CONTINUE to process another block without resetting HL
CRC16_CONTINUE:	

CRC16_MAINLOOP:

;;; Equivalent C-code
;; nh = (data[i] & 0xF0) >> 4;
;; crc = (crc << 4) ^ table_nybble[((crc >> 12) ^ nh) & 0x0f];
;; nl = data[i] & 0x0F;
;; crc = (crc << 4) ^ table_nybble[((crc >> 12) ^ nl) & 0x0f];

	LDAX 	D		;Get two nybbles from memory
	PUSH	D
	PUSH	B
	XRA 	H		; A=A^H
	LXI	D, ha
	STAX	D

	CALL	SHIFTRIGHT4	; index = (H^A)>>4 (high nybble)
	CALL	LOOKUP		; BC = table[index]
	MOV	A, C
	CALL	SHIFTLEFT4	; c1 = (C<<4)
	LXI	D, c1
	STAX	D

	MOV	A, C		; b1 = (B<<4) ^ (C>>4)
	CALL	SHIFTRIGHT4
	MOV	C, A
	MOV	A, B
	CALL	SHIFTLEFT4
	XRA	C
	LXI	D, b1
	STAX	D

	MOV	A, B		; index2 = ( ((H^A)&0xF) ^ B>>4);
	CALL	SHIFTRIGHT4
	MOV	B, A
	LXI	D, ha
	LDAX	D
	ANI	0Fh		; low-nybble
	XRA	B

	CALL	LOOKUP		; BC = table[index2]
	LXI	D, b1		; H2=L^b1^b2
	LDAX	D
	XRA	L
	XRA	B
	MOV	H, A

	LXI	D, c1		; L2 = c1 ^ c2;
	LDAX	D
	XRA	C
	MOV	L, A

	POP	B
	POP 	D

	;;; Get next byte
	INX D			; DE points to next byte 
	DCX B			; BC is length of buffer remaining
	MOV A,B
	ORA C
	JNZ CRC16_MAINLOOP		; Keep going until BC is 0

	;; End of CRC-16 routine. Result is in HL.
	RET



LOOKUP:				; input: A, output: BC=table[A]
	MVI B, 0
	MOV C, A
	PUSH H			; xy = table[A]
	LXI H, table
	DAD B			; ADD with DAD to handle carry.
	DAD B			; Stride of two.
	MOV C, M
	INX H
	MOV B, M
	POP H
	RET

SHIFTRIGHT4:
	ORA A			; clear carry
	RAR
	ORA A
	RAR
	ORA A
	RAR
	ORA A
	RAR
	RET	

SHIFTLEFT4:
	ORA A			; clear carry
	RAL
	ORA A
	RAL
	ORA A
	RAL
	ORA A
	RAL
	RET	


b1:	DW 0x0000
c1:	DW 0x0000
ha:	DW 0x0000


;;; Precomputed nybble-sized table from bitwise algorithm. 
TABLE:	
	DW 0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7
	DW 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
