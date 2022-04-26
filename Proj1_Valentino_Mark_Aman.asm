$NOLIST
$MODLP51
$LIST

CLK                EQU 22118400 ; Microcontroller system crystal frequency in Hz
TIMER0_RATE_LOW    EQU 4000 ; 2000Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_LOW  EQU ((65536-(CLK/TIMER0_RATE_LOW)))

TIMER0_RATE_HIGH   EQU 4200 ; 2100Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_HIGH EQU ((65536-(CLK/TIMER0_RATE_HIGH)))

TIMER0_RATE_E   EQU 1319 ; 659.26Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_E EQU ((65536-(CLK/TIMER0_RATE_E)))

TIMER0_RATE_EL   EQU 660 ; 659.26Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_EL EQU ((65536-(CLK/TIMER0_RATE_EL)))

TIMER0_RATE_F   EQU 1397 ; 698.46Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_F EQU ((65536-(CLK/TIMER0_RATE_F)))

TIMER0_RATE_Fs   EQU 740 ; 698.46Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_Fs EQU ((65536-(CLK/TIMER0_RATE_Fs)))

TIMER0_RATE_G   EQU 1568 ; 783.99Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_G EQU ((65536-(CLK/TIMER0_RATE_G)))

TIMER0_RATE_GL   EQU 784 ; 783.99Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_GL EQU ((65536-(CLK/TIMER0_RATE_GL)))

TIMER0_RATE_A   EQU 880 ; 440Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_A EQU ((65536-(CLK/TIMER0_RATE_A)))

TIMER0_RATE_AH   EQU 1760 ; 440Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_AH EQU ((65536-(CLK/TIMER0_RATE_AH)))


TIMER0_RATE_C   EQU 1047 ; 523.25Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_C EQU ((65536-(CLK/TIMER0_RATE_C)))

TIMER0_RATE_Cs  EQU 1108 ; 523.25Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_Cs EQU ((65536-(CLK/TIMER0_RATE_Cs)))

TIMER0_RATE_CL   EQU 523 ; 523.25Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_CL EQU ((65536-(CLK/TIMER0_RATE_CL)))

TIMER0_RATE_D   EQU 1175 ; 587.33Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_D EQU ((65536-(CLK/TIMER0_RATE_D)))

TIMER0_RATE_DH  EQU 2350 ; 587.33Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_DH EQU ((65536-(CLK/TIMER0_RATE_DH)))

TIMER0_RATE_B   EQU 988 ; 493.88Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_B EQU ((65536-(CLK/TIMER0_RATE_B)))

TIMER0_RATE_Bf   EQU 932 ; 493.88Hz squarewave (peak amplitude of CEM-1203 speaker)
TIMER0_RELOAD_Bf EQU ((65536-(CLK/TIMER0_RATE_Bf)))

SOUND_OUT equ P1.1

NO_CURSOR  equ P2.4
YES_CURSOR equ P2.2
SELECT	   equ P1.3

org 0000H
   ljmp MyProgram
   
; Timer/Counter 0 overflow interrupt vector
org 0x000B
	ljmp Timer0_ISR
	
; Timer/Counter 2 overflow interrupt vector
org 0x002B
	ljmp Timer2_ISR

; These register definitions needed by 'math32.inc'
DSEG at 30H
x:   ds 4
y:   ds 4
bcd: ds 5
z:	 ds 4 ;new variable for new macro
w:   ds 4
q:   ds 4

test: ds 1
testb: ds 1
Seed: ds 32
T2ov: ds 2

BSEG
mf: dbit 1

;test_zero_flag:  dbit 1
;testb_zero_flag: dbit 1

HLbit: dbit 1
$NOLIST
$include(math32.inc)
$LIST

cseg
; These 'equ' must match the hardware wiring
LCD_RS equ P3.2
;LCD_RW equ PX.X ; Not used in this code, connect the pin to GND
LCD_E  equ P3.3
LCD_D4 equ P3.4
LCD_D5 equ P3.5
LCD_D6 equ P3.6
LCD_D7 equ P3.7

$NOLIST
$include(LCD_4bit.inc) ; A library of LCD related functions and utility macros
$LIST

;                     1234567890123456    <- This helps determine the location of the counter

No_Signal_Str:    		  db 'No signal       ', 0
ye:      db 'ye', 0
	
;---------------------------------;
; ISR for timer 0.  Set to execute;

; every 1/4096Hz to generate a    ;
; 2048 Hz square wave at pin P1.1 ;
;---------------------------------;
Timer0_ISR:
	cpl SOUND_OUT ; Connect speaker to P1.1!
	reti

; When using a 22.1184MHz crystal in fast mode
; one cycle takes 1.0/22.1184MHz = 45.21123 ns
WaitHalfSec:
    mov R2, #89
Q3: mov R1, #250
Q2: mov R0, #166
Q1: djnz R0, Q1 ; 3 cycles->3*45.21123ns*166=22.51519us
    djnz R1, Q2 ; 22.51519us*250=5.629ms
    djnz R2, Q3 ; 5.629ms*89=0.5s (approximately)
    ret

; Sends 10-digit BCD number in bcd to the LCD
Display_10_digit_BCD:
	Display_BCD(bcd+4)
	Display_BCD(bcd+3)
	Display_BCD(bcd+2)
	Display_BCD(bcd+1)
	Display_BCD(bcd+0)
	ret

;Initializes timer/counter 2 as a 16-bit timer
InitTimer2:
	mov T2CON, #0 ; Stop timer/counter.  Set as timer (clock input is pin 22.1184MHz).
	; Set the reload value on overflow to zero (just in case is not zero)
	mov RCAP2H, #0
	mov RCAP2L, #0
    ret

Timer2_ISR:
	clr TF2
	push acc
	inc T2ov+0
	mov a, T2ov+0
	jnz Timer2_ISR_done
	inc T2ov+1
Timer2_ISR_done:
	pop acc
	reti
	
InitTimer0:
	mov a, TMOD
	anl a, #0xf0 ; 11110000 Clear the bits for timer 0
	orl a, #0x01 ; 00000001 Configure timer 0 as 16-timer
	mov TMOD, a
	mov TH0, #high(TIMER0_RELOAD_A)
	mov TL0, #low(TIMER0_RELOAD_A)
	; Set autoreload value
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	; Enable the timer and interrupts
    setb ET0  ; Enable timer 0 interrupt
    setb TR0  ; Start timer 0
	ret
	

;---------------------------------;
; Hardware initialization         ;
;---------------------------------;
Initialize_All:
    lcall InitTimer2
    lcall LCD_4BIT ; Initialize LCD
	ret


;------------------------------------------------
; p = p + q
;------------------------------------------------	
add32pq:
	push acc
	push psw
	mov a, w+0
	add a, q+0
	mov w+0, a
	mov a, w+1
	addc a, q+1
	mov w+1, a
	mov a, w+2
	addc a, q+2
	mov w+2, a
	mov a, w+3
	addc a, q+3
	mov w+3, a
	clr a
	pop psw
	pop acc
	ret
	
;------------------------------------------------
; p = p * q
;------------------------------------------------
mul32pq:

	push acc
	push b
	push psw
	push AR0
	push AR1
	push AR2
	push AR3
		
	; R0 = x+0 * y+0
	; R1 = x+1 * y+0 + x+0 * y+1
	; R2 = x+2 * y+0 + x+1 * y+1 + x+0 * y+2
	; R3 = x+3 * y+0 + x+2 * y+1 + x+1 * y+2 + x+0 * y+3
	
	; Byte 0
	mov	a,w+0
	mov	b,q+0
	mul	ab		; x+0 * y+0
	mov	R0,a
	mov	R1,b
	
	; Byte 1
	mov	a,w+1
	mov	b,q+0
	mul	ab		; x+1 * y+0
	add	a,R1
	mov	R1,a
	clr	a
	addc a,b
	mov	R2,a
	
	mov	a,w+0
	mov	b,q+1
	mul	ab		; x+0 * y+1
	add	a,R1
	mov	R1,a
	mov	a,b
	addc a,R2
	mov	R2,a
	clr	a
	rlc	a
	mov	R3,a
	
	; Byte 2
	mov	a,w+2
	mov	b,q+0
	mul	ab		; x+2 * y+0
	add	a,R2
	mov	R2,a
	mov	a,b
	addc a,R3
	mov	R3,a
	
	mov	a,w+1
	mov	b,q+1
	mul	ab		; x+1 * y+1
	add	a,R2
	mov	R2,a
	mov	a,b
	addc a,R3
	mov	R3,a
	
	mov	a,w+0
	mov	b,q+2
	mul	ab		; x+0 * y+2
	add	a,R2
	mov	R2,a
	mov	a,b
	addc a,R3
	mov	R3,a
	
	; Byte 3
	mov	a,w+3
	mov	b,q+0
	mul	ab		; x+3 * y+0
	add	a,R3
	mov	R3,a
	
	mov	a,w+2
	mov	b,q+1
	mul	ab		; x+2 * y+1
	add	a,R3
	mov	R3,a
	
	mov	a,w+1
	mov	b,q+2
	mul	ab		; x+1 * y+2
	add	a,R3
	mov	R3,a
	
	mov	a,w+0
	mov	b,q+3
	mul	ab		; x+0 * y+3
	add	a,R3
	mov	R3,a
	
	mov	w+3,R3
	mov	w+2,R2
	mov	w+1,R1
	mov	w+0,R0
	clr a

	pop AR3
	pop AR2
	pop AR1
	pop AR0
	pop psw
	pop b
	pop acc
	
	ret
	
Load_q MAC
	mov q+0, #low (%0 % 0x10000) 
	mov q+1, #high(%0 % 0x10000) 
	mov q+2, #low (%0 / 0x10000) 
	mov q+3, #high(%0 / 0x10000) 
ENDMAC
	
;---------------------------------;
; Random         ;
;---------------------------------;	
	
Random:
	; Seed = 214013*Seed+2531011
	mov w+0, Seed+0
	mov w+1, Seed+1
	mov w+2, Seed+2
	mov w+3, Seed+3
	Load_q(214013)
	lcall mul32pq
	Load_q(2531011)
	lcall add32pq
	mov Seed+0, w+0
	mov Seed+1, w+1
	mov Seed+2, w+2
	mov Seed+3, w+3
	ret
	
;---------------------------------;
; Wait Random Seconds             ;
;---------------------------------;

Wait_Random:
	Wait_Milli_Seconds(Seed+0)
	Wait_Milli_Seconds(Seed+1)
	Wait_Milli_Seconds(Seed+2)
	Wait_Milli_Seconds(Seed+3)
	ret	
	
;---------------------------------;
; Main program loop               ;
;---------------------------------;
MyProgram:
    ; Initialize the hardware:
    mov SP, #7FH
    lcall InitTimer0
    ;lcall Timer0_Init_HIGH   
    lcall Initialize_All
    setb EA
    setb P0.0 ; Pin is used as right input
    setb P0.1 ; Pin is used as left input
    mov test, #0x00
    mov testb, #0x00
    mov R0, #0x00 ; added point flag
    mov R1, #0x00 ; added point flagB
    mov R2, #0x00 ; flag to test if HLbit is 1 or 0
    mov R3, #0x00 ; Player1 first flag
    mov R4, #0x00 ; Player2 first flag
    mov R5, #0x00 ; flag for if cursor is on "YES" or "NO"
    mov R6, #0x00 ; flag to check for 100 iterations through scoringA
    mov R7, #0x00 ; flag to check for 100 iterations through scoringB
    ;mov test_zero_flag,  #0x00 ; flag to check if test  is zero
	;mov testb_zero_flag, #0x00 ; flag to check if testb is zero
    
    clr TR0
    
    ; Initial seed
    setb TR2
    jb P4.5, $
    mov Seed+0, TH2
    mov Seed+1, #0x01
    mov Seed+2, #0x87
    mov Seed+3,	TL2
    clr TR2
    
    ; "HELLO"
    
    Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#'H')
	Set_Cursor(1, 7)
	Display_char(#'E')
	Set_Cursor(1, 8)
	Display_char(#'L')
	Set_Cursor(1, 9)
	Display_char(#'L')
	Set_Cursor(1, 10)
	Display_char(#'0')
	Set_Cursor(1, 11)
	Display_char(#'!')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	; OPENING MUSIC --> Windows XP BOOT Sound
    
    clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	lcall WaitHalfSec
	Wait_Milli_Seconds(#90)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	Wait_Milli_Seconds(#150)

	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_AH)
	mov RL0, #low(TIMER0_RELOAD_AH)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)
	
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_G)
	mov RL0, #low(TIMER0_RELOAD_G)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)

    
    clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_AH)
	mov RL0, #low(TIMER0_RELOAD_AH)
	setb TR0
	
	lcall WaitHalfSec
	lcall WaitHalfSec
	
	clr TR0
    
    ljmp ask_prompt

	;setb TR0 ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
winner_one:

	;mov a, testb_zero_flag
	;cjne a, #0x01, regular_winner_one_x ; if flag is one, goes to ace display and sound
	;ljmp ACE_one
	
	mov a, testb ; checking to see if testb is 0
	cjne a, #0x00, regular_winner_one_x
	ljmp ACE_one
	
regular_winner_one_x:
	ljmp regular_winner_one
	
ACE_one:

	Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#' ')
	Set_Cursor(1, 7)
	Display_char(#' ')
	Set_Cursor(1, 8)
	Display_char(#' ')
	Set_Cursor(1, 9)
	Display_char(#' ')
	Set_Cursor(1, 10)
	Display_char(#' ')
	Set_Cursor(1, 11)
	Display_char(#' ')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	Set_Cursor(2, 1)
	Display_char(#' ')
	Set_Cursor(2, 2)
	Display_char(#' ')
	Set_Cursor(2, 3)
	Display_char(#' ')
	Set_Cursor(2, 4)
	Display_char(#' ')
	Set_Cursor(2, 5)
	Display_char(#' ')
	Set_Cursor(2, 6)
	Display_char(#' ')
	Set_Cursor(2, 7)
	Display_char(#'A')
	Set_Cursor(2, 8)
	Display_char(#'C')
	Set_Cursor(2, 9)
	Display_char(#'E')
	Set_Cursor(2, 10)
	Display_char(#'!')
	Set_Cursor(2, 11)
	Display_char(#' ')
	Set_Cursor(2, 12)
	Display_char(#' ')
	Set_Cursor(2, 13)
	Display_char(#' ')
	Set_Cursor(2, 14)
	Display_char(#' ')
	Set_Cursor(2, 15)
	Display_char(#' ')
	Set_Cursor(2, 16)
	Display_char(#' ')
	
	; HALO Soundtrack
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	ljmp ACE_one
	
regular_winner_one:
	
	Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#' ')
	Set_Cursor(1, 7)
	Display_char(#' ')
	Set_Cursor(1, 8)
	Display_char(#' ')
	Set_Cursor(1, 9)
	Display_char(#' ')
	Set_Cursor(1, 10)
	Display_char(#' ')
	Set_Cursor(1, 11)
	Display_char(#' ')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	Set_Cursor(2, 1)
	Display_char(#' ')
	Set_Cursor(2, 2)
	Display_char(#' ')
	Set_Cursor(2, 3)
	Display_char(#' ')
	Set_Cursor(2, 4)
	Display_char(#' ')
	Set_Cursor(2, 5)
	Display_char(#' ')
	Set_Cursor(2, 6)
	Display_char(#'W')
	Set_Cursor(2, 7)
	Display_char(#'I')
	Set_Cursor(2, 8)
	Display_char(#'N')
	Set_Cursor(2, 9)
	Display_char(#'N')
	Set_Cursor(2, 10)
	Display_char(#'E')
	Set_Cursor(2, 11)
	Display_char(#'R')
	Set_Cursor(2, 12)
	Display_char(#' ')
	Set_Cursor(2, 13)
	Display_char(#' ')
	Set_Cursor(2, 14)
	Display_char(#' ')
	Set_Cursor(2, 15)
	Display_char(#' ')
	Set_Cursor(2, 16)
	Display_char(#' ')
	
	; Victory Sound

	clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#10)
	
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#10)
	
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	
	Wait_Milli_Seconds(#10)
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Bf)
	mov RL0, #low(TIMER0_RELOAD_Bf)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_C)
	mov RL0, #low(TIMER0_RELOAD_C)
	setb TR0

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_C)
	mov RL0, #low(TIMER0_RELOAD_C)
	setb TR0

	Wait_Milli_Seconds(#150)


	clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	lcall WaitHalfSec
	lcall WaitHalfSec
	
	ljmp regular_winner_one
	
winner_two:

	mov a, test ; checking to see if test is 0
	cjne a, #0x00, regular_winner_two_x
	ljmp ACE_two
	
regular_winner_two_x:
	ljmp regular_winner_two
	
ACE_two:

	Set_Cursor(2, 1)
	Display_char(#' ')
	Set_Cursor(2, 2)
	Display_char(#' ')
	Set_Cursor(2, 3)
	Display_char(#' ')
	Set_Cursor(2, 4)
	Display_char(#' ')
	Set_Cursor(2, 5)
	Display_char(#' ')
	Set_Cursor(2, 6)
	Display_char(#' ')
	Set_Cursor(2, 7)
	Display_char(#' ')
	Set_Cursor(2, 8)
	Display_char(#' ')
	Set_Cursor(2, 9)
	Display_char(#' ')
	Set_Cursor(2, 10)
	Display_char(#' ')
	Set_Cursor(2, 11)
	Display_char(#' ')
	Set_Cursor(2, 12)
	Display_char(#' ')
	Set_Cursor(2, 13)
	Display_char(#' ')
	Set_Cursor(2, 14)
	Display_char(#' ')
	Set_Cursor(2, 15)
	Display_char(#' ')
	Set_Cursor(2, 16)
	Display_char(#' ')
	
	Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#' ')
	Set_Cursor(1, 7)
	Display_char(#'A')
	Set_Cursor(1, 8)
	Display_char(#'C')
	Set_Cursor(1, 9)
	Display_char(#'E')
	Set_Cursor(1, 10)
	Display_char(#'!')
	Set_Cursor(1, 11)
	Display_char(#' ')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	; HALO Soundtrack
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Fs)
	mov RL0, #low(TIMER0_RELOAD_Fs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_A)
	mov RL0, #low(TIMER0_RELOAD_A)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Cs)
	mov RL0, #low(TIMER0_RELOAD_Cs)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_B)
	mov RL0, #low(TIMER0_RELOAD_B)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#200)
	
	ljmp ACE_two
	
regular_winner_two:
	
	Set_Cursor(2, 1)
	Display_char(#' ')
	Set_Cursor(2, 2)
	Display_char(#' ')
	Set_Cursor(2, 3)
	Display_char(#' ')
	Set_Cursor(2, 4)
	Display_char(#' ')
	Set_Cursor(2, 5)
	Display_char(#' ')
	Set_Cursor(2, 6)
	Display_char(#' ')
	Set_Cursor(2, 7)
	Display_char(#' ')
	Set_Cursor(2, 8)
	Display_char(#' ')
	Set_Cursor(2, 9)
	Display_char(#' ')
	Set_Cursor(2, 10)
	Display_char(#' ')
	Set_Cursor(2, 11)
	Display_char(#' ')
	Set_Cursor(2, 12)
	Display_char(#' ')
	Set_Cursor(2, 13)
	Display_char(#' ')
	Set_Cursor(2, 14)
	Display_char(#' ')
	Set_Cursor(2, 15)
	Display_char(#' ')
	Set_Cursor(2, 16)
	Display_char(#' ')
	
	Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#'W')
	Set_Cursor(1, 7)
	Display_char(#'I')
	Set_Cursor(1, 8)
	Display_char(#'N')
	Set_Cursor(1, 9)
	Display_char(#'N')
	Set_Cursor(1, 10)
	Display_char(#'E')
	Set_Cursor(1, 11)
	Display_char(#'R')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	; Victory Sound

	clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#10)
	
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#10)
	
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	
	Wait_Milli_Seconds(#10)
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_Bf)
	mov RL0, #low(TIMER0_RELOAD_Bf)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_C)
	mov RL0, #low(TIMER0_RELOAD_C)
	setb TR0

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#210)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_DH)
	mov RL0, #low(TIMER0_RELOAD_DH)
	setb TR0
	

	Wait_Milli_Seconds(#200)
	Wait_Milli_Seconds(#100)
	
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_C)
	mov RL0, #low(TIMER0_RELOAD_C)
	setb TR0

	Wait_Milli_Seconds(#150)


	clr TR0
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	lcall WaitHalfSec
	lcall WaitHalfSec
	
	ljmp winner_two

ask_prompt:
	
	; "WANNA"
	Set_Cursor(1, 1)
	Display_char(#'W')
	Set_Cursor(1, 2)
	Display_char(#'A')
	Set_Cursor(1, 3)
	Display_char(#'N')
	Set_Cursor(1, 4)
	Display_char(#'N')
	Set_Cursor(1, 5)
	Display_char(#'A')
	Set_Cursor(1, 6)
	Display_char(#' ')
	
	; "PLAY?"
	Set_Cursor(1, 7)
	Display_char(#'P')
	Set_Cursor(1, 8)
	Display_char(#'L')
	Set_Cursor(1, 9)
	Display_char(#'A')
	Set_Cursor(1, 10)
	Display_char(#'Y')
	Set_Cursor(1, 11)
	Display_char(#'?')
	
	; "YES"
	Set_Cursor(2, 1)
	Display_char(#'Y')
	Set_Cursor(2, 2)
	Display_char(#'E')
	Set_Cursor(2, 3)
	Display_char(#'S')
	
	; "NO"
	Set_Cursor(2, 6)
	Display_char(#'N')
	Set_Cursor(2, 7)
	Display_char(#'O')
	
cursor_no:
	
	jb NO_CURSOR, cursor_yes ; if not pressed, goes to branch below
	Wait_Milli_Seconds(#50) ; Debounce delay.  This macro is also in 'LCD_4bit.inc'
	jb NO_CURSOR, cursor_yes ; if not pressed, goes to branch below
	jnb NO_CURSOR, $ ; Wait for button release.  The '$' means: jump to same instruction.
	Set_Cursor(2,4)
	Display_char(#' ')
	Set_Cursor(2,8)
	Display_char(#'<')
	mov R5, #0x00
	
	
cursor_yes:
	
	jb YES_CURSOR, choose_select ; if not pressed, goes to branch below
	Wait_Milli_Seconds(#50) ; Debounce delay.  This macro is also in 'LCD_4bit.inc'
	jb YES_CURSOR, choose_select ; if not pressed, goes to branch below
	jnb NO_CURSOR, $ ; Wait for button release.  The '$' means: jump to same instruction.
	Set_Cursor(2,4)
	Display_char(#'<')
	Set_Cursor(2,8)
	Display_char(#' ')
	mov R5, #0x01
	
choose_select:
	
	jb SELECT, cursor_no_x ; if not pressed, goes to branch below
	Wait_Milli_Seconds(#50) ; Debounce delay.  This macro is also in 'LCD_4bit.inc'
	jb SELECT, cursor_no_x ; if not pressed, goes to branch below
	jnb SELECT, $ ; Wait for button release.  The '$' means: jump to same instruction.
	cjne R5, #0x01, goodbye_message ; if equal to one, continues to forever
	ljmp forever
	
cursor_no_x:
	ljmp cursor_no
	
goodbye_message:

	Set_Cursor(1, 1)
	Display_char(#' ')
	Set_Cursor(1, 2)
	Display_char(#' ')
	Set_Cursor(1, 3)
	Display_char(#' ')
	Set_Cursor(1, 4)
	Display_char(#' ')
	Set_Cursor(1, 5)
	Display_char(#' ')
	Set_Cursor(1, 6)
	Display_char(#' ')
	Set_Cursor(1, 7)
	Display_char(#' ')
	Set_Cursor(1, 8)
	Display_char(#' ')
	Set_Cursor(1, 9)
	Display_char(#' ')
	Set_Cursor(1, 10)
	Display_char(#' ')
	Set_Cursor(1, 11)
	Display_char(#' ')
	Set_Cursor(1, 12)
	Display_char(#' ')
	Set_Cursor(1, 13)
	Display_char(#' ')
	Set_Cursor(1, 14)
	Display_char(#' ')
	Set_Cursor(1, 15)
	Display_char(#' ')
	Set_Cursor(1, 16)
	Display_char(#' ')
	
	Set_Cursor(2, 1)
	Display_char(#' ')
	Set_Cursor(2, 2)
	Display_char(#' ')
	Set_Cursor(2, 3)
	Display_char(#' ')
	Set_Cursor(2, 4)
	Display_char(#'C')
	Set_Cursor(2, 5)
	Display_char(#'Y')
	Set_Cursor(2, 6)
	Display_char(#'A')
	Set_Cursor(2, 7)
	Display_char(#' ')
	Set_Cursor(2, 8)
	Display_char(#'L')
	Set_Cursor(2, 9)
	Display_char(#'A')
	Set_Cursor(2, 10)
	Display_char(#'T')
	Set_Cursor(2, 11)
	Display_char(#'E')
	Set_Cursor(2, 12)
	Display_char(#'R')
	Set_Cursor(2, 13)
	Display_char(#'!')
	Set_Cursor(2, 14)
	Display_char(#' ')
	Set_Cursor(2, 15)
	Display_char(#' ')
	Set_Cursor(2, 16)
	Display_char(#' ')
	
	; Mario Death Sound

	clr TR0
	mov RH0, #high(TIMER0_RELOAD_GL)
	mov RL0, #low(TIMER0_RELOAD_GL)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#50)
	mov RH0, #high(TIMER0_RELOAD_F)
	mov RL0, #low(TIMER0_RELOAD_F)
	setb TR0
	
	Wait_Milli_Seconds(#100)
	
	clr TR0
	Wait_Milli_Seconds(#150)
	mov RH0, #high(TIMER0_RELOAD_F)
	mov RL0, #low(TIMER0_RELOAD_F)
	setb TR0
	
	Wait_Milli_Seconds(#100)
	
	clr TR0
	Wait_Milli_Seconds(#100)
	mov RH0, #high(TIMER0_RELOAD_F)
	mov RL0, #low(TIMER0_RELOAD_F)
	setb TR0
	
	Wait_Milli_Seconds(#200)
	
	clr TR0
	Wait_Milli_Seconds(#50)
	mov RH0, #high(TIMER0_RELOAD_E)
	mov RL0, #low(TIMER0_RELOAD_E)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#50)
	mov RH0, #high(TIMER0_RELOAD_D)
	mov RL0, #low(TIMER0_RELOAD_D)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	clr TR0
	Wait_Milli_Seconds(#50)
	mov RH0, #high(TIMER0_RELOAD_C)
	mov RL0, #low(TIMER0_RELOAD_C)
	setb TR0
	
	Wait_Milli_Seconds(#100)
	
	clr TR0
	Wait_Milli_Seconds(#100)
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#100)
	
	clr TR0
	Wait_Milli_Seconds(#150)
	mov RH0, #high(TIMER0_RELOAD_EL)
	mov RL0, #low(TIMER0_RELOAD_EL)
	setb TR0
	
	Wait_Milli_Seconds(#100)
	
	clr TR0
	Wait_Milli_Seconds(#100)
	mov RH0, #high(TIMER0_RELOAD_CL)
	mov RL0, #low(TIMER0_RELOAD_CL)
	setb TR0
	
	Wait_Milli_Seconds(#150)
	
	ljmp goodbye_message

forever:

	; "PLAYER ONE->"
	Set_Cursor(1, 1)
	Display_char(#'P')
	Set_Cursor(1, 2)
	Display_char(#'L')
	Set_Cursor(1, 3)
	Display_char(#'A')
	Set_Cursor(1, 4)
	Display_char(#'Y')
	Set_Cursor(1, 5)
	Display_char(#'E')
	Set_Cursor(1, 6)
	Display_char(#'R')
	Set_Cursor(1, 7)
	Display_char(#' ')
	Set_Cursor(1, 8)
	Display_char(#'O')
	Set_Cursor(1, 9)
	Display_char(#'N')
	Set_Cursor(1, 10)
	Display_char(#'E')
	Set_Cursor(1, 11)
	Display_char(#'-')
	Set_Cursor(1, 12)
	Display_char(#'>')
	
	; "PLAYER TWO->"
	Set_Cursor(2, 1)
	Display_char(#'P')
	Set_Cursor(2, 2)
	Display_char(#'L')
	Set_Cursor(2, 3)
	Display_char(#'A')
	Set_Cursor(2, 4)
	Display_char(#'Y')
	Set_Cursor(2, 5)
	Display_char(#'E')
	Set_Cursor(2, 6)
	Display_char(#'R')
	Set_Cursor(2, 7)
	Display_char(#' ')
	Set_Cursor(2, 8)
	Display_char(#'T')
	Set_Cursor(2, 9)
	Display_char(#'W')
	Set_Cursor(2, 10)
	Display_char(#'O')
	Set_Cursor(2, 11)
	Display_char(#'-')
	Set_Cursor(2, 12)
	Display_char(#'>')
	
	
	
comeback2RNG:

	cpl P0.6
	
	; random # every random # of secs --> decides high/low ---> point up/down
	lcall Wait_Random ; random amount of time
	
	lcall Random
	mov a, Seed+1
	mov c, acc.3
	mov HLbit, c ; 0 ... 1 ........ 0 .... 1
	
	; if (HLbit == 1) { branch where high freq }
	; if (HLbit == 0) { branch where low freq }
	
	mov a, HLbit
	da a
	mov R2, a ; R2 has converted value of HLbit
	
	cjne R2, #0x00, Freq_High ; if it is 0, continues down to play low frequency

Freq_Low:
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_LOW)
	mov RL0, #low(TIMER0_RELOAD_LOW)
	setb TR0
	ljmp scoringB ; now needs to check for decrementing score
	
Freq_High:
	clr TR0
	mov RH0, #high(TIMER0_RELOAD_HIGH)
	mov RL0, #low(TIMER0_RELOAD_HIGH)
	setb TR0
	ljmp scoringA ; now needs to check for incrementing score
	
	
	
	;mov a, HLbit
	;da a
	;Set_Cursor(1, 11)
	;Display_BCD(a)
	
	
    ;cpl TR0
    ;cpl SOUND_OUT
    
    ; check flag to jump to scoring
    
    ;cjne R2, #0x00, scoring
 
;Sound_low:
   
    ;lcall Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    
    ;lcall Timer0_Init_LOW
    ;setb TR0 ; turns low frequency on
    
    ;ljmp scoring
    
    ;lcall Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    
    ;clr TR0 ; tturns low frequency off
    
    
    ; branch to scoring code
    
;Next_sound:
	
	;mov R5, #0x00
	
	;lcall Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    
    ;clr TR0 ; tturns low frequency off
    
    ;lcall Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    ;lcall Wait_Random
    
    ;lcall Timer0_Init_HIGH
    ;setb TR0
    ;ljmp scoringB

;scoring:
	
	; check loop value to see if we continue with checking score with this sound
	
	; if (R5 >= 99){ Go to Next_sound }
	
	;mov R2, #0x01 ; set scoring flag to skip sound_low

	;cjne R5, #0x99, keep_on_going
	;mov R2, #0x00
	;ljmp Next_Sound
	
;scoringB:

	
	
;keep_on_going:

	; increment loop value
	;mov a, R5
    ;add a, #0x01
    ;da a
    ;mov R5, a
    
scoringB:

	cjne R7, #0x99, skip_jump_RNGB ; if equal to 99, goes back to RNG
	ljmp comeback2RNG
	
skip_jump_RNGB:

	mov a, R7
	add a, #0x01
	da a
	mov R7, a
    
	; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2

synch1_minus:
	;jb TF2, no_signal ; If the timer overflows, we assume there is no signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x_minus
    jb P0.0, synch1_minus
    
    ;if not jb, need to avoid no_signal_x --> needs to jump to synch2
    jnb TF2, synch2_minus
    ;jnb P0.0, synch2
    
no_signal_x_minus:
	ljmp no_signal
	
synch2_minus:    
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x_minus
    jnb P0.0, synch2_minus
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1_minus:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x_minus
    jb P0.0, measure1_minus
measure2_minus:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"    
	jb TF2, no_signal_x_minus
    jnb P0.0, measure2_minus
    clr TR2 ; Stop timer 2, [TH2,TL2] * 45.21123ns is the period

	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, #0
	mov x+3, #0
	; Make sure [TH2,TL2]!=0
	mov a, TL2
	orl a, TH2
	;jz no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jz no_signal_x_minus
	
	Load_y(45211) ; One clock pulse is 1/22.1148 MHz = 45.21123ns
	lcall mul32
	
	Load_y(1000)
	lcall div32
	
	;WE NOW HAVE PERIOD
	
	;______________________________________________________________________________________________________________
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(2, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
    
    ;if period reaches above a certain value, goes to this branch
	
	Load_y(210000)
	lcall x_gteq_y 
	jb mf, point_minus1 
	jnb mf, continue_from_no_press_minus

point_minus1:

	; check if a point has been added already
	cjne R4, #0x00, do_not_add_point_minus ; player 2 has come first
	
    cjne R0, #0x00, do_not_add_point_minus ; if score is 0, continues down
    clr a
    mov a, test
    add a, #0x99 ; maybe subtracts
    da a
    mov test, a
    cjne a, #0x99, keep_her_going_minus1
    mov test, #0x00

keep_her_going_minus1:

	;mov a, test
	
    ;cjne a, #0x00, keep_her_going_minus1x ; if equal to 0, then flag is 1
    ;mov test_zero_flag, #0x01
    
;keep_her_going_minus1x:    
    
    ;Set_Cursor(2, 14)
    ;Display_BCD(test)
    
    mov R0, #0x01 ; added point flag
    
    mov R3, #0x01 ; Player1 came first flag
    
    
    ljmp continue_minus
    
do_not_add_point_minus:
	
	ljmp continue_minus
	
continue_from_no_press_minus:
	mov R3, #0x00 ; Player first flag reset
	mov R0, #0x00 ; added point flag (reset after player has lifted hand)
	ljmp continue_minus

continue_minus:
	
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(2, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
	
	Set_Cursor(2, 14)
    Display_BCD(test)
    
    
	ljmp forever_B_minus
	
	

forever_B_minus:

	;lcall Random
	;mov a, Seed+1
	;mov c, acc.3
	;mov HLbit, c
	;mov a, HLbit
	;da a
	;Set_Cursor(1, 5)
	;lcall Wait_Random
	
	
	;Display_BCD(a)
	
	
    ;cpl TR0
    ;cpl SOUND_OUT

    ; synchronize with rising edge of the signal applied to pin P0.0
    ;clr TR2 ; Stop timer 2
    ;mov TL2, #0
    ;mov TH2, #0
    ;clr TF2
    ;setb TR2
synch1B_minus:
	;jb TF2, no_signal ; If the timer overflows, we assume there is no signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB_minus
    jb P0.1, synch1B_minus
    
    ;if not jb, need to avoid no_signal_x --> needs to jump to synch2
    jnb TF2, synch2B_minus
    ;jnb P0.0, synch2
    
no_signal_xB_minus:
	ljmp no_signal
	
synch2B_minus:    
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB_minus
    jnb P0.1, synch2B_minus
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1B_minus:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB_minus
    jb P0.1, measure1B_minus
measure2B_minus:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"    
	jb TF2, no_signal_xB_minus
    jnb P0.1, measure2B_minus
    clr TR2 ; Stop timer 2, [TH2,TL2] * 45.21123ns is the period

	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, #0
	mov x+3, #0
	; Make sure [TH2,TL2]!=0
	mov a, TL2
	orl a, TH2
	;jz no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jz no_signal_xB_minus
	
	Load_y(45211) ; One clock pulse is 1/22.1148 MHz = 45.21123ns
	lcall mul32
	
	Load_y(1000)
	lcall div32
	
	;WE NOW HAVE PERIOD
	
	;______________________________________________________________________________________________________________
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(1, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
    
    ;if period reaches above a certain value, goes to this branch
	
	Load_y(210000)
	lcall x_gteq_y
	jb mf, point_minus1B 
	jnb mf, continue_from_no_pressB_minus 
		

	
point_minus1B:

	; check if a point has been added already
	
	cjne R3, #0x00, do_not_add_pointB_minus ; if score is 0, continues down
	
    cjne R1, #0x00, do_not_add_pointB_minus ; if score is 0, continues down
    clr a
    mov a, testb
    ;cjne a, #0x00, move_on_minus1B ; testb is 0, then flag is 1
    ;mov testb_zero_flag, #0x01
;move_on_minus1B:
    add a, #0x99
    da a
    mov testb, a
    cjne a, #0x99, keep_her_going_minus1B
    mov testb, #0x00

keep_her_going_minus1B:

	;mov a, testb
	
    ;cjne a, #0x00, keep_her_going_minus1Bx ; if equal to 0, then flag is 1
    ;mov testb_zero_flag, #0x01
    
;keep_her_going_minus1Bx: 
    
    ;Set_Cursor(2, 14)
    ;Display_BCD(test)
    
    mov R1, #0x01 ; added point flag
    
    mov R4, #0x01 ; player2 first flag
    ljmp continueB_minus
    
do_not_add_pointB_minus:
	
	ljmp continueB_minus
	
continue_from_no_pressB_minus:
	
	mov R4, #0x00 ; Player2 first flag reset
	mov R1, #0x00 ; added point flag (reset after player has lifted hand)
	
	ljmp continueB_minus

continueB_minus:
	
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(1, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
	
	Set_Cursor(1, 14)
    Display_BCD(testb)
    
    
    ljmp forever ; Repeat!
    
scoringA:

	cjne R6, #0x99, skip_jump_RNGA ; if equal to 99, goes back to RNG
	ljmp comeback2RNG
	
skip_jump_RNGA:

	mov a, R6
	add a, #0x01
	da a
	mov R6, a
    
	; synchronize with rising edge of the signal applied to pin P0.0
    clr TR2 ; Stop timer 2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2

synch1:
	;jb TF2, no_signal ; If the timer overflows, we assume there is no signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x
    jb P0.0, synch1
    
    ;if not jb, need to avoid no_signal_x --> needs to jump to synch2
    jnb TF2, synch2
    ;jnb P0.0, synch2
    
no_signal_x:
	ljmp no_signal
	
synch2:    
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x
    jnb P0.0, synch2
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_x
    jb P0.0, measure1
measure2:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"    
	jb TF2, no_signal_x
    jnb P0.0, measure2
    clr TR2 ; Stop timer 2, [TH2,TL2] * 45.21123ns is the period

	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, #0
	mov x+3, #0
	; Make sure [TH2,TL2]!=0
	mov a, TL2
	orl a, TH2
	;jz no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jz no_signal_x
	
	Load_y(45211) ; One clock pulse is 1/22.1148 MHz = 45.21123ns
	lcall mul32
	
	Load_y(1000)
	lcall div32
	
	;WE NOW HAVE PERIOD
	
	;______________________________________________________________________________________________________________
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(2, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
    
    ;if period reaches above a certain value, goes to this branch
	
	Load_y(210000)
	lcall x_gteq_y
	jb mf, point_plus1 
	jnb mf, continue_from_no_press




point_plus1:

	; check if a point has been added already
	cjne R4, #0x00, do_not_add_point ; player 2 has come first
	
    cjne R0, #0x00, do_not_add_point ; if score is 0, continues down
    clr a
    mov a, test
    add a, #0x01
    da a
    mov test, a
    ;mov test_zero_flag, #0x00 ; flag is set back to 0 since test is no longer 0
    cjne a, #0x05, keep_her_going1
    ljmp winner_one

keep_her_going1:

	;cjne a, #0x00, keep_her_going1x ; if equal to 0, then flag is 1
    ;mov test_zero_flag, #0x01

;keep_her_going1x: 
    
    ;Set_Cursor(2, 14)
    ;Display_BCD(test)
    
    mov R0, #0x01 ; added point flag
    
    mov R3, #0x01 ; Player1 came first flag
    
    
    ljmp continue
    
do_not_add_point:
	
	ljmp continue
	
continue_from_no_press:
	mov R3, #0x00 ; Player first flag reset
	mov R0, #0x00 ; added point flag (reset after player has lifted hand)
	ljmp continue

continue:
	
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(2, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
	
	Set_Cursor(2, 14)
    Display_BCD(test)
    
    
	ljmp forever_B
	
	

forever_B:

	;lcall Random
	;mov a, Seed+1
	;mov c, acc.3
	;mov HLbit, c
	;mov a, HLbit
	;da a
	;Set_Cursor(1, 5)
	;lcall Wait_Random
	
	
	;Display_BCD(a)
	
	
    ;cpl TR0
    ;cpl SOUND_OUT

    ; synchronize with rising edge of the signal applied to pin P0.0
    ;clr TR2 ; Stop timer 2
    ;mov TL2, #0
    ;mov TH2, #0
    ;clr TF2
    ;setb TR2
synch1B:
	;jb TF2, no_signal ; If the timer overflows, we assume there is no signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB
    jb P0.1, synch1B
    
    ;if not jb, need to avoid no_signal_x --> needs to jump to synch2
    jnb TF2, synch2B
    ;jnb P0.0, synch2
    
no_signal_xB:
	ljmp no_signal
	
synch2B:    
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB
    jnb P0.1, synch2B
    
    ; Measure the period of the signal applied to pin P0.0
    clr TR2
    mov TL2, #0
    mov TH2, #0
    clr TF2
    setb TR2 ; Start timer 2
measure1B:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jb TF2, no_signal_xB
    jb P0.1, measure1B
measure2B:
	;jb TF2, no_signal
	;need to use intermediate branch to avoid "Relative Offest"    
	jb TF2, no_signal_xB
    jnb P0.1, measure2B
    clr TR2 ; Stop timer 2, [TH2,TL2] * 45.21123ns is the period

	; Using integer math, convert the period to frequency:
	mov x+0, TL2
	mov x+1, TH2
	mov x+2, #0
	mov x+3, #0
	; Make sure [TH2,TL2]!=0
	mov a, TL2
	orl a, TH2
	;jz no_signal
	;need to use intermediate branch to avoid "Relative Offest"
	jz no_signal_xB
	
	Load_y(45211) ; One clock pulse is 1/22.1148 MHz = 45.21123ns
	lcall mul32
	
	Load_y(1000)
	lcall div32
	
	;WE NOW HAVE PERIOD
	
	;______________________________________________________________________________________________________________
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(1, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
    
    ;if period reaches above a certain value, goes to this branch
	
	Load_y(210000)
	lcall x_gteq_y
	jb mf, point_plus1B 
	jnb mf, continue_from_no_pressB 
		

	
point_plus1B:

	; check if a point has been added already
	
	cjne R3, #0x00, do_not_add_pointB ; if score is 0, continues down
	
    cjne R1, #0x00, do_not_add_pointB ; if score is 0, continues down
    clr a
    mov a, testb
    add a, #0x01
    da a
    mov testb, a
    ;mov testb_zero_flag, #0x00 ; flag is set back to 0 since testb is no longer 0
    cjne a, #0x05, keep_her_going1B
    ljmp winner_two

keep_her_going1B:

	;cjne a, #0x00, keep_her_going1Bx ; if equal to 0, then flag is 1
    ;mov testb_zero_flag, #0x01

;keep_her_going1Bx:  
    
    ;Set_Cursor(2, 14)
    ;Display_BCD(test)
    
    mov R1, #0x01 ; added point flag
    
    mov R4, #0x01 ; player2 first flag

    ljmp continueB
    
do_not_add_pointB:
	
	ljmp continueB
	
continue_from_no_pressB:
	
	mov R4, #0x00 ; Player2 first flag reset
	mov R1, #0x00 ; added point flag (reset after player has lifted hand)
	
	ljmp continueB

continueB:
	
	
	; Convert the result to BCD and display on LCD
	;Set_Cursor(1, 1)
	;lcall hex2bcd
	;lcall Display_10_digit_BCD	
	
	Set_Cursor(1, 14)
    Display_BCD(testb)
    
    
    ljmp forever ; Repeat! 
    
no_signal:	
	Set_Cursor(2, 1)
    Send_Constant_String(#No_Signal_Str)
    ljmp forever ; Repeat! 

end

