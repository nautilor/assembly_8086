ORG 100H

.DATA

STATE DB 1 DUP(2)

;FRUIT[0] = X, FRUIT[1] = Y
FRUIT 2 DUP(0)
SCORE DB 1 DUP(0)
SCORE_TEXT DB "SCORE: $"

.CODE

NEXT:
; FLUSH KEYBOARD BUFFER
MOV AH, 0CH
INT 21H

; CHECK FOR DIRECTION
CMP STATE, 1
    JE UP
        CMP STATE, 2
            JE RIGHT
                CMP STATE, 3
                    JE DOWN
                        CMP STATE, 4
                            JE LEFT 

UP:
    DEC DH
    JMP CONTINUE

RIGHT:
    INC DL
    JMP CONTINUE

DOWN:
    INC DH
    JMP CONTINUE

LEFT:
    DEC DL
    JMP CONTINUE

CONTINUE:

; SET CURSOR POSITION AT DL, DH
MOV AH, 02h
INT 10h

MOV BL, 255
MOV AL, ' '     ; CHAR TO PRINT
MOV BH, 0       ; MUST BE 0 TO WORK
MOV CX, 1       ; NUMBER OF CHAR PER TIME
MOV AH, 09H
INT 10H


; GET INPUT WHILE DOING STUFF
MOV AH, 01H
INT 16H

; SET DIRECTION FROM INPUT
; wasd (NOT WASD)
CMP AL, 119
    JE STATE_1
        CMP AL, 100 
            JE STATE_2
                CMP AL, 115
                    JE STATE_3
                        CMP AL, 97
                            JE STATE_4
                            JMP NEXT
STATE_1:
    MOV STATE, 1
    JMP NEXT

STATE_2:
    MOV STATE, 2
    JMP NEXT
     
STATE_3:
    MOV STATE, 3
    JMP NEXT

STATE_4:
    MOV STATE, 4
    JMP NEXT


JMP NEXT