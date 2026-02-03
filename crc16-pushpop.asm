;;; CRC16: 16-bit Cyclic Redundancy Check
;;;   An 8080 implementation of CRC-16 using the same parameters as XMODEM.
;;;   Calculates checksum of BC bytes at addr DE and puts result in HL.
;;; 
;;;   THIS VERSION USES PUSH AND POP INSTEAD OF AN ASSEMBLER MACRO.
;;;   IT TAKES 50% LONGER (ABOUT 9 SECONDS) TO CHECK 72K ON A TANDY 200.

;;; Hackerb9, January 2026

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
	
	PUSH D
	MVI D, 8
BITLOOP:	
	DAD H		; Add HL to HL (shift CRC left, pushes bit 15 to Carry)
	JNC NEXTBIT	; If Carry is clear, skip XOR.
	; XOR HL with Xmodem's polynomial (1021H).
	MOV A,H
	XRI 10H
	MOV H,A
	MOV A,L
	XRI 21H
	MOV L,A
NEXTBIT:	
	DCR D
	JNZ BITLOOP
	POP D

DONE8BITS:	
	;;; Done with all 8 bits, get next byte
	INX D			; DE points to next byte 
	DCX B			; BC is length of buffer remaining
	MOV A,B
	ORA C
	JNZ CRC16_MAINLOOP		; Keep going until BC is 0

	;; End of CRC-16 routine. Result is in HL.
	RET

