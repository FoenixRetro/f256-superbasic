100 print "Loading fox1.dat"
110 bload "fox1.dat",$030000
120 print "Loaded.
1000 '
1001 ' "Solarfox in SuperBasic"
1002 '
1003 cls:sprites on:bitmap on:bitmap clear 0
1004 initialise()
1005 newLevel(level)
1006 repeat
1007 repeat
1008 if event(moveEnemies,4)
1009 updateEnemies()
1010 n = random(mcount):if remain(n) = 0 then launch(n)
1011 endif
1012 if event(moveMissiles,6) then moveMissiles()
1013 if event(movePlayer,3) then movePlayer()
1014 until collectZeroCount = 0 | playerHit
1015 if playerHit
1016 lives = lives-1:updateLives():resetmissiles()
1017 playerHit = False:flashplayer()
1018 else
1019 level = level+1:newLevel(level)
1020 score = score + 1000*level:updateScore()
1021 endif
1022 until lives = 0
1023 bitmap clear 0:sprites off
1024 end
1025 '
1026 ' "Set up a new game"
1027 '
1028 proc initialise()
1029 xSize = 14:ySize = 11:mCount = 8
1030 xOrg = 160-xSize*8:yOrg = 140-ySize*8
1031 dim x(7),y(7),xi(7),yi(7),remain(7)
1032 dim collect(xSize-1,ySize-1)
1033 score = 0:lives = 3:level = 0
1034 endproc
1035 '
1036 ' "Move the player"
1037 '
1038 proc movePlayer()
1039 local x,y
1040 x = joyx(0):y = joyy(0)
1041 if x <> 0 & (yPlayer & 15) = 0 then xiPlayer = x * 4:yiPlayer = 0:iPlayer = 1-x
1042 if y <> 0 & (xPlayer & 15) = 0 then yiPlayer = y * 4:xiPlayer = 0:iPlayer = 2-y
1043 if (xPlayer | yPlayer & 15) = 0 then checkCollect(xPlayer >> 4,yPlayer >> 4)
1044 xPlayer = min((xSize-1) << 4,max(0,xPlayer + xiPlayer))
1045 yPlayer = min((ySize-1) << 4,max(0,yPlayer + yiPlayer))
1046 sprite 50 image iPlayer to xOrg+xPlayer,yOrg+yPlayer
1047 endproc
1048 '
1049 ' "Flash the player"
1050 '
1051 proc flashplayer()
1052 local t:t = timer() + 140
1053 while timer() < t
1054 if timer() & 16:sprite 50 image iPlayer:else sprite 50 off:endif
1055 wend
1056 endproc
1057 '
1058 ' "Fire a new missile from slot 'n'"
1059 '
1060 proc launch(n)
1061 if random() & 1:horizontalLaunch(n):else:verticalLaunch(n):endif
1062 endproc
1063 '
1064 ' "Launch a missile from top or bottom"
1065 '
1066 proc verticalLaunch(n)
1067 x(n) = xOrg-16:y(n) = yOrg+((yFire+8) & $F0):xi(n) = 4:yi(n) = 0
1068 remain(n) = abs((xSize*16+16) \ xi(n))
1069 if random() & 1 then x(n) = x(n) + remain(n)*xi(n):xi(n) = -xi(n)
1070 sprite n image 11 to x(n),y(n)
1071 endproc
1072 '
1073 ' "Launch a missile from left or right"
1074 '
1075 proc horizontalLaunch(n)
1076 y(n) = yOrg-16:x(n) = xOrg+((xFire+8) & $F0):yi(n) = 4:xi(n) = 0
1077 remain(n) = abs((ySize*16+16) \ yi(n))
1078 if random() & 1 then y(n) = y(n) + remain(n)*yi(n):yi(n) = -yi(n)
1079 sprite n image 12 to x(n),y(n)
1080 endproc
1081 '
1082 ' "Move all missiles"
1083 '
1084 proc moveMissiles()
1085 local i
1086 for i = 0 to mCount-1
1087 if remain(i) > 0
1088 x(i) = x(i)+xi(i):y(i) = y(i)+yi(i)
1089 if hit(i,50) > 0 then if hit(i,50) < 10 then playerHit = True
1090 remain(i) = remain(i)-1
1091 if remain(i) > 0:sprite i to x(i),y(i):else:sprite i off:endif
1092 endif
1093 next
1094 endproc
1095 '
1096 ' "Start a new level"
1097 '
1098 proc newLevel(n)
1099 local x,y,c$
1100 bitmap clear 0
1101 drawBackground():resetmissiles():updateEnemies()
1102 xPlayer = xSize\2*16:yPlayer = ySize\2*16:iPlayer = 0:xiPlayer = 0:yiPlayer = 0
1103 sprite 50 image iPlayer to xOrg+xPlayer,yOrg+yPlayer:playerHit = False
1104 for x = 0 to xSize-1:for y = 0 to ySize-1:collect(x,y) = 0:next:next
1105 collectZeroCount = 0
1106 getLevelData(level % 6):p = 1:if level >= 6 then p = 2
1107 for x = 0 to 6:for y = 0 to 4
1108 c$ = mid$(level$,x+y*8+1,1):if c$ = "X" then setqcollect(x,y,p)
1109 next:next:mCount = min(3+level\3,7)
1110 endproc
1111 '
1112 ' "Check collection"
1113 '
1114 proc checkCollect(x,y)
1115 if collect(x,y) <> 0
1116 local n:n = collect(x,y)-1:collect(x,y) = n
1117 renderCollect(x,y,n)
1118 if n = 0 then collectZeroCount = collectZeroCount - 1
1119 score = score + 25:updateScore()
1120 endif
1121 endproc
1122 '
1123 ' "Update score"
1124 '
1125 proc updateScore()
1126 text right$("00000"+str$(score),6) dim 1 colour $1F,4 to 80-24,12
1127 endproc
1128 '
1129 ' "Update lives display"
1130 '
1131 proc updateLives()
1132 rect solid colour 0 from 240,6 to 300,16
1133 if lives > 0
1134 for i = 1 to lives
1135 image 10 to 240+i*12,8
1136 next
1137 endif
1138 endproc
1139 '
1140 ' "Set the collection in all 4 quadrant"
1141 '
1142 proc setqcollect(x,y,n)
1143 setcollect(x,y,n):setcollect(xSize-1-x,y,n):setcollect(x,ySize-1-y,n):setcollect(xSize-1-x,ySize-1-y,n)
1144 endproc
1145 '
1146 ' "Set the collect for one cell (non-erase, creation *only*)"
1147 '
1148 proc setcollect(x,y,n)
1149 if collect(x,y) = 0
1150 collectZeroCount = collectZeroCount + 1
1151 collect(x,y) = n
1152 renderCollect(x,y,n)
1153 endif
1154 endproc
1155 '
1156 ' "Render a collection item 0,1,2. 0 Erases. These are drawn on the background not sprites."
1157 '
1158 proc renderCollect(x,y,n)
1159 if n > 0
1160 image 7+n dim 1 to x*16+xOrg-4+1,y*16+yOrg-4+1
1161 else
1162 local xc,yc:xc = x * 16+xOrg:yc = y * 16 + yOrg
1163 rect solid colour $0 from xc-6,yc-6 to xc+6,yc+6
1164 line colour $25 from xc-6,yc to xc+6,yc from xc,yc-6 to xc,yc+6
1165 endif
1166 endproc
1167 '
1168 ' "Reset all Missiles"
1169 '
1170 proc resetmissiles()
1171 local i
1172 for i = 0 to 7:remain(i) = 0:sprite i off:next
1173 endproc
1174 '
1175 ' "Draw the screen background"
1176 '
1177 proc drawBackground()
1178 local x,y:line colour $25
1179 for x = 0 to xSize-1:line xOrg+x*16,yOrg-8 by 0,ySize*16:next
1180 for y = 0 to ySize-1:line xOrg-8,yOrg+y*16 by xSize*16,0:next
1181 rect colour $E0 outline xOrg-24,yOrg-24 by xSize*16+32,ySize*16+32
1182 rect colour $FF outline xOrg-25,yOrg-25 by xSize*16+34,ySize*16+34
1183 updateScore():text "1 Up" colour $E0 to 64,2:updateLives()
1184 endproc
1185 '
1186 ' "Use the timer to set the positions of the shooting enemies"
1187 '
1188 proc updateEnemies()
1189 local t:t = timer()
1190 xFire = abs((t % (xSize << 5))-(xSize << 4))
1191 sprite 10 image 5 to xOrg+xFire,yOrg-16
1192 sprite 11 image 7 to xOrg+xFire,yOrg+ySize<<4
1193 yFire = abs((t % (ySize << 5))-(ySize << 4))
1194 sprite 12 image 4 to xOrg-16,yOrg+yFire
1195 sprite 13 image 6 to xOrg+xSize<<4,yOrg+yFire
1196 endproc
1197 '
1198 ' "Level data"
1199 '
1200 proc getLevelData(n)
1201 level$ = ""
1202 if n = 0 then level$ = "....XXX ...XXX. ..XXX.. ..XXX.. .XXXX.."
1203 if n = 1 then level$ = "....XXX ...XXXX ..XXXXX .XXXXXX XXXXXXX"
1204 if n = 2 then level$ = "XXXXXXX X...... X...... XXXXXXX ......."
1205 if n = 3 then level$ = "XXXXX.. X...X.. X...XXX XXXXX.. ....X.."
1206 if n = 4 then level$ = ".....X. ....XX. ..XX.X. X....X. XXXXXX."
1207 if n = 5 then level$ = ".....X. ....XX. .XXX.X. X....X. XXXXXX."
1208 if n = 6 then level$ = "XX..... .XX.... ..XX... ....XX. .....XX
1209 endproc
1210 '
1211 ' "Simple title screen"
1212 '
1213 proc title(name$)
1214 bitmap on:bitmap clear 0:cls
1215 centre(210,1,$1F,"Press FIRE to Start")
1216 centre(120,1,$FC,"A Foenix F256 Demo Game in BASIC")
1217 centre(130,1,$F0,"Written by Paul Robson 2022")
1218 n = 0
1219 while joyb(0) = 0
1220 drawTitleAt(n$,n):n = (n + 1) & 7
1221 wend
1222 while joyb(0) <> 0:wend
1223 bitmap off
1224 endproc
1225 '
1226 proc centre(y,size,c,msg$)
1227 text msg$ dim size colour c to 160-len(msg$)*size*4,y
1228 endproc
1229 '
1230 proc drawTitleAt(n$,offset)
1231 text name$ colour random() & $FF dim 3 to 160-len(name$)*12+offset,32+offset
1232 endproc
ÿÿÿÿ

