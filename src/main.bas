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


Initialise_Program:
    VL = 1024  : REM $0400 - First Screen Location
    CR = 55296 : REM $D800 - Colour RAM Base
    RA% = 0 : REM Card Rank
    SU% = 0 : REM Card Suit - 0 - Spades, 1 - Diamonds, 2 - Clubs, 3 - Hearts
    DI% = 0 : REM Deck Index Value
    DIM SD%(51) : REM Shuffled Card Deck Order
    DIM TS%(51) : REM Temp Shuffle Array



Restart:
    RD% = RND(-TI) : REM Re-seed the randomiser

    POKE 53280,5 : REM Set border colour to green - $D020
    POKE 53281,5 : REM Set background colour to green - $D020

    PRINT "{clr}{home}{white}Shuffling deck..."
    PRINT

    GOSUB Shuffle_Deck

    GOSUB Game_Screen

    FOR I = 0 TO 51
        REM Set Current Card
        DI% = I
        
        FOR J = 1 TO 300 : NEXT
        
        XP% = 35 : YP% = 20 : GOSUB Set_Cursor_Position : REM Set Cursor
        GOSUB Print_Current_Card        
    NEXT I

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
    PRINT "{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{127}{169}{180}  {166}{166}{166}  ";
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
    CI% = SD%(DI%) : REM Get Next Card
    GOSUB Get_Card_Value
    GOSUB Get_Cart_Suit

    IF SU% = 0 OR SU% = 2 THEN PRINT "{rvs off}{black}   " : GOTO Print_Current_Card__Rank
    PRINT "{rvs off}{red}   "

Print_Current_Card__Rank:
    YP% = YP% + 1 : GOSUB Set_Cursor_Position : REM Set Cursor
    If RA% = 0  THEN PRINT " A " : GOTO Print_Current_Card__Suit
    If RA% = 10 THEN PRINT " J " : GOTO Print_Current_Card__Suit
    If RA% = 11 THEN PRINT " Q " : GOTO Print_Current_Card__Suit
    If RA% = 12 THEN PRINT " K " : GOTO Print_Current_Card__Suit

    TS$ = STR$(RA%) + " "
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