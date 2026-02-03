;;; CRC16: 16-bit Cyclic Redundancy Check
;;;   An 8080 implementation of CRC-16 using the same parameters as XMODEM.
;;;   Calculates checksum of BC bytes at addr DE and puts result in HL.
;;; 
;;;   This is the most basic, bitwise algorithm. It is slower than the
;;;   byte-at-a-time algorithm, but it uses an assembler macro in an
;;;   unrolled loop so it is faster than the version which does a push
;;;   and a pop for each byte.
;;; 
;;; Hackerb9, January 2026

;;; Macro to XOR HL with Xmodem's polynomial (1021H).
XORPOLY: MACRO
	MOV A,H
	XRI 10H
	MOV H,A
	MOV A,L
	XRI 21H
	MOV L,A
	ENDM

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
	LDAX D			; Get each byte from memory
	XRA H			; XOR the high byte of the checksum
	MOV H, A
	
;;; Unrolled inner loop for eight bits. Faster than PUSH/POP per byte.
BIT7:	
	DAD H		; Add HL to HL (shift CRC left, pushes bit 15 to Carry)
	JNC BIT6	; If Carry is clear, skip XOR.
	XORPOLY		; XOR HL with Xmodem's polynomial (1021H).
BIT6:	
	DAD H
	JNC BIT5
	XORPOLY
BIT5:	
	DAD H
	JNC BIT4
	XORPOLY
BIT4:	
	DAD H
	JNC BIT3
	XORPOLY
BIT3:	
	DAD H
	JNC BIT2
	XORPOLY
BIT2:	
	DAD H
	JNC BIT1
	XORPOLY
BIT1:	
	DAD H
	JNC BIT0
	XORPOLY
BIT0:	
	DAD H
	JNC DONE8BITS
	XORPOLY
DONE8BITS:	
	;;; Done with all 8 bits, get next byte
	INX D			; DE points to next byte 
	DCX B			; BC is length of buffer remaining
	MOV A,B
	ORA C
	JNZ CRC16_MAINLOOP		; Keep going until BC is 0

	;; End of CRC-16 routine. Result is in HL.
	RET

