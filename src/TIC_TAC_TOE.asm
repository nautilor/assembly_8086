; *****************************
; * TIC TAC TOE * FreedomSka  *
; *****************************
; *                           *
; *           *   *           *
; *           *   *           *
; *           *   *           *
; *        ***********        *
; *           *   *           *
; *           *   *           *
; *           *   *           *
; *        ***********        *
; *           *   *           *
; *           *   *           *
; *           *   *           *
; *                           *
; *****************************


include 'emu8086.inc'

ORG 100H

.DATA

BOARD_GAME DW 10, 13,
           DW '   *   *   ', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '***********', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '***********', 10, 13,
           DW '   *   *   ', 10, 13,
           DW '   *   *   ', 10, 13
           DW '   *   *   $'

GAME DB 9 DUP(0), "$" ; TO CHECK WHO WIN AT THE END

; VAR FOR GAME STATE
; 0 START
; 1 INPUT
; 2 CHECK WIN
GAME_STATE DB 1 DUP(0)

; VAR FOR TURN
; 58H = 'X'
; 04F = 'O' 
PLAYER_TURN DB 1 DUP(58H)

GAME_COUNTER DB 1 DUP(0)

MSG1 DB 10, 13, 10, 13, "INSERT A NUMBER: $"
MSG_ERROR1_X_CORD DB 1 DUP(0)
MSG_ERROR1 DB 10, 13, "NUMBER ALREADY TAKEN...$"
MSG_ERROR_CLEAR DB 10, 13, "                                   $"
MSG_TURN DB 10, 13, 10, 13, "TURN: $"
WIN_X DB 10, 13, "PLAYER X WIN$"
WIN_O DB 10, 13, "PLAYER O WIN$"
NO_WIN DB 10, 13, "NO WINNER$"
 



 
.CODE

; SET TO GAME ARRAY 1 2 3 4 5 6 7 8  
CALL INITIALIZE_ARRAY
INITIALIZE_DONE:

MOV AH, 09H
MOV DX, OFFSET BOARD_GAME
INT 21H

MOV GAME_STATE, 1 ; SET GAME_STATE TO INPUT

; START INPUT OF 'X' OR 'O'
MOV AH, 09H
MOV DX, OFFSET MSG1
INT 21H 
MOV AH, 09H
MOV DX, OFFSET MSG_TURN
INT 21H
PRINT_NUMBER 7 15 PLAYER_TURN 7

START_ASKING_NUMBER:
PRINT_NUMBER 2 2 GAME[0] 7
PRINT_NUMBER 6 2 GAME[1] 7
PRINT_NUMBER 10 2 GAME[2] 7
PRINT_NUMBER 2 6 GAME[3] 7
PRINT_NUMBER 6 6 GAME[4] 7
PRINT_NUMBER 10 6 GAME[5] 7
PRINT_NUMBER 2 10 GAME[6] 7
PRINT_NUMBER 6 10 GAME[7] 7
PRINT_NUMBER 10 10 GAME[8] 7
ASK_AGAIN:
MOV MSG_ERROR1_X_CORD, 0
PRINT_NUMBER 18 13 20H 7
PRINT_NUMBER 18 13 08H 7

MOV AH, 01H
INT 21H

; CHECK FOR NUMBER INPUT
CMP AL, 31H ; 1
    JB ASK_AGAIN
    CMP AL, 40H ;9
        JA ASK_AGAIN 
SUB AL, 48
MOV AH, 0
MOV DI, AX
DEC DI

; CHECK IF IS ALREADY TAKEN
CMP GAME[DI], 58H ; X
        JE TAKEN
        CMP GAME[DI], 04FH ; O
        JE TAKEN 

; IF IS NOT TAKEN MOVE 'X' OR 'O' TO ARRAY
CMP PLAYER_TURN, 58H ; X
    JE INSERT_X
    ; INSERT OF 'O' TO ARRAY
    ADD GAME_COUNTER, 1
    MOV GAME[DI], 04FH
    MOV PLAYER_TURN, 'X'
    MOV AH, 09H
    MOV DX, OFFSET MSG_ERROR_CLEAR
    INT 21H
    PRINT_NUMBER 7 15 PLAYER_TURN 7
    JMP CHECK_WIN
 
; INSERT OF 'X' TO ARRAY   
INSERT_X:
ADD GAME_COUNTER, 1
MOV GAME[DI], 58H 
MOV PLAYER_TURN, 'O'
MOV AH, 09H
MOV DX, OFFSET MSG_ERROR_CLEAR
INT 21H 
PRINT_NUMBER 7 15 PLAYER_TURN 7
JMP CHECK_WIN

; ERROR IF ALREADY TAKEN
TAKEN:
MOV SI, 0
LEA SI, MSG_ERROR1
PRINT_ERROR:
CMP [SI], 24H
    JE ASK_AGAIN
    
PRINT_NUMBER MSG_ERROR1_X_CORD 14 [SI] 12
INC MSG_ERROR1_X_CORD    
INC SI
JMP PRINT_ERROR


RET
; ********
; * PROC *
; ********


INITIALIZE_ARRAY PROC    
    MOV CL, 48
    SET:
    INC CL
    CMP CL, 58
        JE INITIALIZE_DONE
    MOV GAME[DI], CL
    DEC CL
    INC DI
    INC CL
    JMP SET  
ENDP

; *********
; * MACRO *
; *********

                            
PRINT_NUMBER MACRO X Y ARGV COL
; SET CURSOR POSITION AT DL, DH
MOV DL, X
MOV DH, Y
MOV AH, 02h
INT 10h

; SET COLOR ATTRIBUTES
MOV BL, COL

; PRINT CHAR ON POSITION
MOV AL, ARGV
MOV BH, 0       ; MUST BE 0 TO WORK
MOV CX, 1       ; NUMBER OF CHAR PER TIME
MOV AH, 09h
INT 10h            
ENDM




CHECK_WIN:

FIRST_SLOT_CONTINUE_HORIZONTAL_X:               ; CHECK FOR LINE 1 2 3 'X'
    CMP GAME[0], 'X'
        JE FIRST_SLOT_CONTINUE_HORIZONTAL_1_X
        JNE FIRST_SLOT_CONTINUE_HORIZONTAL_O
FIRST_SLOT_CONTINUE_HORIZONTAL_1_X:
    CMP GAME[1], 'X'
        JE FIRST_SLOT_CONTINUE_HORIZONTAL_2_X
        JNE FIRST_SLOT_CONTINUE_VERTICAL_X
FIRST_SLOT_CONTINUE_HORIZONTAL_2_X:
    CMP GAME[2], 'X'
        JE X_WIN
        JNE FIRST_SLOT_CONTINUE_VERTICAL_X
                    
FIRST_SLOT_CONTINUE_VERTICAL_X:                 ; CHECK FOR LINE 1 4 7 'X' 
    CMP GAME[3], 'X'
        JE FIRST_SLOT_CONTINUE_VERTICAL_1_X    
        JNE FIRST_SLOT_CONTINUE_DIAGONAL_X 
FIRST_SLOT_CONTINUE_VERTICAL_1_X:
    CMP GAME[6], 'X'
        JE X_WIN 
        JNE FIRST_SLOT_CONTINUE_DIAGONAL_X

FIRST_SLOT_CONTINUE_DIAGONAL_X:                 ; CHECK FOR LINE 1 5 9 'X'        
    CMP GAME[4], 'X'
        JE FIRST_SLOT_CONTINUE_DIAGONAL_1_X
        JNE SKIP_CHECK_FIRST_SLOT
         
FIRST_SLOT_CONTINUE_DIAGONAL_1_X:
    CMP GAME[8], 'X'
        JE X_WIN
        JNE SKIP_CHECK_FIRST_SLOT

                                       
FIRST_SLOT_CONTINUE_HORIZONTAL_O:               ; CHECK FOR LINE 1 2 3 'O'
    CMP GAME[0], 'O'
        JE FIRST_SLOT_CONTINUE_HORIZONTAL_1_O
        JNE SKIP_CHECK_FIRST_SLOT
FIRST_SLOT_CONTINUE_HORIZONTAL_1_O:
    CMP GAME[1], 'O'
        JE FIRST_SLOT_CONTINUE_HORIZONTAL_2_O
        JNE FIRST_SLOT_CONTINUE_VERTICAL_O
FIRST_SLOT_CONTINUE_HORIZONTAL_2_O:
    CMP GAME[2], 'O'
        JE O_WIN
        JNE FIRST_SLOT_CONTINUE_VERTICAL_O
                    
FIRST_SLOT_CONTINUE_VERTICAL_O:                 ; CHECK FOR LINE 1 4 7 'O'
    CMP GAME[3], 'O'
        JE FIRST_SLOT_CONTINUE_VERTICAL_1_O    
        JNE FIRST_SLOT_CONTINUE_DIAGONAL_O 
FIRST_SLOT_CONTINUE_VERTICAL_1_O:
    CMP GAME[6], 'O'
        JE O_WIN
        JNE FIRST_SLOT_CONTINUE_DIAGONAL_O
FIRST_SLOT_CONTINUE_DIAGONAL_O:                 ; CHECK FOR LINE 1 5 9 'O'        
    CMP GAME[4], 'O'
        JE FIRST_SLOT_CONTINUE_DIAGONAL_1_O
        JNE SKIP_CHECK_FIRST_SLOT
         
FIRST_SLOT_CONTINUE_DIAGONAL_1_O:
    CMP GAME[8], 'O'
        JE O_WIN
        JNE SKIP_CHECK_FIRST_SLOT

SKIP_CHECK_FIRST_SLOT:

SECOND_SLOT_CONTINUE_VERTICAL_X:                 ; CHECK FOR LINE 2 5 8 'X'
    CMP GAME[1], 'X'
        JE SECOND_SLOT_CONTINUE_VERTICAL_1_X
        JNE SECOND_SLOT_CONTINUE_VERTICAL_O

SECOND_SLOT_CONTINUE_VERTICAL_1_X:
    CMP GAME[4], 'X'
        JE SECOND_SLOT_CONTINUE_VERTICAL_2_X
        JNE SKIP_CHECK_SECOND_SLOT
        
SECOND_SLOT_CONTINUE_VERTICAL_2_X:
    CMP GAME[7], 'X'
        JE X_WIN
        JNE SKIP_CHECK_SECOND_SLOT

SECOND_SLOT_CONTINUE_VERTICAL_O:                 ; CHECK FOR LINE 2 5 8 'O'
    CMP GAME[1], 'O'
        JE SECOND_SLOT_CONTINUE_VERTICAL_1_O
        JNE SKIP_CHECK_SECOND_SLOT

SECOND_SLOT_CONTINUE_VERTICAL_1_O:
    CMP GAME[4], 'O'
        JE SECOND_SLOT_CONTINUE_VERTICAL_2_O
        JNE SKIP_CHECK_SECOND_SLOT
        
SECOND_SLOT_CONTINUE_VERTICAL_2_O:
    CMP GAME[7], 'O'
        JE O_WIN
        JNE SKIP_CHECK_SECOND_SLOT
SKIP_CHECK_SECOND_SLOT:

THIRD_SLOT_CONTINUE_VERTICAL_X:                  ; CHECK FOR LINE 3 6 9 'X'
    CMP GAME[2], 'X'
        JE THIRD_SLOT_CONTINUE_VERTICAL_1_X
        JNE THIRD_SLOT_CONTINUE_VERTICAL_O
        
THIRD_SLOT_CONTINUE_VERTICAL_1_X:
    CMP GAME[5], 'X'
        JE THIRD_SLOT_CONTINUE_VERTICAL_2_X
        JNE THIRD_SLOT_CONTINUE_DIAGONAL_X
        
THIRD_SLOT_CONTINUE_VERTICAL_2_X:
    CMP GAME[8], 'X'
        JE X_WIN
        JNE THIRD_SLOT_CONTINUE_DIAGONAL_X
        
THIRD_SLOT_CONTINUE_DIAGONAL_X:                  ; CHECK FOR LINE 3 5 7 'X'
    CMP GAME[4], 'X'
        JE THIRD_SLOT_CONTINUE_DIAGONAL_1_X
        JNE SKIP_CHECK_THIRD_SLOT

THIRD_SLOT_CONTINUE_DIAGONAL_1_X:
    CMP GAME[6], 'X'
        JE X_WIN
        JNE SKIP_CHECK_THIRD_SLOT 

THIRD_SLOT_CONTINUE_VERTICAL_O:                  ; CHECK FOR LINE 3 6 9 'O'
    CMP GAME[2], 'O'
        JE THIRD_SLOT_CONTINUE_VERTICAL_1_O
        JNE SKIP_CHECK_THIRD_SLOT
        
THIRD_SLOT_CONTINUE_VERTICAL_1_O:
    CMP GAME[5], 'O'
        JE THIRD_SLOT_CONTINUE_VERTICAL_2_O
        JNE THIRD_SLOT_CONTINUE_DIAGONAL_O
        
THIRD_SLOT_CONTINUE_VERTICAL_2_O:
    CMP GAME[8], 'O'
        JE O_WIN
        JNE THIRD_SLOT_CONTINUE_DIAGONAL_O
        
THIRD_SLOT_CONTINUE_DIAGONAL_O:                  ; CHECK FOR LINE 3 5 7 'O'
    CMP GAME[4], 'O'
        JE THIRD_SLOT_CONTINUE_DIAGONAL_1_O
        JNE SKIP_CHECK_THIRD_SLOT

THIRD_SLOT_CONTINUE_DIAGONAL_1_O:
    CMP GAME[6], 'O'
        JE O_WIN
        JNE SKIP_CHECK_THIRD_SLOT 

SKIP_CHECK_THIRD_SLOT:


FOURTH_SLOT_HORIZONTAL_X:                        ; CHECK FOR LINE 4 5 6 'X'
    CMP GAME[3], 'X'
        JE FOURTH_SLOT_HORIZONTAL_1_X
        JNE FOURTH_SLOT_HORIZONTAL_O
        
FOURTH_SLOT_HORIZONTAL_1_X:
    CMP GAME[4], 'X'
        JE FOURTH_SLOT_HORIZONTAL_2_X
        JNE SKIP_CHECK_FOURTH_SLOT
        
FOURTH_SLOT_HORIZONTAL_2_X:
    CMP GAME[5], 'X'
        JE X_WIN
        JNE SKIP_CHECK_FOURTH_SLOT

FOURTH_SLOT_HORIZONTAL_O:                        ; CHECK FOR LINE 4 5 6 'O'
    CMP GAME[3], 'O'
        JE FOURTH_SLOT_HORIZONTAL_1_O
        JNE SKIP_CHECK_FOURTH_SLOT
        
FOURTH_SLOT_HORIZONTAL_1_O:
    CMP GAME[4], 'O'
        JE FOURTH_SLOT_HORIZONTAL_2_O
        JNE SKIP_CHECK_FOURTH_SLOT
        
FOURTH_SLOT_HORIZONTAL_2_O:
    CMP GAME[5], 'O'
        JE O_WIN
        JNE SKIP_CHECK_FOURTH_SLOT            

SKIP_CHECK_FOURTH_SLOT:
; FIFTH SLOT AND SIXTH SLOT CAN BE SKIPPED SINCE WE ALREADY CHECK ALL THEIR CASE  

SEVENTH_SLOT_HORIZONTAL_X:                        ; CHECK FOR LINE 7 8 9 'X'
    CMP GAME[6], 'X'
        JE SEVENTH_SLOT_HORIZONTAL_1_X
        JNE SEVENTH_SLOT_HORIZONTAL_O
          
SEVENTH_SLOT_HORIZONTAL_1_X:
    CMP GAME[7], 'X'
        JE SEVENTH_SLOT_HORIZONTAL_2_X
        JNE SKIP_CHECK_SEVENTH_SLOT
        
SEVENTH_SLOT_HORIZONTAL_2_X:
    CMP GAME[8], 'X'
        JE X_WIN
        JNE SKIP_CHECK_SEVENTH_SLOT 

SEVENTH_SLOT_HORIZONTAL_O:                        ; CHECK FOR LINE 7 8 9 'O'
    CMP GAME[6], 'O'
        JE SEVENTH_SLOT_HORIZONTAL_1_O
        JNE SKIP_CHECK_SEVENTH_SLOT
          
SEVENTH_SLOT_HORIZONTAL_1_O:
    CMP GAME[7], 'O'
        JE SEVENTH_SLOT_HORIZONTAL_2_O
        JNE SKIP_CHECK_SEVENTH_SLOT
        
SEVENTH_SLOT_HORIZONTAL_2_O:
    CMP GAME[8], 'O'
        JE O_WIN
        JNE SKIP_CHECK_SEVENTH_SLOT 

SKIP_CHECK_SEVENTH_SLOT:

; EIGHTH AND NINTH SLOT CAN BE SKIPPED SINCE WE ALREADY CHECK ALL THEIR CASE

; CHECK FOR FULL BOARD
CHECK_FULL:
MOV DI, 8                               ; MOVE 8 TO COUNTER
START_CHECK:                            ; START_CHECK
    CMP GAME[DI], 58H                   ; COMPARE GAME[DI] WITH 'X' (58H)
        JE CONTINUE                     ; IF EQUALS CONTINUE TO CHECK
            CMP GAME[DI], 04FH          ; IF NOT COMPARE WITH 'O' 04FH)
                JE CONTINUE             ; IF EQUALS CONTINUE TO CHECK
                JMP START_ASKING_NUMBER ; ELSE REASK CAUSE NOT FULL BOARD
CONTINUE:
    DEC DI                              ; DEC THE COUNTER FOR NEXT COMPARE
    CMP DI, -1                          ; COMPARE DI WITH -1
        JE TIE                          ; IF EQUALS IT MEANS THAT THE BOARD IS COMPLETED
        JMP START_CHECK                 ; ELSE CONTINUE TO CHECK

X_WIN:
CALL CLEAR_SCREEN
MOV AH, 09H
MOV DX, OFFSET WIN_X
INT 21H
JMP END_GAME


O_WIN:
CALL CLEAR_SCREEN
MOV AH, 09H
MOV DX, OFFSET WIN_O
INT 21H
JMP END_GAME

TIE:
CALL CLEAR_SCREEN
MOV AH, 09H
MOV DX, OFFSET NO_WIN
INT 21H
JMP END_GAME 

END_GAME:
DEFINE_CLEAR_SCREEN
END