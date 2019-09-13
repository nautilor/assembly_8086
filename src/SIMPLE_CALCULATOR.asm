; ******************************** 
; * 8086 CALCULATOR * nautilor *
; *************************************************************************************
; * TO FIX:                                                                           *
; *      - CANNOT INPUT NEGATIVE NUMBERS AND NUMBER > 65536                           *
; ************************************************************************************* 
; * USAGE: N1 '+/*-' N2 (ENTER)                                                       *
; *************************************************************************************


ORG 100H

.DATA
CHECK_SUB DB 1 DUP(0)
FIRST_NUMBER_ARRAY DB 125 DUP(0)
SECOND_NUMBER_ARRAY DB 125 DUP(0)
FIRST_NUMBER DW 1 DUP(0)
SECOND_NUMBER DW 1 DUP(0)
MATH_SYMBOL DB 1 DUP(0)
CNT_FIRST DW 1  DUP(0)
CNT_SECOND DW 1 DUP(0)
FINAL_RESULT DW 0 , "$"
REAL_NUMBER DB 125 DUP(0)
UNSIGNED_STRING DB 10, 13, 10, 13, "UNSIGNED RESULT: $"
SIGNED_STRING DB 10, 13, 10, 13, "SIGNED RESULT: $"
SIGNED_NUMBER_ARRAY DB 7 DUP(0)
UNSIGNED_NUMBER_ARRAY DB 7 DUP(0)
;WIP_PRINT DB 10, 13, "PRINT IS NOT WORKING FOR NOW, CHECK THE VAR 'FINAL RESULT'$"
DIV_ZERO DB 10, 13, "MATH ERROR: DIVIDE BY ZERO$"
WIP_RESULT DB 10, 13, "PRINT MATH ERROR: RESULT TOO BIG", 10, 13, "CHECK VARIABLES FOR RESULT$"
WIP_NUMBER DB 10, 13, "MATH OVERFLOW ERROR: NUMBER TOO BIG$"
.CODE 
JMP START 
DO_BACKSPACE:
CMP BL, 1                               ; CHECK IF SECOND NUMBER
    JE CHECK_SECOND_NUMBER_DEL           ; IF EQUAL
    JNE DELETE_FIRST_NUMBER             ; IF NOT DELETE LAST DIGIT OF FIRST NUMBER

CHECK_SECOND_NUMBER_DEL:
CMP SECOND_NUMBER_ARRAY[0], 0
    JE CHECK_MATH_SYMBOL_DEL 
; DELETE LAST DIGIT OF SECOND NUMBER
DEC DI
DEC CNT_SECOND
MOV SECOND_NUMBER_ARRAY[DI], 0          ; ELSE DELETE LAST DIGIT OF SECOND NUMBER
JMP SEND_BACKSPACE_DEL                  ; SEND BACKSPACE
    
CHECK_MATH_SYMBOL_DEL:
CMP MATH_SYMBOL, 0                      ; COMPARE MATH_SYMBOL WITH 0
    JNE DELETE_MATH_SYMBOL              ; IF EQUAL START DELETING MATH SYMBOL


; DELETE MATH SYMBOL 
DELETE_MATH_SYMBOL:
MOV BL, 0
MOV DI, CNT_FIRST 
MOV MATH_SYMBOL, 0                      ; DELETE MATH SYMBOL FROM VAR
JMP SEND_BACKSPACE_DEL                  ; DELETE MATH SYMBOL GRAPHICAL    

; DELETE LAST DIGIT OF FIRST NUMBER
DELETE_FIRST_NUMBER:
DEC DI
DEC CNT_FIRST
MOV FIRST_NUMBER_ARRAY[DI], 0           ; DELETE LAST DIGIT OF FIRST NUMBER
JMP SEND_BACKSPACE_DEL                  ; SEND BACKSPACE

SEND_BACKSPACE_DEL:
PUSH AX
PUSH DX
MOV AH, 02H
MOV DL, 20H                             ; SEND A SPACE TO DELETE THE OLD CHAR (20H)
INT 21H
MOV DL, 08H                             ; SEND A BACKSPACE (08H)
INT 21H
POP AX
POP DX    
JMP NEXT    


START:
MOV DI, 0 ; SET ARRAY COUNTER TO 0
MOV BL, 0 ; SET COUNTER FOR SECOND INPUT TO 0
NEXT:


MOV AH, 01H  ; TAKING INPUT
INT 21H      ; TAKING INPUT

CMP AL, 08H
    JE DO_BACKSPACE

CMP AL, 0DH         ; CHECK IF ENTER
    JE END_INPUT    ; END IF ENTER

; CHECK IF IS A NUMBER OR * / - +
CMP AL, 30H                    ; CHECK IF IS LESS THAN 0 (30H)
        JB CHECK_MATH          ; IF IS LESS THAN 0 THEN CHECK IF IS A MATH SYMBOL
        CMP AL, 39H            ; CHECK IF IS GREATER THAN 9 (39H)
            JA SEND_BACKSPACE  ; IF IS GREATER THAN 9 DELETE AND RE-ASK
            JMP INPUT_NUMBER
                 
; CHECK IF IS * / - +
CHECK_MATH:
CMP AL, 2AH                     ; CHECK IF IS * (2A)
    JE INPUT_MATH
    CMP AL, 2BH                 ; CHECK IF IS + (2B)
        JE INPUT_MATH
        CMP AL, 2DH             ; CHECK IF IS - (2D)
            JE INPUT_MATH
            CMP AL, 2FH         ; CHECK IF IS / (2F)
            JE INPUT_MATH
            JNE SEND_BACKSPACE ; IF IS NOT A MATH SYMBOL DELETE AND RE-ASK
; FINISH CHECK IF IS A NUMBER OR * / - +

; SEND A BACKSPACE AND RE-ASK WHEN YOU DON'T INPUT A NUMBER OR * / - +            
SEND_BACKSPACE:
MOV AH, 02H
MOV DL, 08H ; SEND A BACKSPACE (08H)
INT 21H 
MOV DL, 20H ; SEND A SPACE TO DELETE THE OLD CHAR (20H)
INT 21H
MOV DL, 08H ; SEND A BACKSPACE (08H)
INT 21H
JMP NEXT 


; ADDING THE NUMBER TO THE ARRAY
INPUT_NUMBER:
SUB AL, 48
; CHECK IF IS THE FIRST INPUT OR NOT
CMP BL, 1 ; IF BL 1 WE HAVE THE SECOND INPUT 
       JE SECOND 
        MOV FIRST_NUMBER_ARRAY[DI], AL ; MOVE ALL THE INPUT IN THE ARRAY
        ADD CNT_FIRST, 1               ; ADD 1 TO FIRST INPUT COUNTER
        ADD DI, 1
        JMP NEXT
        
; SECOND INPUT OF NUMBER        
SECOND:  
    MOV SECOND_NUMBER_ARRAY[DI], AL    ; MOVE ALL THE INPUT IN THE ARRAY
    ADD CNT_SECOND, 1                  ; ADD 1 TO SECOND INPUT COUNTER
    ADD DI, 1
    JMP NEXT 

; ADDING THE MATH SYMBOL TO THE MATH_SYMBOL VAR
INPUT_MATH:
CMP BL, 1
    JE SEND_BACKSPACE
ADD BL, 1
MOV DI, 0     
MOV MATH_SYMBOL, AL
JMP NEXT  
END_INPUT:
; CHECK FOR OVERFLOW NUMBER
;CMP FIRST_NUMBER_ARRAY[3], 0    ; CHECK IF NUMBER LENGHT > 4
;        JE CHECK_SECOND         ; IF NOT CHECK SECOND NUMBER
;        JMP NUMBER_ERROR        ; ELSE DISPLAY ERROR
        
;CHECK_SECOND:
;CMP SECOND_NUMBER_ARRAY[3], 0   ; CHECK IF NUMBER LENGHT > 4
;        JE NUMBER_OK            ; IF NOT CONTINUE
;        JMP NUMBER_ERROR        ; ELSE DISPLAY ERROR
             
; ERROR NUMBER TOO BIG           
;NUMBER_ERROR:
;MOV AH, 09H
;MOV DX, OFFSET WIP_NUMBER
;INT 21H
;RET

;NUMBER_OK: 
;CREATING FIRST NUMBER
MOV CX, 1           ; FOR MULTIPLIER.. (EX 100 OR 10)
MOV BX, 10          ; THE ONE THAT MULTIPLY
MOV DI, CNT_FIRST   ; COUNTER OF FIRST NUMBER 
DEC DI              ; CAUSE WE ATART FROM 0 ON THE ARRAY
; GENERATING THE MULTIPLIER  EX: 1000 / 100 / 10 AND THE NUMBER ITSELF
FIRST_NUMBER_C:
MOV AX, 0                                   ; RESET AX (AL AND AH)
MOV AX, WORD PTR FIRST_NUMBER_ARRAY[DI]     ; MOV 8BIT VALUE OF VAR IN 16BIT REGISTER
MOV AH, 0                                   ; RESET AH CAUSE THE PREVIOUS COMMAND MOVE VAL IN AL AND AH
MUL CX                                      ; MUL THE MULTIPLIER TO NUMBER
JO PRINT_OVERFLOW_ERROR                     ; CHECK FOR OVERFLOW
ADD FIRST_NUMBER, AX                        ; ADD RESULT TO FIRST_NUMBER
XCHG AX, CX                                 ; CHANGE AX WITH BX
MUL BX                                      ; MUL BY 10 
XCHG AX, CX                                 ; CHANGE AX WITH BX
DEC DI                                      ; DEC THE ARRAY COUNTER
CMP DI, -1                                  ; COMPARE DI WITH -1
    JE START_SECOND_NUMBER_C                ; IF IS EQUAL THE NUMBER IS FINISHED
    JMP FIRST_NUMBER_C                      ; ELSE CONTINUE
    
;CREATING SECOND NUMBER
START_SECOND_NUMBER_C:
MOV CX, 1           ; FOR MULTIPLIER.. (EX 100 OR 10)
MOV BX, 10          ; THE ONE THAT MULTIPLY
MOV DI, CNT_SECOND  ; COUNTER OF FIRST NUMBER
DEC DI
; GENERATING THE MULTIPLIER  EX: 1000 / 100 / 10 AND THE NUMBER ITSELF
SECOND_NUMBER_C:
MOV AX, 0                                   ; RESET AX (AL AND AH)
MOV AX, WORD PTR SECOND_NUMBER_ARRAY[DI]    ; MOV 8BIT VALUE OF VAR IN 16BIT REGISTER
MOV AH, 0                                   ; RESET AH CAUSE THE PREVIOUS COMMAND MOVE VAL IN AL AND AH
MUL CX                                      ; MUL THE MULTIPLIER TO NUMBER
JO PRINT_OVERFLOW_ERROR                     ; CHECK FOR OVERLFOW
ADD SECOND_NUMBER, AX                       ; ADD RESULT TO FIRST_NUMBER
XCHG AX, CX                                 ; CHANGE AX WITH BX
MUL BX                                      ; MUL BY 10 
XCHG AX, CX                                 ; CHANGE AX WITH BX
DEC DI                                      ; DEC THE ARRAY COUNTER
CMP DI, -1                                  ; COMPARE DI WITH -1
    JE FINISH_C                             ; IF IS EQUAL THE NUMBER IS FINISHED
    JMP SECOND_NUMBER_C                     ; ESLE CONTINUE

FINISH_C:

;MATH CALCS
; CHECK FOR MATH SYMBOL
MOV DX, 0 ; SET DX TO 0 FOR NEXT CALC
MOV AL, MATH_SYMBOL
CMP AL, 2AH                     ; CHECK IF IS * (2A)
    JE DO_MUL
    CMP AL, 2BH                 ; CHECK IF IS + (2B)
        JE DO_SUM
        CMP AL, 2DH             ; CHECK IF IS - (2D)
            JE DO_SUB
            CMP AL, 2FH         ; CHECK IF IS / (2F)
            JE DO_DIV
            RET


; SUM CALC
DO_SUM:
    ADD DX, FIRST_NUMBER        ; ADD FIRST_NUMBER TO DX (0)
    ADD DX, SECOND_NUMBER       ; ADD SECOND_NUMBER
    MOV FINAL_RESULT, DX        ; MOVE THE RESULT IN FINAL_RESULT
    CMP FIRST_NUMBER, DX        ; COMPARE FIRST_NUMBER WITH RESULT    
        JA PRINT_OVERFLOW_ERROR ; IF GREATER PRINT OVERFLOW ERROR
    CMP SECOND_NUMBER, DX       ; ELSE COMPARE WITH SECOND
        JA PRINT_OVERFLOW_ERROR ; IF GREATER PRINT OVERFLOW ERROR
    JMP PRINT_RESULT            ; JUMP TO PRINT 

; MUL CALC    
DO_MUL:
    ADD DX, FIRST_NUMBER        ; ADD FIRST_NUMBER TO DX (0)
    MOV AX, DX                  ; MOVE DX TO AX FOR MUL
    MOV DX, 0                   ; RESET DX
    ADD DX, SECOND_NUMBER       ; ADD SECOND_NUMBER TO DX (0)
    MUL DX                      ; MUL DX (DL) WITH AX (AL)
    MOV FINAL_RESULT, AX        ; MOVE THE RESULT IN FINAL_RESULT
    CMP FIRST_NUMBER, AX        ; COMPARE FIRST_NUMBER WITH RESULT    
        JA PRINT_OVERFLOW_ERROR ; IF GREATER PRINT OVERFLOW ERROR
    CMP SECOND_NUMBER, AX       ; ELSE COMPARE WITH SECOND
        JA PRINT_OVERFLOW_ERROR ; IF GREATER PRINT OVERFLOW ERROR
    JMP PRINT_RESULT            ; JUMP TO PRINT

; SUB CALC
; IF SECOND NUMBER IF GTR THAN SECOND DO SECOND - FIRST AND PRINT A MINUS
DO_SUB:                 
    ADD DX, FIRST_NUMBER    ; ADD FIRST_NUMBER TO DX (0)
    CMP SECOND_NUMBER, DX   ; CMP SECOND NUMBER WITH DX (FIRST_NUMBER)
        JA  DO_SECOND_FIRST ; IF GREATER
    SUB DX, SECOND_NUMBER   ; SUB SECOND NUMBER
    JMP SUB_DONE
DO_SECOND_FIRST:
INC CHECK_SUB
XOR DX, DX
ADD DX, SECOND_NUMBER
SUB DX, FIRST_NUMBER
SUB_DONE:
    MOV FINAL_RESULT, DX    ; MOVE THE RESULT IN FINAL_RESULT
    JMP PRINT_RESULT        ; JUMP TO PRINT

; DIV CALC <--TO CHECK-->
DO_DIV:
    ; CHECK DIV BY 0
    CMP SECOND_NUMBER, 0        ; CHECK SECOND NUMBER
    JE ZERO_DIV                 ; IF SECOND NUMBER IS 0 IT'S A DIV BY 0 SO PRINT ERROR
        ADD BX, FIRST_NUMBER    ; ELSE ADD FIRST_NUMBER TO BX (0)
        MOV AX, BX              ; MOVE FROM BX TO AX
        MOV BX, 0               ; RESET BX
        ADD BX, SECOND_NUMBER   ; ADD SECOND NUMBER TO BX (0)
        DIV BX                  ; DIV AX BY BX
        MOV FINAL_RESULT, AX    ; MOVE THE RESULT IN FINAL_RESULT
        ;SUB FINAL_RESULT, 2     ; SUB CAUSE IT ADD RANDOM +2 RO RESULT    
        JMP PRINT_RESULT        ; JUMP TO PRINT

; DIV BY 0 ERROR
ZERO_DIV:
    MOV AH, 09H
    MOV DX, OFFSET DIV_ZERO
    INT 21H
    RET    

; PRINT THE RESUL
; TO PRINT THE RESULT JUST DIVIDE BY 10 AND WHEN IT RETURN 'N / 10 = 0' STOP   
PRINT_RESULT:
; CHECK NUMBER PRINT OVERFLOW
;CMP FINAL_RESULT, 9C4H   ; CHECK RESULT
;    JG RESULT_TOO_BIG    ; IF IS BIGGER THAN 9C4H (2500) PRINT ERROR
;    JMP PRINT_OK         ; ELSE CONTINUE
    
;PRINT ERROR
;RESULT_TOO_BIG:
;MOV AH, 09H
;MOV DX, OFFSET WIP_RESULT
;INT 21H
;RET

PRINT_OK:
CMP CHECK_SUB, 1                ; CMP CHECK_SUB WITH 1
    JE FINAL_DESTRUCTION        ; REVERSE ALL THE PRINT 
    JMP REGULAR_PRINT 
    
FINAL_DESTRUCTION:
MOV AX, FINAL_RESULT            ; MOVE RESULT IN AX
PUSH AX                         ; MOVE AX TO STACK 
; PRINTING UNSIGNED VALUE DES
MOV AH, 09H
MOV DX, OFFSET SIGNED_STRING
INT 21H                         ; MOVE AX TO STACK
MOV AH, 02H                     ; PRINT MINUS SIGN
MOV DL, 2DH                     ; 45 = 2DH = '-'
INT 21H                            ; PRINT
POP AX                          ; GET VALUE FROM THE STACK
PUSH AX                         ; MOVE AX TO STACK
MOV BX, 10                      ; NUMBER FOR DIV
MOV DI, 1 
; GETTING UNSIGNED VALUE DES
NEXT_UNS_DES:
XOR DX, DX                              ; RESET DX TO 0
DIV BX                                  ; DIV BY 10
MOV UNSIGNED_NUMBER_ARRAY[DI], DL       ; GETTING NUMBER
INC DI                                  ; INCREMENT ARRAY COUNTER
CMP AX, 0                               ; CHECK IF 0
    JE START_PRINT_UNS_DEC_DES          ; IF 0 STOP DIV
JMP NEXT_UNS_DES                        ; ELSE CONTINUE 
START_PRINT_UNS_DEC_DES:
DEC DI
START_PRINT_UNS_DES:                    ; START_PRINT
CMP DI, 0                               ; CHECK IF COUNTER IS 0
    JE DO_SIGNED_ONE_DES                ; IF 0 STOP PRINT
MOV AH, 02H                             ; ELSE PRINT
MOV DL, UNSIGNED_NUMBER_ARRAY[DI]       ; MOV NUMBER TO DL TO PRINT 
ADD DL, 48                              ; ADD DL 48 TO GET NUMBER CHAR  
INT 21H                                 ; PRINT   
DEC DI                                  ; INCREMENT COUNTER
JMP START_PRINT_UNS_DES


; GETTING SIGNED VALUE DES
DO_SIGNED_ONE_DES:
MOV AH, 09H
MOV DX, OFFSET UNSIGNED_STRING
INT 21H
MOV AX, FINAL_RESULT
NEG AX                          ; IT'S LIKE AX * -1
;PROCESS NUMBER
MOV BX, 10                      ; MOVE 10 TO BX TO DIVIDE
MOV DI, 1                       ; SET ARRAY COUNTER TO 1
NEXT_SIGN_DES:
XOR DX, DX                      ; RESET DX TO 0
DIV BX                          ; DIV BY 10
MOV SIGNED_NUMBER_ARRAY[DI], DL ; MOV NUMBER TO ARRAY
INC DI                          ; INCREMENT ARRAY COUNTER
CMP AX, 0                       ; CHECK IF AX IS 0
    JE START_PRINT_SIGN_DEC_DES ; IF 0 START PRINT
JMP NEXT_SIGN_DES               ; ELSE REPEAT
START_PRINT_SIGN_DEC_DES:
DEC DI
START_PRINT_SIGN_DES:
CMP DI, 0                               ; CHECK IF COUNTER IS 0
    JE FINISH_PRINT                     ; IF 0 STOP PRINT
MOV AH, 02H                             ; ELSE PRINT
MOV DL, SIGNED_NUMBER_ARRAY[DI]         ; MOV NUMBER TO DL TO PRINT 
ADD DL, 48                              ; ADD DL 48 TO GET NUMBER CHAR  
INT 21H                                 ; PRINT   
DEC DI                                  ; INCREMENT COUNTER
JMP START_PRINT_SIGN_DES
JMP FINISH_PRINT





REGULAR_PRINT:
; CHECK FOR NEGATIVE NUMBER
MOV AX, FINAL_RESULT            ; MOVE RESULT IN AX
PUSH AX                         ; MOVE AX TO STACK 
; PRINTING UNSIGNED VALUE
MOV AH, 09H
MOV DX, OFFSET UNSIGNED_STRING
INT 21H
POP AX                          ; GET VALUE FROM THE STACK
PUSH AX                         ; MOVE AX TO STACK
MOV BX, 10                      ; NUMBER FOR DIV
MOV DI, 1                       ; SET COUNTER TO 1

; GETTING UNSIGNED VALUE
NEXT_UNS:
XOR DX, DX                              ; RESET DX TO 0
DIV BX                                  ; DIV BY 10
MOV UNSIGNED_NUMBER_ARRAY[DI], DL       ; GETTING NUMBER
INC DI                                  ; INCREMENT ARRAY COUNTER
CMP AX, 0                               ; CHECK IF 0
    JE START_PRINT_UNS_DEC              ; IF 0 STOP DIV
JMP NEXT_UNS                            ; ELSE CONTINUE 
START_PRINT_UNS_DEC:
DEC DI
START_PRINT_UNS:                        ; START_PRINT
CMP DI, 0                               ; CHECK IF COUNTER IS 0
    JE DO_SIGNED_ONE                    ; IF 0 STOP PRINT
MOV AH, 02H                             ; ELSE PRINT
MOV DL, UNSIGNED_NUMBER_ARRAY[DI]       ; MOV NUMBER TO DL TO PRINT 
ADD DL, 48                              ; ADD DL 48 TO GET NUMBER CHAR  
INT 21H                                 ; PRINT   
DEC DI                                  ; INCREMENT COUNTER
JMP START_PRINT_UNS


; GETTING SIGNED VALUE
DO_SIGNED_ONE:
MOV AH, 09H
MOV DX, OFFSET SIGNED_STRING
INT 21H
POP AX
CMP AX, 0
    JGE NO_NEGATIVE
    NEG AX                      ; IT'S LIKE AX * -1
    PUSH AX                     ; MOVE AX TO STACK
    MOV AH, 02H                 ; PRINT MINUS SIGN
    MOV DL, 2DH                 ; 45 = 2DH = '-'
    INT 21H                     ; PRINT
    POP AX
;PROCESS NUMBER
NO_NEGATIVE:
MOV BX, 10                      ; MOVE 10 TO BX TO DIVIDE
MOV DI, 1                       ; SET ARRAY COUNTER TO 1
NEXT_SIGN:
XOR DX, DX                      ; RESET DX TO 0
DIV BX                          ; DIV BY 10
MOV SIGNED_NUMBER_ARRAY[DI], DL ; MOV NUMBER TO ARRAY
INC DI                          ; INCREMENT ARRAY COUNTER
CMP AX, 0                       ; CHECK IF AX IS 0
    JE START_PRINT_SIGN_DEC     ; IF 0 START PRINT
JMP NEXT_SIGN                   ; ELSE REPEAT
START_PRINT_SIGN_DEC:
DEC DI
START_PRINT_SIGN:
CMP DI, 0                               ; CHECK IF COUNTER IS 0
    JE FINISH_PRINT                     ; IF 0 STOP PRINT
MOV AH, 02H                             ; ELSE PRINT
MOV DL, SIGNED_NUMBER_ARRAY[DI]         ; MOV NUMBER TO DL TO PRINT 
ADD DL, 48                              ; ADD DL 48 TO GET NUMBER CHAR  
INT 21H                                 ; PRINT   
DEC DI                                  ; INCREMENT COUNTER
JMP START_PRINT_SIGN

PRINT_OVERFLOW_ERROR:
MOV AH, 09H
MOV DX, OFFSET WIP_NUMBER
INT 21H

FINISH_PRINT:
END