
Initialise_Program:
    VL = 1024  : REM $0400 - First Screen Location
    CR = 55296 : REM $D800 - Colour RAM Base

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

Wait_Key: GOTO Wait_Key