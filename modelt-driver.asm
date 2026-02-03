;;; tandy-driver: Exercise the CRC-16 routine
;;; Hackerb9, January 2026

;;; This program prints the checksum of the system ROM. Requires 8K of RAM. 
;;; Use CLEAR 256,60000 to reserve space before running.

;;; This should work for any computer related to the Kyotronic-85. 
;;; KC-85, M10, M100, T102, PC8201: All work without special handling. 
;;; Tandy 200: Recognized and checks all 72K of ROM via bank selection. 
;;; PC-8300: Recognized and checks all 128K of ROM via bank selection.

;;; For machine detection, currently two memory addresses are checked:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; |  Model | PEEK(1) | PEEK(21222) | ;;
	;; |-------:|--------:|------------:| ;;
	;; |   kc85 |     225 |         167 | ;;
	;; |    m10 |      35 |          56 | ;;
	;; |   m100 |      51 |         230 | ;;
	;; |   m102 |     167 |         230 | ;;
	;; |   t200 |     171 |          83 | ;;
	;; | pc8201 |     148 |          66 | ;;
	;; | pc8300 |     148 |          64 | ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	.8080			; Hint to asmx

CHGET	EQU	12CBH		; Model 100/102 wait for key
CH200	EQU	12F7H		; Model 200 wait for key
CHNEC	EQU	174DH		; NEC PC-8201 & 8300

;PRT0	EQU	11A2H		; Model 100 print string up to NULL
; Note: PRT0 routine not used so this will work on any device
;LCD	EQU	4B44H		; Model 100 print to LCD screen
; Note: LCD routine not used as RST 4 works on all Kyotronic Sisters

	LXI H, CRCIS		; Print "CRC-16 is "
PRT0:	MOV A, M
	ANA A
	JZ PRT0DONE
	RST 4
	INX H
	JMP PRT0
PRT0DONE:

	;; Tandy 200 if peek(1) == 171, ROM is 72K (40K + 32K).
	LXI D, 1
	LDAX D
	CPI 171			; T200
	JZ TANDY200

	LXI D, 21222
	LDAX D
	CPI 64			; PC8300
	JZ PC8300

KYOTRONIC:	
	;; All other Kyotronic Sisters (m100, m10, pc8201) have 32KB of ROM.
	LXI D, 0     ; DE: Address to start checksumming (0 for ROM)
	LXI B, 8000H ; BC: Length of buffer (8000H for 32K ROM)

	;; Calculate checksum of BC bytes at addr DE and put result in HL.
	CALL CRC16
	JMP ALLDONE

TANDY200:	
	;; Handle the Tandy 200 specially
	LXI D, 0     ; DE: Address to start checksumming (0 for main ROM)
	LXI B, A000H ; BC: Length of buffer (40K ROM for T200)
	CALL CRC16

	;; Switch to the Multiplan ROM bank
        ; first, disable interrupts and keep them off,
        ; then send a specific byte to a specific IO port to see multiplan 
	DI
	IN 0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	ORI 00000001b		; enable multiplan rom
	OUT 0D8H
	
	LXI D, 0     ; DE: Address to start checksumming (0 for main ROM)
	LXI B, 8000H ; BC: Length of buffer (32K ROM for T200)
	CALL CRC16_CONTINUE

	;; Switch back to normal BASIC ROM 
        ; send a specific byte to a specific IO port to get back
        ; to the main rom, enable interrupts
	IN 0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	OUT 0D8H	
	EI

	JMP ALLDONE
	
PC8300:	
	;; The PC8300 has four ROM banks of 32K each.
	DI			; Disable interrupts before switching banks

	LXI H, 0		; Initialize CRC to 0 so we can use _CONTINUE
	MVI D, 0		; Rom bank counter 000b to 100b
PC8300_BANK_LOOP:
	PUSH D
	LXI D, 0     ; DE: Address to start checksumming
	LXI B, 8000H ; BC: Length of buffer (8000H is 32K)
	CALL CRC16_CONTINUE
	POP D

	IN 0A3h
	ANI 11111100b		; keep the ram bits, zero out the rom bits
	INR D
	ORA D			; enable bank 01, 10, 11, then 00
	OUT 0A3H

	MOV A, D
	CPI 00000100b
	JNZ PC8300_BANK_LOOP

	;; We're back to ROM bank 00, so enable interrupts
	EI

	JMP ALLDONE


ALLDONE:
	;;; All done with entire buffer. Result is in HL.
	XCHG			; Swap HL and DE for printing

	;; Print DE as hexadecimal nybbles
	LXI H, HEXITS
	MOV A, D
	ANI F0H
	RAR
	RAR
	RAR
	RAR
	MVI B, 0
	MOV C, A
	DAD B
	MOV A, M
	RST 4

	LXI H, HEXITS
	MOV A, D
	ANI 0FH
	MVI B, 0
	MOV C, A
	DAD B
	MOV A, M
	RST 4

	LXI H, HEXITS
	MOV A, E
	ANI F0H
	RAR
	RAR
	RAR
	RAR
	MVI B, 0
	MOV C, A
	DAD B
	MOV A, M
	RST 4

	LXI H, HEXITS
	MOV A, E
	ANI 0FH
	MVI B, 0
	MOV C, A
	DAD B
	MOV A, M
	RST 4

	;; Do we know how to wait for a key?
	LXI D, 1
	LDAX D
	CPI 171			; T200
	JZ WAIT200
	CPI 51			; M100
	JZ WAIT100
	CPI 167			; M102
	JZ WAIT100
	CPI 148			; PC-8201 or 8300
	JZ WAITNEC

	;; Unrecognized machine, let's just pause for about 5 seconds.
	LXI B, 10H
PAUSE1:	
	LXI H, FFFFH
PAUSE2:	DCX H
	MOV A, L
	ORA H
	JNZ PAUSE2
	DCX B
	MOV A, C
	ORA B
	JNZ PAUSE1
	RET

WAIT200:
	CALL CH200
	RET

WAIT100:
	CALL CHGET
	RET

WAITNEC:
	CALL CHNEC
	RET


CRCIS:	DB "CRC-16 = ", 0
HEXITS:	DB "0123456789ABCDEF"

