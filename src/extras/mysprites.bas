10 print chr$(147)
20 print "generated with spritemate"
30 print "2 of 2 sprites displayed."
40 poke 53285,8: rem multicolor 1
50 poke 53286,6: rem multicolor 2
60 poke 53269,255 : rem set all 8 sprites visible
70 for x=12800 to 12800+127: read y: poke x,y: next x: rem sprite generation
80 :: rem sprite_0
90 poke 53287,9: rem color = 9
100 poke 2040,200: rem pointer
110 poke 53248, 44: rem x pos
120 poke 53249, 120: rem y pos
130 :: rem sprite_1
140 poke 53288,1: rem color = 1
150 poke 2041,201: rem pointer
160 poke 53250, 92: rem x pos
170 poke 53251, 120: rem y pos
180 poke 53276, 0: rem multicolor
190 poke 53277, 0: rem width
200 poke 53271, 0: rem height
1000 :: rem sprite_0 / singlecolor / color: 9
1010 data 0,0,0,0,0,0,0,6,0,0,15,0,0,11,0,0
1020 data 11,0,0,11,0,0,59,0,1,251,0,15,219,0,30,219
1030 data 112,22,219,208,22,219,176,22,219,96,31,255,64,31,255,192
1040 data 15,255,128,14,247,128,7,15,0,7,255,0,3,254,0,9
1050 :: rem sprite_1 / singlecolor / color: 1
1060 data 0,0,0,127,255,0,86,220,0,109,184,0,83,112,0,114
1070 data 208,0,109,176,0,90,112,0,118,88,0,109,188,0,91,94
1080 data 0,127,239,0,112,247,128,96,123,192,64,61,224,64,30,224
1090 data 0,15,96,0,7,192,0,3,128,0,0,0,0,0,0,1
