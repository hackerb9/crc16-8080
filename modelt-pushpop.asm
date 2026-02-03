	.8080			; Hint to asmx

;; Macro to generate 6-byte Model-T .CO header: 
;; START - Where the program is ORG'd to run from.
;; LENGTH - Size of executable data, this does not include the header(6 bytes),
;;          just the length of EXECUTABLE DATA.
;; ENTRY - Where the program will be entered (entry point).
;; Executable data - 8085 machine code ORG'ed at START.
ENT:	MACRO 	P1
	DW 	P1, ENDP-BEGINP, P1
	RORG	P1
	ENDM

	ORG	60000			; Use CLEAR 255,59999
	ENT	60000
BEGINP:	

	INCLUDE modelt-driver.asm
	INCLUDE crc16-pushpop.asm

ENDP
