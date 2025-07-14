GOTO Initialise_Program

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP%
    REM Clear Flags
    REM CALL PLOT kernal routine - $FFF0
    POKE 781,YP% : POKE 782,XP% : POKE 783,0 : SYS 65520
    RETURN

Get_Random_Number:
    REM Get Random Number
    REM Returns RD% - Random Output
    RD% = INT(RND(1) * RD%)
    RETURN

Get_Card_Value:
    REM Get Card Value
    REM Requires CI% - Card Index Value
    REM Returns RA% - Rank Value
    RA% = CI% - (INT(CI% / 13) * 13)
    RETURN

Get_Cart_Suit:
    REM Get Card Suit
    REM Requires CI% - Card Index Value
    REM Returns SU% - Suit Index

    REM 0 - Spades, 0-12
    REM 1 - Diamonds, 13-25
    REM 2 - Clubs, 26-38
    REM 3 - Hearts, 39-51

    SU% = INT(CI% / 13)
    RETURN

Setup_Card_Shuffle_Sound:
    REM Reset Sound Memory
    FOR T = 0 TO 24 : POKE SL + T,0 : NEXT

    REM Set High Pulse Width for Voice 1
    POKE SL + 0,240 : POKE SL + 1,20

    REM Set Attack/Decay for voice 1 (A=4,D=8)
    POKE SL + 5,72

    REM Set High Cut-off frequency for filter
    POKE SL + 22,0

    REM Turn on Voice 1 filter
    POKE SL + 23,1

    REM Set Volume and high pass filter
    POKE SL + 24,79

    RETURN

Setup_Card_Sound:
    REM Set High Pulse Width for Voice 1
    POKE SL + 0,240 : POKE SL + 1,20

    REM Set Attack/Decay for voice 1 (A=4,D=8)
    POKE SL + 5,34

    REM Disable High Cut-off frequency for filter
    POKE SL + 22,0

    REM Turn off Voice 1 filter
    POKE SL + 23,0

    REM Set Volume
    POKE SL + 24,15

    RETURN


Play_Cursor_Positive_Sound:
    REM Play Cursor Positive Sound
    REM Set Frequency
    POKE SL,214 : POKE SL+1,94

    GOSUB Play_Cursor_Sound
    
    RETURN

Play_Cursor_Negative_Sound:
    REM Play Cursor Positive Sound
    REM Set Frequency
    POKE SL,181 : POKE SL+1,23

    GOSUB Play_Cursor_Sound
    
    RETURN

Play_Cursor_Sound:
    REM Set Volume
    POKE SL + 24,15

    REM Start Sound
    POKE SL + 4,33
    
    FOR T = 1 TO 100 : NEXT T
    
    REM Stop Sound
    POKE SL + 4,32
    POKE SL + 24,0

    RETURN

Play_Win_Jingle:
    IF CP% THEN Play_Win_Jingle_Player

Play_Win_Jingle_Computer:
    FOR WJ = 3 TO 0 STEP -1
        POKE SL,WJ%(WJ, 0)
        POKE SL+1,WJ%(WJ, 1)
        GOSUB Play_Cursor_Sound
    NEXT WJ

    RETURN

Play_Win_Jingle_Player:
    FOR WJ = 0 TO 3
        POKE SL,WJ%(WJ, 0)
        POKE SL+1,WJ%(WJ, 1)
        GOSUB Play_Cursor_Sound
    NEXT WJ
    
    RETURN


Shuffle_Deck:
    REM Shuffle Deck
    REM Set Deck Shuffled Flag
    REM This is used to test for a stalemate situation
    SP% = -1

    GOSUB Setup_Card_Shuffle_Sound

    REM Reset Deck
    FOR I = 0 TO 51
        DP%(I) = I
    NEXT I

    FOR I = 0 TO 51
        RD% = 52 - I
        GOSUB Get_Random_Number

        SD%(I) = DP%(RD%) : REM Get card from deck

        IF RD% >= 51 THEN Shuffle_Deck__Continue

        REM Slide cards along one
        FOR J = RD% TO 50
            POKE SL + 4, 129 : REM Start Shuffle Sound
            DP%(J) = DP%(J + 1)

            REM Stop shuffle sound after a delay, depending on modulo
            IF (J AND 7) = 0 THEN POKE SL + 4, 128
        NEXT J

        POKE SL + 4, 128 : REM Stop Shuffle Sound

Shuffle_Deck__Continue:
        XP% = I - (INT(I / 26) * 26) : YP% = 2

        IF I >= 26 THEN YP% = YP% + 2
        GOSUB Set_Cursor_Position

        GOSUB Print_Card_Back
    NEXT I

    POKE SL + 24,0 : REM Disable Sound

    RETURN

Shuffle_Discards:
    REM Shuffle Discard Pile
    GOSUB Update_Shuffling_Message

    REM Set Deck Shuffled Flag
    REM This is used to test for a stalemate situation
    SP% = -1

    GOSUB Setup_Card_Shuffle_Sound

    REM Reset Shuffled Deck
    FOR I = 0 TO 51
        SD%(I) = -1
    NEXT I

    FOR I = 0 TO DI% - 1
        RD% = DI% - I
        GOSUB Get_Random_Number

        SD%(I) = DP%(RD%) : REM Get card from discard pile

        IF RD% >= DI% THEN Shuffle_Discards__Continue
        
        REM Slide cards along one
        FOR J = RD% TO DI% - 1
            POKE SL + 4, 129 : REM Start Shuffle Sound
            DP%(J) = DP%(J + 1)

            REM Stop shuffle sound after a delay, depending on modulo
            IF J - (INT(J / 10) * 10) = 0 THEN POKE SL + 4, 128
        NEXT J

        POKE SL + 4, 128 : REM Stop Shuffle Sound

Shuffle_Discards__Continue:
    NEXT I

    REM Reset Discard Pile
    DP%(0) = DP%(DI%)

    REM I = 1 because we can't include the top discarded card
    FOR I = 1 TO 51
        DP%(I) = -1
    NEXT I

    SI% = DI% : REM Reset Shuffled Deck Index
    DI% = 0 : REM Reset Discard Pile Index (0 because we have one card already)   

    XP% = 35 : YP% = 2 : GOSUB Set_Cursor_Position
    GOSUB Print_Card_Back

    POKE SL + 24,0 : REM Disable Sound

    FOR I = 0 TO 300 : NEXT I : REM Wait

    RETURN

Highlight_Card_Bank_Position:
    REM Highlight Card Bank Position
    REM Requires Highlight Position - HP%
    REM Requires Highlight Mode - HM% -> HM% = 1 Print, 0 - Remove
    REM Uses CP% for Player / Computer calculation
    IF HP% = 10 THEN XP% = 34 : YP% = 1  : GOTO Highlight_Card_Bank_Position__Set_Position
    IF HP% = 11 THEN XP% = 34 : YP% = 10 : GOTO Highlight_Card_Bank_Position__Set_Position

    CO% = HP% - (INT(HP% / 5) * 5) : REM Get the Column Index 
    RO% = INT(HP% / 5) : REM Get the Row Index

    XP% = (CO% * 6) + 2 : REM Convert Column Index into Character position
    YP% = (RO% * 6)     : REM Convert Row Index into screen line

    IF CP% THEN YP% = YP% + 13 : REM Move the screen line into player set

Highlight_Card_Bank_Position__Set_Position:
    GOSUB Set_Cursor_Position    
    
    IF HM% THEN PRINT "{rvs on}{green}{117}   {105}{rvs off}" : GOTO Highlight_Card_Bank_Position__Set_Bottom_Position
    PRINT "{rvs on}{green}     {rvs off}"

Highlight_Card_Bank_Position__Set_Bottom_Position:
    YP% = YP% + 5 : GOSUB Set_Cursor_Position

    IF HM% THEN PRINT "{rvs on}{green}{106}   {107}{rvs off}"; : RETURN
    PRINT "{rvs on}{green}     {rvs off}";
    RETURN

Place_Card_In_Bank:
    REM Place Card In Bank

    REM Reset Deck Shuffled Flag
    REM This is used to test for a stalemate situation
    SP% = 0

    CB% = -1 : REM Card Bank Flag

Place_Card_Dealt_In_Bank:
    REM Place Card Dealt In Bank

    GOSUB Setup_Card_Sound
    POKE SL + 4,129 : REM Start Card Sound

    CO% = RA% - (INT(RA% / 5) * 5) : REM Get the Column Index 
    RO% = INT(RA% / 5) : REM Get the Row Index

    XP% = (CO% * 6) + 3 : REM Convert Column Index into Character position
    YP% = (RO% * 6) + 1 : REM Convert Row Index into screen line

    IF CP% THEN YP% = YP% + 13 : REM Move the screen line into player set

    GOSUB Set_Cursor_Position

    IF CB% THEN GOSUB Print_Current_Card : GOTO Place_Card_In_Bank__Continue
    GOSUB Print_Card_Back

Place_Card_In_Bank__Continue:
    POKE SL + 4,128 : REM Stop Card Sound
    POKE SL + 24,0 : REM Disable Sound

    CB% = 0

    RETURN


Print_Current_Card:
    REM Print Current Card
    GOSUB Get_Card_Value
    GOSUB Get_Cart_Suit

    IF SU% = 0 OR SU% = 2 THEN PRINT "{rvs off}{black}   " : GOTO Print_Current_Card__Rank
    PRINT "{rvs off}{red}   "

Print_Current_Card__Rank:
    REM Print Current Card Rank
    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    If RA% = 0  THEN PRINT " A " : GOTO Print_Current_Card__Suit
    If RA% = 9  THEN PRINT "10 " : GOTO Print_Current_Card__Suit
    If RA% = 10 THEN PRINT " J " : GOTO Print_Current_Card__Suit
    If RA% = 11 THEN PRINT " Q " : GOTO Print_Current_Card__Suit
    If RA% = 12 THEN PRINT " K " : GOTO Print_Current_Card__Suit

    TS$ = STR$(RA% + 1) + " "
    PRINT TS$

Print_Current_Card__Suit:
    REM Print Current Card Suit
    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    IF SU% = 0 THEN PRINT " {97} "  : GOTO Print_Current_Card__Final_Line
    IF SU% = 1 THEN PRINT " {122} " : GOTO Print_Current_Card__Final_Line
    IF SU% = 2 THEN PRINT " {120} " : GOTO Print_Current_Card__Final_Line
    PRINT " {115} "

Print_Current_Card__Final_Line:
    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "   ";

    RETURN

Print_Blank_Card:
    REM Print Blank Card
    REM Requires YP% Set
    XP% = 35 : YP% = YP% - 1
    
    FOR BC = 0 TO 3
        REM Set Cursor Position
        YP% = YP% + 1 : GOSUB Set_Cursor_Position         
        PRINT "{green}{166}{166}{166}"
    NEXT BC

    RETURN

Print_Card_Back:
    REM Print Card Back
    REM Requires XP% and YP% to be set and cursor in position
    PRINT "{rvs on}{blue}{176}{99}{174}{green}{rvs off}";

    YP% = YP% + 1 : GOSUB Set_Cursor_Position
    PRINT "{rvs on}{blue}{125}{166}{125}{green}{rvs off}";

    YP% = YP% + 1 : GOSUB Set_Cursor_Position
    PRINT "{rvs on}{blue}{125}{166}{125}{green}{rvs off}";

    YP% = YP% + 1 : GOSUB Set_Cursor_Position
    PRINT "{rvs on}{blue}{173}{99}{189}{green}{rvs off}";

    RETURN

Update_Shuffling_Message:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{99}{99}{99}{99}{99}             {99}{99}{99}{99}{99}{99}{99}{99}{99}{rvs off}";

    XP% = 12 : YP% = 12 : GOSUB Set_Cursor_Position
    PRINT "{rvs on}{green}SHUFFLING{rvs off}";

    RETURN

Update_Player_Display:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position : REM Set Cursor

    IF NOT CP% THEN Update_Player_Display__Computer

Update_Player_Display__Player:
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{127}{169}{127}{169}  PLAYER  TURN {127}{169}{127}{169}{99}{99}{99}{99}{rvs off}";
    RETURN

Update_Player_Display__Computer:
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{rvs off}{169}{127}{169}{127}{rvs on} COMPUTER TURN {rvs off}{169}{127}{169}{127}{rvs on}{99}{99}{99}{99}{rvs off}";
    RETURN

Update_Player_Display_Player_Win:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{99}{99}{99}{99}  PLAYER  WINS {99}{99}{99}{99}{99}{99}{99}{99}{rvs off}";

    GOSUB Play_Win_Jingle : REM Play Win Jingle

    FOR I = 0 TO 2000 : NEXT I

    PW% = PW% + 1
    CP% = 0 : REM Set Computer turn, so that ready up flips to player
    
    IF PW% = MR% THEN Print_Title_Screen
    GOTO Restart

Update_Player_Display_Computer_Win:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{99}{99}{99}{99} COMPUTER WINS {99}{99}{99}{99}{99}{99}{99}{99}{rvs off}";

    GOSUB Play_Win_Jingle : REM Play Win Jingle

    FOR I = 0 TO 2000 : NEXT I

    CW% = CW% + 1
    CP% = -1 : REM Set player turn, so that ready up flips to computer
    
    IF CW% = MR% THEN Print_Title_Screen
    GOTO Restart

Update_Player_Display_Stalemate:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{rvs on}{green}{171}{99}{99}{99}{99}{99} STALEMATE DETECTED {99}{99}{99}{99}{rvs off}";
    FOR I = 0 TO 2000 : NEXT I
    GOTO Restart


Initialise_Program:
    REM Initialise Program
    VL = 1024  : REM $0400 - First Screen Location
    CR = 55296 : REM $D800 - Colour RAM Base

    SL = 54272 : REM SID Location
    
    REM Reset Sound Memory
    FOR T = 0 TO 24 : POKE SL + T,0 : NEXT

    POKE 649,1 : REM Set Keyboard Buffer size to 1
    POKE 650,64 : REM Disable Key Hold
    
    RA% = 0 : REM Card Rank
    SU% = 0 : REM Card Suit - 0 - Spades, 1 - Diamonds, 2 - Clubs, 3 - Hearts

    DIM SD%(51) : REM Shuffled Card Deck Order
    
    DIM PC%(9) : REM Player Covered Cards
    DIM PU%(9) : REM Player Uncovered Cards    

    DIM CC%(9) : REM Computer Covered Cards
    DIM CU%(9) : REM Computer Uncovered Cards    

    DIM DP%(51) : REM Discard Pile

    DIM WJ%(3,1) : REM Win Lose Jingle Notes

    WJ%(0,0) = 134 : WJ%(0,1) = 35
    WJ%(1,0) = 223 : WJ%(1,1) = 39
    WJ%(2,0) = 193 : WJ%(2,1) = 44
    WJ%(3,0) = 107 : WJ%(3,1) = 47

    MD% = -1    : REM Options Discard Flag
    MW% = -1    : REM Options Wild Card Flag
    MR% = 1     : REM Rounds to declare a win

    RD% = RND(-TI)

    GOTO Print_Title_Screen

Pre_Restart:
    REM Pre-Restart
    PW% = 0     : REM Player Complete Win Score
    CW% = 0     : REM Computer Complete Win Score

    CP% = 0     : REM Current Player - -1 = Computer, 0 = Player

Restart:
    REM Restart
    PS% = 0 + PW%   : REM Player Uncovered Count
    CS% = 0 + CW%   : REM Computer Uncovered Count

    SI% = 52    : REM Shuffled Deck Current Index
    DI% = -1    : REM Discard Pile Current Index

    GOSUB Print_Blank_Screen
    PRINT "{home}{rvs on}Shuffling deck...{rvs off}"
    PRINT

    RD% = RND(-TI) : REM Re-seed the randomiser
    
    GOSUB Shuffle_Deck
    GOSUB Game_Screen

    FOR I = 0 TO 500 : NEXT I : REM Wait

    TD% = CP%   : REM Temp Previous Deal Holder

    REM Deal Cards
    FOR I = 0 TO 9
        IF I > (9 - PW%) THEN Deal_Cards_Omit_Player_Card
        SI% = SI% - 1       : REM Set Next Card Index
        PC%(I) = SD%(SI%)   : REM Allocate to Player
        PU%(I) = 0

        RA% = I
        CP% = -1 : GOSUB Place_Card_Dealt_In_Bank

        FOR J = 0 TO 150 : NEXT J

        GOTO Deal_Cards_Computer

Deal_Cards_Omit_Player_Card:
        PU%(I) = -1

Deal_Cards_Computer:
        IF I > (9 - CW%) THEN Deal_Cards_Omit_Computer_Card
        SI% = SI% - 1       : REM Set Next Card Index
        CC%(I) = SD%(SI%)   : REM Allocate to Computer
        CU%(I) = 0

        RA% = I
        CP% = 0 : GOSUB Place_Card_Dealt_In_Bank

        FOR J = 0 TO 150 : NEXT J

        GOTO Deal_Cards_Continue

Deal_Cards_Omit_Computer_Card:
        CU%(I) = -1

Deal_Cards_Continue:        
    NEXT I

    CP% = TD%   : REM Reset Previous Player

Ready_Up_Next_Player:
    REM Ready Up Next Player
    CP% = NOT CP% : REM Set Next Player
    DA% = 0 : REM Discard Available Flag

    FOR J = 1 TO 1000 : NEXT : REM Wait

    IF SP% = -1 AND SI% <= 0 THEN Update_Player_Display_Stalemate
    IF SI% <= 0 THEN GOSUB Shuffle_Discards

    GOSUB Update_Player_Display

    REM Highlight Card Stack
    HP% = 10 : HM% = -1 : GOSUB Highlight_Card_Bank_Position

    FOR J = 1 TO 300 : NEXT : REM Wait

    REM Check if Discard pile is empty
    IF DI% = -1 AND NOT CP% THEN Draw_Card_From_Card_Stack
    IF DI% = -1 AND CP% THEN Wait_Stack_Key

    REM If Discard Pickup Menu option disabled, skip discard pile check
    IF NOT MD% AND NOT CP% THEN Do_Computer_Turn
    IF NOT MD% AND CP% THEN Wait_Stack_Key

    REM Check rank of discarded card
    CI% = DP%(DI%) : GOSUB Get_Card_Value

    REM Set Discard Pile Available
    REM If the card is A - 10 or Jack, we may be able to claim it
    IF RA% < 11 THEN DA% = -1

    REM If Wild Card Menu option disabled, disable pickup from discard pile
    IF NOT MW% AND RA% = 10 THEN DA% = 0

    IF CP% THEN Do_Player_Turn

Do_Computer_Turn:
    REM Do Computer Turn
    IF NOT DA% THEN Draw_Card_From_Card_Stack

    IF RA% = 10 AND NOT MW% THEN Draw_Card_From_Card_Stack
    IF RA% = 10 THEN Do_Computer_Turn__Skip_Bank_Check

    REM Check Computer Cards - CP% = 0 means computer turn
    IF CU%(RA%) = -1 THEN Draw_Card_From_Card_Stack

Do_Computer_Turn__Skip_Bank_Check:
    REM Otherwise, use the discarded card (continue)
    HP% = 11 : HM% = -1 : GOSUB Highlight_Card_Bank_Position

    FOR J = 1 TO 300 : NEXT : REM Wait

Get_Card_From_Discard_Pile:
    REM Get Card From Discard Pile
    GOSUB Setup_Card_Sound
    POKE SL + 4, 129

    HP% = 10 : HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = 11 : HM% = 0 : GOSUB Highlight_Card_Bank_Position

    DI% = DI% - 1
    IF DI% < 0 THEN DI% = -1 : GOTO Blank_Discard_Pile

    REM Re-print the last card on the discard pile
    CI% = DP%(DI%)

    XP% = 35 : YP% = 11 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    POKE SL + 4,128 : REM Stop Card Sound
    POKE SL + 24,0 : REM Disable Sound

    GOTO Get_Discarded_Card

Blank_Discard_Pile:
    YP% = 11 : GOSUB Print_Blank_Card

Get_Discarded_Card:
    REM Move the discarded card onto the current pile
    CI% = DP%(DI% + 1)

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    HP% = 10 : REM Set Card to Highlight
    HM% = 0 : REM Set Highlight Mode
    GOSUB Highlight_Card_Bank_Position

    HP% = 11 : REM Set Card to Highlight
    HM% = 0 : REM Set Highlight Mode
    GOSUB Highlight_Card_Bank_Position

    FOR J = 1 TO 300 : NEXT : REM Wait

    GOTO Process_Card

Draw_Card_From_Card_Stack:
    REM Draw Card from Card Stack

    GOSUB Setup_Card_Sound
    POKE SL + 4,129 : REM Start Card Sound

    HP% = 10 : HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = 11 : HM% = 0 : GOSUB Highlight_Card_Bank_Position

    SI% = SI% - 1 : REM Set Next Card Index
    CI% = SD%(SI%) : REM Get Next Card

    REM Check and Show Empty Card Stack
    IF SI% > 0 THEN Draw_Card_From_Card_Stack_Continue
    YP% = 2 : GOSUB Print_Blank_Card

Draw_Card_From_Card_Stack_Continue:
    REM Display First Card
    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    POKE SL + 4,128 : REM Stop Card Sound
    POKE SL + 24,0 : REM Disable Sound

    FOR J = 1 TO 300 : NEXT : REM Wait

    IF RA% > 10 AND NOT CP% THEN Discard_Current_Card

Process_Card:
    REM Process Card
    IF NOT CP% THEN Process_Computer_Card

    REM Set Cursor to player discard pile position
    GOSUB Highlight_Discard_Pile

Process_Player_Card:
    REM Process Player Card
    WF% = 0 : REM Reset Wild Flag
    TC% = -1 : REM Reset Temporary Wild Card

    GET K$

    IF HP% = 11 AND K$ = CHR$(13) THEN Discard_Current_Card

    IF HP% < 5 AND (K$ = "S" OR K$ = CHR$(17)) THEN Move_Marker_Down
    IF HP% >= 5 AND HP% < 10 AND (K$ = "W" OR K$ = CHR$(145)) THEN Move_Marker_Up
    IF HP% >= 0 AND HP% < 12 AND (K$ = "D" OR K$ = CHR$(29)) THEN Move_Marker_Right
    IF HP% >= 0 AND HP% < 12 AND (K$ = "A" OR K$ = CHR$(157)) THEN Move_Marker_Left

    IF RA% > 10 AND K$ = CHR$(13) THEN GOSUB Play_Cursor_Negative_Sound
    IF RA% > 10 THEN Process_Player_Card

    IF RA% = 10 AND NOT K$ = CHR$(13) THEN Process_Player_Card
    IF RA% = 10 AND K$ = CHR$(13) THEN Player_Wild_Card_Check : REM Toggle Wild Card Check

    IF HP% = RA% AND RA% < 10 AND PU%(RA%) <> -1 AND K$ = CHR$(13) THEN Place_Player_Card_In_Bank

    REM If key pressed and all other validations failed
    REM play negative sound as an incorrect input
    IF K$ <> "" THEN GOSUB Play_Cursor_Negative_Sound

    GOTO Process_Player_Card


Move_Marker_Down:
    REM Move Marker Down
    HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = HP% + 5 : HM% = -1  : GOSUB Highlight_Card_Bank_Position

    GOSUB Play_Cursor_Positive_Sound
    GOTO Process_Player_Card

Move_Marker_Up:
    REM Move Marker Up
    HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = HP% - 5 : HM% = -1  : GOSUB Highlight_Card_Bank_Position

    GOSUB Play_Cursor_Positive_Sound
    GOTO Process_Player_Card

Move_Marker_Left:
    REM Move Marker Left
    IF HP% <= 0 OR HP% = 5 THEN GOSUB Play_Cursor_Negative_Sound : GOTO Process_Player_Card

    HM% = 0 : GOSUB Highlight_Card_Bank_Position    

    IF HP% = 11 THEN HP% = 5

    HP% = HP% - 1 : HM% = -1  : GOSUB Highlight_Card_Bank_Position

    GOSUB Play_Cursor_Positive_Sound
    GOTO Process_Player_Card

Move_Marker_Right:
    REM Move Marker Right
    IF HP% > 10 THEN GOSUB Play_Cursor_Negative_Sound : GOTO Process_Player_Card

    HM% = 0 : GOSUB Highlight_Card_Bank_Position

    IF HP% = 4 OR HP% >= 9 THEN HP% = 10

    HP% = HP% + 1 : HM% = -1  : GOSUB Highlight_Card_Bank_Position

    GOSUB Play_Cursor_Positive_Sound
    GOTO Process_Player_Card

Player_Wild_Card_Check:
    REM Player Wild Card Check
    REM If Wild Cards Disabled, skip
    IF RA% = 10 AND NOT MW% THEN GOSUB Play_Cursor_Negative_Sound : GOTO Process_Player_Card

    IF RA% = 10 THEN WF% = -1

    IF HP% >= 0 AND HP% < 10 AND PU%(HP%) <> 0 THEN GOSUB Play_Cursor_Negative_Sound: GOTO Process_Player_Card
    RA% = HP% : REM Set card rank equal to current position
    
Place_Player_Card_In_Bank:
    REM Place Player Card in Bank
    YP% = 20 : GOSUB Print_Blank_Card

    IF PU%(RA%) = 0 THEN PU%(RA%) = -1
    IF WF% THEN PU%(RA%) = CI%
    IF NOT WF% = -1 AND PU%(RA%) > -1 THEN TC% = PU%(RA%) : PU%(RA%) = -1

    GOSUB Place_Card_In_Bank

    IF RA% = 10 THEN RA% = HP% : REM Reset card rank

    HP% = RA% : HM% = 0 : GOSUB Highlight_Card_Bank_Position

    REM If card replaces a wild card, reduce the score
    IF TC% > -1 THEN PS% = PS% - 1
    PS% = PS% + 1
    IF PS% >= 10 THEN Update_Player_Display_Player_Win

    CI% = PC%(RA%)
    IF TC% > -1 THEN CI% = TC%

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    REM Re-highlight current card position
    HM% = -1 : GOSUB Highlight_Card_Bank_Position

    GOTO Process_Player_Card

Do_Player_Turn:
    REM Do Player Turn
    IF NOT DA% THEN Wait_Stack_Key

    REM If card has already been turned, draw from the stack
    REM Check Player Cards - CP% = -1 means player turn
    IF PU%(RA%) = -1 THEN DA% = 0

Wait_Stack_Key:
    REM Wait on Stack keypress
    GET K$

    IF DA% AND HP% = 10 AND (K$ = "S" OR K$ = CHR$(17)) THEN GOSUB Highlight_Discard_Pile : GOTO Wait_Stack_Key
    IF DA% AND HP% = 11 AND (K$ = "W" OR K$ = CHR$(145)) THEN GOSUB Highlight_Stack_Pile : GOTO Wait_Stack_Key
    IF K$ = CHR$(13) THEN Process_Stack_Input

    IF K$ = "" THEN Wait_Stack_Key

    IF NOT DA% AND K$ <> CHR$(13) THEN GOSUB Play_Cursor_Negative_Sound
    IF DA% AND HP% = 10 AND K$ <> "S" AND K$ <> CHR$(17) THEN GOSUB Play_Cursor_Negative_Sound
    IF DA% AND HP% = 11 AND K$ <> "W" AND K$ <> CHR$(145) THEN GOSUB Play_Cursor_Negative_Sound

    GOTO Wait_Stack_Key

Highlight_Stack_Pile:
    REM Highlight Stack Pile
    REM Remove Highlight From Card Stack
    HP% = 11 : HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = 10 : HM% = -1 : GOSUB Highlight_Card_Bank_Position
    
    RETURN

Highlight_Discard_Pile:
    REM Highlight Discard Pile
    REM Remove Highlight From Card Stack
    HP% = 10 : HM% = 0 : GOSUB Highlight_Card_Bank_Position
    HP% = 11 : HM% = -1 : GOSUB Highlight_Card_Bank_Position
    
    RETURN


Process_Stack_Input:
    REM Process Stack Input
    IF HP% = 10 THEN Draw_Card_From_Card_Stack
    IF HP% = 11 THEN Get_Card_From_Discard_Pile

    GOTO Process_Player_Card


Process_Computer_Card:
    REM Process Computer Card
    WF% = 0 : REM Reset Wild Flag
    TC% = -1 : REM Reset Temporary Wild Card

    REM Do Wild card game variation check here    
    IF RA% > 10 THEN Discard_Current_Card : REM 10 = Jack
    IF RA% = 10 AND NOT MW% THEN Discard_Current_Card : REM 10 = Jack, Wild Card Disabled
    IF RA% = 10 THEN Process_Computer_Card__After_Bank_Check

    IF CU%(RA%) = -1 THEN Discard_Current_Card

Process_Computer_Card__After_Bank_Check:
    HP% = 10  : HM% = 0  : GOSUB Highlight_Card_Bank_Position
    HP% = 11  : HM% = 0  : GOSUB Highlight_Card_Bank_Position

    REM Replace RA% < 10 with game level
    IF RA% >= 0 AND RA% < 10 THEN Process_Computer_Card__Play_Normal_Card

Process_Computer_Card__Play_Wild_Card:
    WF% = -1 : REM Card picked was a wild card

    REM Pick a random place to play the card
    RD% = 10 : GOSUB Get_Random_Number
    RA% = RD% : REM Set the rank to the randomized number

    REM Check that the space is available and also not already a wild card
    IF CU%(RA%) = 0 THEN Process_Computer_Card__Play_Normal_Card

    GOTO Process_Computer_Card__Play_Wild_Card


Process_Computer_Card__Play_Normal_Card:
    HP% = RA% : HM% = -1 : GOSUB Highlight_Card_Bank_Position

    YP% = 20 : GOSUB Print_Blank_Card

    IF CU%(RA%) = 0 THEN CU%(RA%) = -1
    IF WF% THEN CU%(RA%) = CI%
    IF NOT WF% = -1 AND CU%(RA%) > -1 THEN TC% = CU%(RA%) : CU%(RA%) = -1

    GOSUB Place_Card_In_Bank

    IF RA% = 10 THEN RA% = RD% : REM Reset card rank

    HP% = RA% : HM% = 0 : GOSUB Highlight_Card_Bank_Position

    REM If card replaces a wild card, reduce the score
    IF TC% > -1 THEN CS% = CS% - 1
    CS% = CS% + 1
    IF CS% >= 10 THEN Update_Player_Display_Computer_Win

    CI% = CC%(RA%)
    IF TC% > -1 THEN CI% = TC%

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    GOTO Process_Computer_Card
    

Discard_Current_Card:
    REM Discard Current Card
    GOSUB Setup_Card_Sound
    POKE SL + 4,129 : REM Start Card Sound

    HP% = 11 : HM% = -1 : GOSUB Highlight_Card_Bank_Position

    YP% = 20 : GOSUB Print_Blank_Card

    XP% = 35 : YP% = 11 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    DI% = DI% + 1
    DP%(DI%) = CI%

    HP% = 11 : HM% = 0 : GOSUB Highlight_Card_Bank_Position

    POKE SL + 4,128
    POKE SL + 24,0

    GOTO Ready_Up_Next_Player


Game_Screen:
    REM Print Game screen
    POKE 53280,5 : REM Set border colour to green - $D020

    REM Disable the screen. This way, we can draw to the screen
    REM without the user seeing the characters being drawn.
    POKE 53265,PEEK(53265) AND 239 : REM 0 in bit 4 $D011
    
    POKE 53281,1 : REM Set background colour to white - $D021
    
    REM The whole screen is painted using reversed characters!
    PRINT "{clr}{home}{rvs on}{green}";
    PRINT "                                {180} STACK ";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "C  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {blue}{176}{99}{174}{green}  ";
    PRINT "O  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {blue}{125}{166}{125}{green}  ";
    PRINT "M  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {blue}{125}{166}{125}{green}  ";
    PRINT "P                               {180}  {blue}{173}{99}{189}{green}  ";
    PRINT "U                               {180}       ";
    PRINT "T  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "E  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "R  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}DISCARD";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "                                {180}  {166}{166}{166}  ";
    PRINT "{171}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{180}  {166}{166}{166}  ";
    PRINT "                                {180}  {166}{166}{166}  ";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {166}{166}{166}  ";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "P  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "L  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}       ";
    PRINT "A                               {180}CURRENT";
    PRINT "Y                               {180}       ";
    PRINT "E  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {166}{166}{166}  ";
    PRINT "R  {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {166}{166}{166}  ";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {166}{166}{166}  ";
    PRINT "   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}   {166}{166}{166}  {180}  {166}{166}{166}  ";
    PRINT "                                {180}      {rvs off}";

    REM The PRINT / CHROUT routine will automatically scroll the screen
    REM when the character reaches the bottom-right corner.
    REM We don't want this, so we have to poke the final character
    REM and the colour into Screen and Colour RAM manually
    POKE VL + (40*25) - 1,160 : REM Put a reversed space in the final character positon
    POKE CR + (40*25) - 1,5   : REM Set the character colour to green

    REM Re-enable the screen
    REM The graphics should appear almost instant
    POKE 53265,PEEK(53265) OR 16 : REM 1 in bit 4 $D011

    RETURN

Print_Blank_Screen:
    REM Print Blank Screen
    POKE 53280,5 : REM Set border colour to green - $D020

    REM Disable the screen. This way, we can draw to the screen
    REM without the user seeing the characters being drawn.
    POKE 53265,PEEK(53265) AND 239 : REM 0 in bit 4 $D011
    
    POKE 53281,1 : REM Set background colour to white - $D021
    
    REM The whole screen is painted using reversed characters!
    PRINT "{clr}{home}{rvs on}{green}";

    FOR I = 0 TO 39
        PRINT "                                        ";
    NEXT I

    PRINT "                                       {rvs off}";

    REM The PRINT / CHROUT routine will automatically scroll the screen
    REM when the character reaches the bottom-right corner.
    REM We don't want this, so we have to poke the final character
    REM and the colour into Screen and Colour RAM manually
    POKE VL + (40*25) - 1,160 : REM Put a reversed space in the final character positon
    POKE CR + (40*25) - 1,5   : REM Set the character colour to green

    REM Re-enable the screen
    REM The graphics should appear almost instant
    POKE 53265,PEEK(53265) OR 16 : REM 1 in bit 4 $D011

    RETURN


Print_Title_Screen:
    POKE 53280,5
    POKE 53281,5

    PRINT "{clr}{home}{white}   Unlike other game jam submissions"
    PRINT
    PRINT "              this one is"
    PRINT "{red}"
    PRINT "     {rvs on}{169} {127}{rvs off} {rvs on}  {127}{rvs off} {rvs on}{169} {127}{rvs off} {rvs on}{169} {127}{rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off} {rvs on}   {rvs off} {rvs on}{169}  {rvs off}"
    PRINT "     {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off} {169} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}  {rvs on} {rvs off}  {rvs on} {rvs off}"
    PRINT "     {rvs on}   {rvs off} {rvs on}  {127}{rvs off} {127}{rvs on} {127}{rvs off} {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}  {rvs on} {rvs off}  {rvs on}   {rvs off}"
    PRINT "     {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}  {rvs on} {rvs off}  {rvs on} {rvs off}"
    PRINT "     {rvs on} {rvs off} {rvs on} {rvs off} {rvs on}  {rvs off}{169} {127}{rvs on} {rvs off}{169} {127}{rvs on} {rvs off}{169} {rvs on}   {rvs off} {127}{rvs on} {rvs off}{169}  {rvs on} {rvs off}  {127}{rvs on}  {rvs off}"
    PRINT
    PRINT "{blue}"
    PRINT "     {rvs on}     {rvs off} {rvs on}    {127}{rvs off}  {rvs on}{169} {127}{rvs off}  {rvs on}{169}   {127}{rvs off} {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on}{169}{rvs off}{169} {127}{rvs on}{127}{rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}     {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on}    {rvs off}{169} {rvs on}     {rvs off} {127}{rvs on}   {127}{rvs off} {rvs on}     {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on} {rvs off} {127}{rvs on}{127}{rvs off}  {rvs on} {rvs off}   {rvs on} {rvs off}     {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on} {rvs off}  {127}{rvs on}{127}{rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT "       {rvs on} {rvs off}   {rvs on} {rvs off}   {rvs on} {rvs off} {rvs on} {rvs off}   {rvs on} {rvs off} {127}{rvs on}   {rvs off}{169} {rvs on} {rvs off}   {rvs on} {rvs off}"
    PRINT
    PRINT
    PRINT "{white}  Participated in the {blue}Retro Programmers"
    PRINT "   Inside {white}(RPI) and {yellow}Phaze101 {white}game jam"
    PRINT
    PRINT "     - Press any key to continue -"

Wait_Title_Screen:
    GET K$ : IF K$ = "" THEN Wait_Title_Screen

Print_Options_Screen:
    PRINT "{clr}{home}"
    PRINT "            {blue}Absolute {red}Trash"
    PRINT "            {black}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}"
    PRINT
    PRINT "        {white}A card game for the C64"
    PRINT "     {white}By {brown}Alto{orange}Fluff{white}, May - July 2025"
    PRINT
    PRINT
    PRINT "             {black}Game Options"
    PRINT "             {black}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}"
    PRINT
    PRINT
    GOSUB Print_Options_Screen__Print_Discard
    PRINT
    GOSUB Print_Options_Screen__Print_Wild
    PRINT
    GOSUB Print_Options_Screen__Print_Round_Count
    PRINT
    PRINT
    PRINT
    PRINT "       {white}- Press {rvs on}RETURN{rvs off} to play -"
    PRINT
    PRINT
    PRINT "  {white}I = Instructions      C - Credits"

    GOTO Wait_Options_Screen

Set_Options_Screen__Discard:
    MD% = NOT MD%

Print_Options_Screen__Print_Discard:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position
    IF MD% THEN PRINT "  {white}Discard Pickup    (F1) : {rvs on}YES{rvs off} / NO" : RETURN
    PRINT "  {white}Discard Pickup    (F1) : YES / {rvs on}NO{rvs off}"
    RETURN

Set_Options_Screen__Wild:
    MW% = NOT MW%

Print_Options_Screen__Print_Wild:
    XP% = 0 : YP% = 14 : GOSUB Set_Cursor_Position
    IF MW% THEN PRINT "  {white}Jack as Wild Card (F3) : {rvs on}YES{rvs off} / NO" : RETURN
    PRINT "  {white}Jack as Wild Card (F3) : YES / {rvs on}NO{rvs off}"
    RETURN

Set_Options_Screen__Increase_Round_Count:
    IF MR% < 10 THEN MR% = MR% + 1
    GOTO Print_Options_Screen__Print_Round_Count

Set_Options_Screen__Decrease_Round_Count:
    IF MR% > 1 THEN MR% = MR% - 1
    GOTO Print_Options_Screen__Print_Round_Count

Print_Options_Screen__Print_Round_Count:
    XP% = 0 : YP% = 16 : GOSUB Set_Cursor_Position
    PRINT "  {white}Rounds to Win  (F5/F7) :    "

    XP% = 0 : YP% = 16 : GOSUB Set_Cursor_Position
    PRINT "  {white}Rounds to Win  (F5/F7) :";MR%
    RETURN

Wait_Options_Screen:
    GET K$

    IF K$ = CHR$(133) THEN GOSUB Set_Options_Screen__Discard
    IF K$ = CHR$(134) THEN GOSUB Set_Options_Screen__Wild
    IF K$ = CHR$(135) THEN GOSUB Set_Options_Screen__Increase_Round_Count
    IF K$ = CHR$(136) THEN GOSUB Set_Options_Screen__Decrease_Round_Count

    IF K$ = "I" THEN Print_Instructions
    IF K$ = "C" THEN Print_Credits
    IF K$ = CHR$(13) THEN Pre_Restart

    GOTO Wait_Options_Screen

    
Print_Credits:
    POKE 53281,5
    PRINT "{clr}{home}"
    PRINT " {white}Absolute Trash - Credits"
    PRINT
    PRINT " {black}Special Thanks to:"
    PRINT
    PRINT " {yellow}Phaze101 {white}and {black}Retro Programmers Inside"
    PRINT " {white}({black}RPI{white}) for hosting the game jam."
    PRINT
    PRINT " https://itch.io/jam/cardgame"
    PRINT
    PRINT
    PRINT " {black}John McLeod {white}and {black}https://www.pagat.com"
    PRINT " {white}for hosting and maintaining such a"
    PRINT " wonderful resource online, containing"
    PRINT " the rules to many card games, and for"
    PRINT " making them freely available."
    PRINT
    PRINT " {black}DeadSheppy{white}, for putting up with all my"
    PRINT " ramblings on how this game was made,"
    PRINT " the thought processes into the"
    PRINT " decision making, for helping to test"
    PRINT " the game, and for being supportive all"
    PRINT " the way through the process."
    PRINT
    PRINT "                                - END -";

Wait_Credits:
    GET K$ : IF K$ = "" THEN Wait_Credits
    GOTO Print_Title_Screen


Print_Instructions:
    POKE 53281,5
    PRINT "{clr}{home}"
    PRINT " Absolute Trash - How to Play"
    PRINT
    PRINT " This game is an American Children's"
    PRINT " card game, known as Garbage, Ten"
    PRINT " or more commonly known as Trash."
    PRINT 
    PRINT " The aim of the game is to complete"
    PRINT " your bank of 10 cards, A - 10, before"
    PRINT " your opponent. The game is essentially"
    PRINT " the luck of the draw."
    PRINT
    PRINT " Aces count as 1, cards 2 - 10 have"
    PRINT " their face value, and Jacks are wild."
    PRINT " Queens and Kings end the player turn."
    PRINT
    PRINT " In this game, the suit of the card"
    PRINT " doesn't matter. Only the rank of the"
    PRINT " card counts."
    PRINT
    PRINT " The cursor is moved around the screen"
    PRINT " using the W, A, S, D or cursor keys."
    PRINT " Press RETURN to make your selection."
    PRINT
    PRINT "                               - MORE -";

Wait_Instruction_Key_1:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_1

    GOSUB Print_Blank_Screen

    PRINT "{home}{rvs on}                                        ";
    PRINT " Absolute Trash - How to Play           ";
    PRINT "                                        ";
    PRINT " Cards are shuffled and each player is  ";
    PRINT " dealt 10 cards, placed face down in    ";
    PRINT " front of them in 2 rows of 5 cards.    ";
    PRINT "                                        ";
    PRINT " {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green}                    ";
    PRINT " {blue}{125}A{125}{green} {blue}{125}2{125}{green} {blue}{125}3{125}{green} {blue}{125}4{125}{green} {blue}{125}5{125}{green}                    ";
    PRINT " {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green}                    ";
    PRINT " {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green}                    ";
    PRINT "                                        ";
    PRINT "                                        ";
    PRINT " {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green}                    ";
    PRINT " {blue}{125}6{125}{green} {blue}{125}7{125}{green} {blue}{125}8{125}{green} {blue}{125}9{125}{green} {blue}{125}1{125}{green}                    ";
    PRINT " {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {blue}{125}0{125}{green}                    ";
    PRINT " {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green}                    ";
    PRINT "                                        ";
    PRINT " Players are not allowed to look at     ";
    PRINT " their card bank.                       ";
    PRINT "                                        ";
    PRINT " The rest of the deck is set to one     ";
    PRINT " side to be used as a draw stack.       ";
    PRINT "                                        ";
    PRINT "                               - MORE -";

Wait_Instruction_Key_2:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_2

    GOSUB Print_Blank_Screen

    PRINT "{home}{rvs on}                                        ";
    PRINT " Absolute Trash - How to Play   {180} STACK ";
    PRINT "                                {180}       ";
    PRINT " The turn begins by drawing     {180}  {blue}{176}{99}{174}{green}  ";
    PRINT " from the stack. The card in    {180}  {blue}{125}{166}{125}{green}  ";
    PRINT " play is shown under 'current'  {180}  {blue}{125}{166}{125}{green}  ";
    PRINT "                                {180}  {blue}{173}{99}{189}{green}  ";
    PRINT " If the card is a pip card,     {180}       ";
    PRINT " A-10, the player places that   {180}       ";
    PRINT " card in the correct location   {180}DISCARD";
    PRINT " in the bank, unless the bank   {180}       ";
    PRINT " slot has already been filled.  {180}  {rvs off}   {rvs on}  ";
    PRINT "                                {180}  {rvs off} {black}A{green} {rvs on}  ";
    PRINT " If the card in that location   {180}  {rvs off} {black}{120}{green} {rvs on}  ";
    PRINT " is currently face down, the    {180}  {rvs off}   {rvs on}  ";
    PRINT " face down card is turned over  {180}       ";
    PRINT " and becomes the next card in   {180}       ";
    PRINT " play.                          {180}CURRENT";
    PRINT "                                {180}       ";
    PRINT " If the card in play has        {180}  {166}{166}{166}  ";
    PRINT " already been banked, the       {180}  {166}{166}{166}  ";
    PRINT " player must discard the card,  {180}  {166}{166}{166}  ";
    PRINT " placing it on the discard pile {180}  {166}{166}{166}  ";
    PRINT "                                        ";
    PRINT "                               - MORE -";

Wait_Instruction_Key_3:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_3

    GOSUB Print_Blank_Screen

    PRINT "{home}{rvs on}                                        ";
    PRINT " Absolute Trash - How to Play   {180} STACK ";
    PRINT "                                {180}       ";
    PRINT " {blue}{176}{99}{174}{green} {rvs off}   {rvs on} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green} {rvs off}   {rvs on}{green}            {180}  {blue}{176}{99}{174}{green}  ";
    PRINT " {blue}{125}{166}{125}{green} {rvs off} {black}2 {rvs on}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {rvs off} {red}5 {rvs on}{green}            {180}  {blue}{125}{166}{125}{green}  ";
    PRINT " {blue}{125}{166}{125}{green} {rvs off} {black}{97} {rvs on}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green} {rvs off} {red}{115} {rvs on}{green}            {180}  {blue}{125}{166}{125}{green}  ";
    PRINT " {blue}{173}{99}{189}{green} {rvs off}   {rvs on}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green} {rvs off}   {rvs on}            {180}  {blue}{173}{99}{189}{green}  ";
    PRINT "                                {180}       ";
    PRINT " {rvs off}   {rvs on} {blue}{176}{99}{174}{green} {rvs off}   {rvs on}{green} {blue}{176}{99}{174}{green} {blue}{176}{99}{174}{green}            {180}       ";
    PRINT " {rvs off} {red}6 {rvs on}{green} {blue}{125}{166}{125}{green} {rvs off} {black}8 {rvs on}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green}            {180}DISCARD";
    PRINT " {rvs off} {red}{122} {rvs on}{green} {blue}{125}{166}{125}{green} {rvs off} {black}{120} {rvs on}{green} {blue}{125}{166}{125}{green} {blue}{125}{166}{125}{green}            {180}       ";
    PRINT " {rvs off}   {rvs on}{green} {blue}{173}{99}{189}{green} {rvs off}   {rvs on}{green} {blue}{173}{99}{189}{green} {blue}{173}{99}{189}{green}            {180}  {rvs off}   {rvs on}  ";
    PRINT "                                {180}  {rvs off} {red}6 {rvs on}{green}  ";
    PRINT " The player continues turning   {180}  {rvs off} {red}{115} {rvs on}{green}  ";
    PRINT " and banking cards until the.   {180}  {rvs off}   {rvs on}{green}  ";
    PRINT " card to bank has already been  {180}       ";
    PRINT " turned face up.                {180}       ";
    PRINT "                                {180}CURRENT";
    PRINT " The player discards this card  {180}       ";
    PRINT " and play continues with their  {180}  {rvs off}   {rvs on}  ";
    PRINT " opponent.                      {180}  {rvs off} {black}7 {rvs on}{green}  ";
    PRINT "                                {180}  {rvs off} {black}{97} {rvs on}{green}  ";
    PRINT "                                {180}  {rvs off}   {rvs on}  ";
    PRINT "                                        ";
    PRINT "                               - MORE -";

Wait_Instruction_Key_4:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_4

    POKE 53281,5

    PRINT "{clr}{home}{white}"
    PRINT " Absolute Trash - How to Play"
    PRINT
    PRINT " If discards are enabled and the"
    PRINT " previous player has discarded a card"
    PRINT " that the player requires, the player"
    PRINT " may pick up and play the discarded"
    PRINT " card instead of starting their turn"
    PRINT " from the stack."
    PRINT
    PRINT
    PRINT " If Jacks as Wild Cards is enabled, any"
    PRINT " time that the player draws a Jack, the"
    PRINT " Jack may be played as if it were a pip"
    PRINT " card, A-10, so long as the banked slot"
    PRINT " has not yet been turned face up."
    PRINT
    PRINT " If the player is able to play a pip"
    PRINT " card where a wild card Jack has"
    PRINT " previously been played, the pip card"
    PRINT " will replace the wild card and the"
    PRINT " wild card is then able to be re-used"
    PRINT " in a new, face down location."
    PRINT
    PRINT "                               - MORE -";

Wait_Instruction_Key_5:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_5

    PRINT "{clr}{home}{white}"
    PRINT " Absolute Trash - How to Play"
    PRINT
    PRINT " In the unlikely event that all of the"
    PRINT " stack has been played, the discard"
    PRINT " pile, (with the exception of the top"
    PRINT " card), will be re-shuffled and turned"
    PRINT " face down to form a new stack pile."
    PRINT
    PRINT
    PRINT " The first player to turn over all of"
    PRINT " their bank cards is the winner."
    PRINT
    PRINT " If more than one round is to be"
    PRINT " played, the winner from the previous"
    PRINT " round will have 1 fewer cards to bank,"
    PRINT " starting from 10, (leaving A - 9"
    PRINT " remaining, and so on)."
    PRINT
    PRINT " The player who won the previous round"
    PRINT " will start the next round."
    PRINT
    PRINT
    PRINT "                                - END -";

Wait_Instruction_Key_6:
    GET K$ : IF K$ = "" THEN Wait_Instruction_Key_6

    GOTO Print_Title_Screen