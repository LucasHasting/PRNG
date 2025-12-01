;Name: Lucas Hasting
;Class: CS 490
;Date: 12/3/2025
;Instructor: Dr. Jerkins
;Description: Procedures for a PRNG on an 8-bit computer (w65c02sxb)
;Source: https://6502.org/
;        Starter code: https://github.com/andrew-jacobs/w65c02sxb-monitor/
;        Example code by Dr. Jerkins

;===============================================================================
;
; Change this to what ever you need.

;-------------------------------------------------------------------------------

		.include "w65c02sxb.inc"
		
;===============================================================================
; ASCII Control Characters
;-------------------------------------------------------------------------------

LF		.equ	$0a
CR		.equ	$0d

;===============================================================================
; Data Areas
;-------------------------------------------------------------------------------

;		.page0
		.org	$00
		
PTR		.space	2
;
;		.bss
;		.org	$0280

; More storage space here if need

;===============================================================================
; Application code - PRNG
;-------------------------------------------------------------------------------

;		.code
		
; Assemble to fixed memory address -- Makes the listing much easier to read. No
; ?? bytes for relocatable addresses that are patched by the linker.

                .org	$0410		; limit is $6FFF

; Description:  Example PRNG usage
; INPUT:        NONE
; OUTPUT:       addresses (0000 - 007f) -> the table for the LCG, Y and A are not preserved

PRNG:
    ;Display a new line to start
    JSR displayNewLine

    ;Seed the rand using default behavior
    LDY #0
    JSR SRAND

    ;display 3 random numbers
    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine

    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine

    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine

    ;seed with specefic value
    LDY #$f8
    JSR SRAND

    ;display 3 random numbers from set seed
    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine

    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine

    JSR NEXT
    JSR BIN2HEX
    JSR displayNewLine
    
    BRK  ;END

;===============================================================================
; SRAND
;-------------------------------------------------------------------------------

; Description:  Seeds and inits the PRNG
; INPUT:        Y=0 => defualt, Y is a seed for the PRNG
; OUTPUT:       addresses (0000 - 007f) -> the table for the LCG

SRAND:
    JSR LoadTable       ;load the table into zero page (0000 - 007f)
    CPY #0              ;compare y register with 0
    BNE end_srand
    LDY $040B           ;default seed location 
                        ; - roughly uniformly random, hardware related

    ;reduce y register to modulo $7f and return
    end_srand:
        JSR reduceY
        RTS

;===============================================================================
; NEXT
;-------------------------------------------------------------------------------

; Description:  Get's the next random number in the LCG table
; INPUT:        Y - an index in the table of random numbers
; OUTPUT:       A - the random number at the inital index of Y
;               Y - the next index in the table of random numbers     

NEXT:
    LDA $00,Y   ;load table value in A
    JSR Count   ;Increase Y
    RTS         ;END

;===============================================================================
; reduceY
;-------------------------------------------------------------------------------

; Description:  Get's the next random number in the LCG table
; INPUT:        Y - an index for the table of random numbers
;                   (can be outside the range)
; OUTPUT:       Y - an index in the table of random numbers

reduceY:
    PHA                 ;save A
    TYA                 ;move contents of Y to A

    ;if good, go to end of procedure
    CMP #$80
    BCC End_reduce

    ;keep subtracting until good
    Loop:
        ;subtract
        SEC
        SBC #$7f

        ;check if keep looping 
        CMP #$7f
        BCS Loop
    End_reduce:
        TAY             ;move contents of A to Y
        PLA             ;get A back
        RTS             ;end


;===============================================================================
; displayNewLine
;-------------------------------------------------------------------------------

; Description:  Uses UartTx to display a new line character
; INPUT:        NONE
; OUTPUT:       NONE

;procedure to display a new line
displayNewLine:
    PHA
    LDA #10     ;Newline ASCII Character
    JSR UartTx 
    PLA
    RTS         ;END

;===============================================================================
; UART I/O - FROM EXAMPLE - UNTOUCHED
;-------------------------------------------------------------------------------

; Inserts the byte in A into the transmit buffer. If the buffer is full then
; wait until some space is available. Registers are preserved.
; MODIFIED - Added a counter, Y-REG

UartTx:
		PHA
                PHX
		TAX
		
                LDA     #$01        	; Wait until there is space for data
L2:		BIT    VIA2_IRB
                BNE    L2
		
		LDA	#$ff		; Make port an output
		STA	VIA2_DDRA
		STX	VIA2_ORA	; And output the character
                LDA     #$04        	; Strobe WR high
		TSB	VIA2_ORB ;Set to high
                NOP
                NOP
		TRB	VIA2_ORB ;Set to low, to write bit
                PLX
		PLA
		RTS			; Done

;===============================================================================
; BIN2HEX
;-------------------------------------------------------------------------------

; Description:  Uses UART I/O to display a byte in memory
; INPUT:        A - register to display using UartTx
; OUTPUT:       NONE
BIN2HEX:
    PHA                  ;save A

    ;get high nibble
    AND #$F0             ;CUTOFF low nibble
    LSR                  ;BIT Shift 4 times
    LSR
    LSR
    LSR
    ORA #$30             ;ASCII Shift
    JSR LetterShift      ;Shift more if needed
    JSR UartTx           ;DISPLAY BYTE

    PLA                  ;get A back
    PHA                  ;save A
    AND #$0F             ;get low nibble
    ORA #$30             ;ASCII Shift
    JSR LetterShift      ;Shift more if needed
    JSR UartTx           ;DISPLAY BYTE
    PLA                  ;get A back
    RTS                  ;end procedure

;===============================================================================
; LoadTable
;-------------------------------------------------------------------------------

; Description:  Load a table into memory (addresses 0000 - 007f),
;               does not perserve contents in memory.
; INPUT:        NONE
; OUTPUT:       NONE
LoadTable:
    PHX             ; save x
    LDX #0 	        ; x is index register
    L1:	            ; LOOP    
        LDA TABLE,X		    ; load table into X addr
        STA $00,X		    ; store into 00 + X 
        INX			        ; increment X addr
        CPX #$f0		   	; compare to f0
        BNE L1			    ; go until X=7F
    PLX             ; get x back
    RTS             ; end proceduue

;===============================================================================
; LetterShift
;-------------------------------------------------------------------------------

; Description:  Shift for when A is greater than 10,
;               used for displaying a byte
; INPUT:        A, reg to shift (if needed)
; OUTPUT:       A, shifted if needed

LetterShift:
    ;Check if A is <= 9, if so, end
    CMP #$3A
    BCC endShift

    ;INC A - 7 times
    INA
    INA
    INA
    INA
    INA
    INA
    INA		

    endShift:
    RTS ; end procedure

;===============================================================================
; Count
;-------------------------------------------------------------------------------

; Description:  Count Y cyclically (bounds in 0000 - 007f - same as table)
; INPUT:        Y, reg to increment (table index)
; OUTPUT:       Y, incremented cyclically

Count:
    ;INC Y - Count Up
    INY

    ;Check if Y is >= $80, if so, reset Y-REG
    CPY #$7f
    BCS resetY
    RTS ; end procedure

    resetY:
        LDY #0
        RTS ; end procedure

;===============================================================================
; TABLE - Linear Congruential Generator - See table.py 
;-------------------------------------------------------------------------------

TABLE: 	
    .BYTE $41,$23,$20,$08
    .BYTE $17,$e4,$6b,$5a
    .BYTE $39,$23,$ca,$ed
    .BYTE $56,$01,$1f,$97
    .BYTE $39,$01,$da,$9a
    .BYTE $33,$93,$af,$f5
    .BYTE $22,$a9,$4a,$b7
    .BYTE $19,$30,$90,$f6
    .BYTE $5d,$b6,$24,$3b
    .BYTE $13,$62,$06,$93
    .BYTE $51,$a6,$1d,$7a
    .BYTE $2c,$14,$30,$2c
    .BYTE $28,$5b,$57,$14
    .BYTE $79,$2f,$6d,$0e
    .BYTE $61,$f5,$d4,$16
    .BYTE $26,$c8,$ef,$50
    .BYTE $bd,$5f,$5e,$02
    .BYTE $42,$12,$8f,$e9
    .BYTE $4f,$41,$83,$50
    .BYTE $51,$b9,$2a,$87
    .BYTE $4b,$8f,$4b,$1d
    .BYTE $65,$89,$4e,$68
    .BYTE $3b,$d4,$3e,$e3
    .BYTE $97,$88,$1b,$0c
    .BYTE $44,$13,$92,$de
    .BYTE $5f,$23,$a8,$e5
    .BYTE $59,$18,$93,$d8
    .BYTE $67,$c9,$d3,$c3
    .BYTE $50,$f7,$a9,$46
    .BYTE $52,$31,$b7,$ee
    .BYTE $a0,$e5,$ef,$05
    .BYTE $1d,$0b,$32,$d6

