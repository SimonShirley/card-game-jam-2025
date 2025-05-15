GOTO Initialise_Program

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP%
    REM Clear Flags
    REM CALL PLOT kernal routine
    POKE 781,YP% : POKE 782,XP% : POKE 783,0 : SYS 65520
    RETURN


Shuffle_Deck:
    REM Reset Deck
    FOR I = 0 TO 51
        TS%(I) = I
    NEXT I

    FOR I = 0 TO 51
        RD% = 52 - I
        GOSUB Get_Random_Number

        SD%(I) = TS%(RD%) : REM Get card from deck

        IF RD% >= 51 THEN Shuffle_Deck__Continue
        
        REM Slide cards along one
        FOR J = RD% TO 50
            TS%(J) = TS%(J + 1)
        NEXT J

Shuffle_Deck__Continue:
        PRINT "{166} ";
    NEXT I

    RETURN


Get_Card_Value:
    REM Requires CI% - Card Index Value
    REM Returns RA% - Rank Value
    RA% = CI% - (INT(CI% / 13) * 13)
    RETURN

Get_Cart_Suit:
    REM Requires CI% - Card Index Value
    REM Returns SU% - Suit Index

    REM 0 - Spades, 0-12
    REM 1 - Diamonds, 13-25
    REM 2 - Clubs, 26-38
    REM 3 - Hearts, 39-51

    SU% = INT(CI% / 13)
    RETURN

Get_Random_Number:
    REM Returns RD% - Random Output
    RD% = INT(RND(1) * RD%)
    RETURN

Place_Card_In_Bank:
    CO% = RA% - (INT(RA% / 5) * 5) : REM Get the Column Index 
    RO% = INT(RA% / 5) : REM Get the Row Index

    XP% = (CO% * 6) + 3 : REM Convert Column Index into Character position
    YP% = (RO% * 6) + 1 : REM Convert Row Index into screen line

    IF CP% THEN YP% = YP% + 13 : REM Move the screen line into player set

    GOSUB Set_Cursor_Position    
    GOSUB Print_Current_Card
    RETURN

Update_Player_Display:
    XP% = 0 : YP% = 12 : GOSUB Set_Cursor_Position : REM Set Cursor

    IF NOT CP% THEN Update_Player_Display__Computer

Update_Player_Display__Player:
    PRINT "{rvs on}{green}{99}{99}{99}{99}{99}{127}{169}{127}{169}  PLAYER  TURN {127}{169}{127}{169}{99}{99}{99}{99}{rvs off}";
    RETURN

Update_Player_Display__Computer:
    PRINT "{rvs on}{green}{99}{99}{99}{99}{99}{rvs off}{169}{127}{169}{127}{rvs on} COMPUTER TURN {rvs off}{169}{127}{169}{127}{rvs on}{99}{99}{99}{99}{rvs off}";
    RETURN


Initialise_Program:
    VL = 1024  : REM $0400 - First Screen Location
    CR = 55296 : REM $D800 - Colour RAM Base
    
    RA% = 0 : REM Card Rank
    SU% = 0 : REM Card Suit - 0 - Spades, 1 - Diamonds, 2 - Clubs, 3 - Hearts

    DIM SD%(51) : REM Shuffled Card Deck Order
    DIM TS%(51) : REM Temp Shuffle Array
    
    DIM PC%(9) : REM Player Covered Cards
    DIM PU%(9) : REM Player Uncovered Cards    

    DIM CC%(9) : REM Computer Covered Cards
    DIM CU%(9) : REM Computer Uncovered Cards    

    DIM DP%(41) : REM Discard Pile

    SI% = -1    : REM Shuffled Deck Current Index
    DI% = -1    : REM Discard Pile Current Index

    RD% = RND(-TI)


Restart:
    CP% = 0    : REM Current Player - -1 = Computer, 0 = Player

    PS% = 0    : REM Player Uncovered Count
    CS% = 0    : REM Computer Uncovered Count

    POKE 53280,5 : REM Set border colour to green - $D020
    POKE 53281,5 : REM Set background colour to green - $D021

    PRINT "{clr}{home}{white}Shuffling deck..."
    PRINT

    GOSUB Shuffle_Deck

    RD% = RND(-TI) : REM Re-seed the randomiser

    GOSUB Game_Screen

    REM Deal Cards
    FOR I = 0 TO 9
        SI% = SI% + 1       : REM Set Next Card Index
        PC%(I) = SD%(SI%)   : REM Allocate to Player
        PU%(I) = 0

        SI% = SI% + 1       : REM Set Next Card Index
        CC%(I) = SD%(SI%)   : REM Allocate to Computer
        CU%(I) = 0
    NEXT I

Ready_Up_Next_Player:
    CP% = NOT CP% : REM Set Next Player

    FOR J = 1 TO 1000 : NEXT : REM Wait

    GOSUB Update_Player_Display

    FOR J = 1 TO 1000 : NEXT : REM Wait

    REM Check if Discard pile is empty
    IF DI% = -1 THEN Draw_Card_From_Card_Stack

    REM Check rank of discarded card
    CI% = DP%(DI%)
    GOSUB Get_Card_Value

    REM If the card is A - 10, we may be able to claim it
    IF RA% > 9 THEN Draw_Card_From_Card_Stack
    IF NOT CP% THEN Check_Computer_Card_Bank

Check_Player_Card_Bank:
    REM If card has already been turned, draw from the stack
    IF PU%(RA%) THEN Draw_Card_From_Card_Stack

    REM Otherwise, use the discarded card
    GOTO Get_Card_From_Discard_Pile

Check_Computer_Card_Bank:
    REM If card has already been turned, draw from the stack
    IF CU%(RA%) THEN Draw_Card_From_Card_Stack

    REM Otherwise, use the discarded card
    GOTO Get_Card_From_Discard_Pile

Get_Card_From_Discard_Pile:
    DI% = DI% - 1
    IF DI% < 0 THEN DI% = -1

    IF DI% < 0 THEN GOSUB Blank_Discard_Pile : GOTO Get_Discarded_Card

    REM Re-print the last card on the discard pile
    CI% = DP%(DI%)

    XP% = 35 : YP% = 11 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

Get_Discarded_Card:
    REM Move the discarded card onto the current pile
    CI% = DP%(DI% + 1)

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    GOTO Proccess_Card

Blank_Discard_Pile:
    XP% = 35 : YP% = 11 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    RETURN


Draw_Card_From_Card_Stack:
    SI% = SI% + 1 : REM Set Next Card Index
    CI% = SD%(SI%) : REM Get Next Card

    REM Display First Card
    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    IF RA% >= 10 THEN Discard_Current_Card

Proccess_Card:
    IF CP% THEN Process_Player_Card
    GOTO Process_Computer_Card

Process_Player_Card:
    IF RA% >= 10 THEN Discard_Current_Card
    
    IF PU%(RA%) THEN Discard_Current_Card
    GOSUB Print_Blank_Card

    PU%(RA%) = -1

    GOSUB Place_Card_In_Bank

    PS% = PS% + 1
    IF PS% >= 10 THEN Wait_Key

    CI% = PC%(RA%)

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    GOTO Process_Player_Card


Process_Computer_Card:
    IF RA% >= 10 THEN Discard_Current_Card
    
    IF CU%(RA%) THEN Discard_Current_Card
    GOSUB Print_Blank_Card

    CU%(RA%) = -1

    GOSUB Place_Card_In_Bank

    CS% = CS% + 1
    IF CS% >= 10 THEN Wait_Key

    CI% = CC%(RA%)

    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    FOR J = 1 TO 300 : NEXT : REM Wait

    GOTO Process_Computer_Card
    

Discard_Current_Card:
    GOSUB Print_Blank_Card

    XP% = 35 : YP% = 11 : GOSUB Set_Cursor_Position : REM Set Cursor
    GOSUB Print_Current_Card

    DI% = DI% + 1
    DP%(DI%) = CI%

    GOTO Ready_Up_Next_Player


Wait_Key: GOTO Wait_Key

Game_Screen:
    POKE 53280,5 : REM Set border colour to green - $D020

    REM Disable the screen. This way, we can draw to the screen
    REM without the user seeing the characters being drawn.
    POKE 53265,PEEK(53265) AND 239 : REM 0 in bit 4 $D011
    
    POKE 53281,1 : REM Set background colour to white - $D021
    
    REM The whole screen is painted using reversed characters!
    PRINT "{clr}{home}{rvs on}{green}";
    PRINT "                                {180} STACK ";
    PRINT "   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}  {180}       ";
    PRINT "C  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}  {blue}{176}{99}{174}{green}  ";
    PRINT "O  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}  {blue}{125}{166}{125}{green}  ";
    PRINT "M  {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}  {180}  {blue}{125}{166}{125}{green}  ";
    PRINT "P                               {180}  {blue}{173}{99}{189}{green}  ";
    PRINT "U                               {180}       ";
    PRINT "T  {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}  {180}       ";
    PRINT "E  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}       ";
    PRINT "R  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}DISCARD";
    PRINT "   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}  {180}       ";
    PRINT "                                {180}  {166}{166}{166}  ";
    PRINT "{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{180}  {166}{166}{166}  ";
    PRINT "                                {180}  {166}{166}{166}  ";
    PRINT "   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}  {180}  {166}{166}{166}  ";
    PRINT "   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}       ";
    PRINT "P  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}       ";
    PRINT "L  {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}  {180}       ";
    PRINT "A                               {180}CURRENT";
    PRINT "Y                               {180}       ";
    PRINT "E  {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}   {blue}{176}{99}{174}{green}  {180}  {166}{166}{166}  ";
    PRINT "R  {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}  {166}{166}{166}  ";
    PRINT "   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}   {blue}{125}{166}{125}{green}  {180}  {166}{166}{166}  ";
    PRINT "   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}   {blue}{173}{99}{189}{green}  {180}  {166}{166}{166}  ";
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

Print_Current_Card:
    GOSUB Get_Card_Value
    GOSUB Get_Cart_Suit

    IF SU% = 0 OR SU% = 2 THEN PRINT "{rvs off}{black}   " : GOTO Print_Current_Card__Rank
    PRINT "{rvs off}{red}   "

Print_Current_Card__Rank:
    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    If RA% = 0  THEN PRINT " A " : GOTO Print_Current_Card__Suit
    If RA% = 9  THEN PRINT "10 " : GOTO Print_Current_Card__Suit
    If RA% = 10 THEN PRINT " J " : GOTO Print_Current_Card__Suit
    If RA% = 11 THEN PRINT " Q " : GOTO Print_Current_Card__Suit
    If RA% = 12 THEN PRINT " K " : GOTO Print_Current_Card__Suit

    TS$ = STR$(RA% + 1) + " "
    PRINT TS$

Print_Current_Card__Suit:
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
    XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{green}{166}{166}{166}"

    XP% = 35 : YP% = 21 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    XP% = 35 : YP% = 22 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    XP% = 35 : YP% = 23 : GOSUB Set_Cursor_Position : REM Set Cursor
    PRINT "{166}{166}{166}"

    RETURN