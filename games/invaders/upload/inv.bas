100 print "Loading inv1.dat"
110 bload "inv1.dat",$030000
120 print "Loaded.
1000 '
1001 ' "Simplified Space Invaders Game"
1002 '
1003 cls:bitmap on:sprites on:bitmap clear 0
1004 skillLevel = 0:score = 0:lives = 3
1005 defineVariables():text "SCORE<1>" dim 1 colour $FF to 136,1
1006 resetlevel():resetPlayer():displayScore()
1007 repeat
1008 if event(moveInvadersEvent,invaderSpeed) then moveInvaders()
1009 if event(movePlayerEvent,3) then movePlayer():if yBullet >= 0 then moveBullet()
1010 if event(moveMissileEvent,2) then moveMissile()
1011 until lives = 0
1012 end
1013 '
1014 ' "Display the score"
1015 '
1016 proc displayScore()
1017 local a$:a$ = right$("00000"+str$(score),6)
1018 text a$ dim 1 colour $FF,4 to 144,10
1019 text "LIVES "+str$(lives) colour $1C,4 to 10,230
1020 endproc
1021 '
1022 ' "Move the player"
1023 '
1024 proc movePlayer()
1025 xPlayer = min(304,max(16,xPlayer+joyx(0)<<2))
1026 sprite 63 image 6 to xPlayer,220
1027 if joyb(0) & yBullet < 0 then xBullet = xPlayer:yBullet = 200
1028 endproc
1029 '
1030 ' "Flash player for 2 seconds"
1031 '
1032 proc flashPlayer()
1033 local tEnd:tEnd = timer()+70*2
1034 repeat
1035 if timer() & 8
1036 sprite 63 image 6
1037 else
1038 sprite 63 off
1039 endif
1040 until timer() > tEnd
1041 endproc
1042 '
1043 ' "Move the player bullet"
1044 '
1045 proc moveBullet()
1046 local xo
1047 yBullet = yBullet - 10
1048 if yBullet < 0
1049 sprite 62 off
1050 else
1051 sprite 62 image 11 to xBullet,yBullet
1052 xo = xBullet - xInvaders + 8
1053 if xo >= 0 & xo < 8*24 & xo % 24 < 16 then checkHit(xo \ 24)
1054 endif
1055 endproc
1056 '
1057 ' "Move current missile"
1058 '
1059 proc moveMissile()
1060 local r
1061 currentMissile = currentMissile + 1:if currentMissile > missileCount then currentMissile = 1
1062 if yMissile(currentMissile) < 0
1063 r = random(8)
1064 if colHeight(r) > 0 & (random()& 3) = 0
1065 xMissile(currentMissile) = xInvaders + 24 * r
1066 yMissile(currentMissile) = yInvaders + 24 * colHeight(r) - 24
1067 endif
1068 else
1069 yMissile(currentMissile) = yMissile(currentMissile) + 8
1070 if yMissile(currentMissile) > 220
1071 if abs(xMissile(currentMissile)-xPlayer) < 12
1072 lives = lives - 1:displayScore()
1073 flashPlayer()
1074 if lives > 0 then resetLevel()
1075 endif
1076 sprite currentMissile+50 off
1077 yMissile(currentMissile) = -1
1078 else
1079 sprite currentMissile+50 image 9 to xMissile(currentMissile),yMissile(currentMissile)
1080 endif
1081 endif
1082 endproc
1083 '
1084 ' "Check if column hit"
1085 '
1086 proc checkHit(col)
1087 yo = abs(yInvaders + (colHeight(col)-1)*24 - yBullet)
1088 if yo < 12 & colHeight(col) <> 0
1089 sprite col*5+colHeight(col)-1 off
1090 sprite 61 image 7 to col*24+xInvaders,(colHeight(col)-1)*24+yInvaders
1091 yBullet = -1:sprite 62 off
1092 score = score+(6-colHeight(col))*10:displayScore()
1093 colHeight(col) = colHeight(col)-1
1094 invTotal = invTotal - 1
1095 if invTotal > 0 & colHeight(col) = 0 then recalculateEdge()
1096 if invTotal = 0
1097 skillLevel = (skillLevel+1) % 10
1098 resetlevel()
1099 endif
1100 recalculateSpeed()
1101 endif
1102 endproc
1103 '
1104 ' "Move invaders across/down"
1105 '
1106 proc moveInvaders()
1107 xInvaders = xInvaders + xiInvaders
1108 if xInvaders < leftEdge
1109 xInvaders = leftEdge
1110 yInvaders = yInvaders + abs(xiInvaders)
1111 xiInvaders = -xiInvaders
1112 endif
1113 if xInvaders > rightEdge
1114 xInvaders = rightEdge
1115 yInvaders = yInvaders + abs(xiInvaders)
1116 xiInvaders = -xiInvaders
1117 endif
1118 drawInvaders(xInvaders,yInvaders)
1119 endproc
1120 '
1121 ' "Draw invaders sprites at correct position"
1122 '
1123 proc drawInvaders(xPos,yPos)
1124 local x,y,s
1125 altGraphic = 1 - altGraphic
1126 for x = 0 to 7
1127 s = x * 5
1128 if colHeight(x) > 0
1129 for y = 0 to colHeight(x)-1
1130 sprite s image graphic(y)+altGraphic to xPos+x*24,yPos+y*24
1131 s = s + 1
1132 next
1133 sprite 61 off
1134 endif
1135 next
1136 endproc
1137 '
1138 ' "Set up variables"
1139 '
1140 proc defineVariables()
1141 local i:missileCount = 4
1142 dim colheight(7),graphic(4),xMissile(missileCount),yMissile(missileCount)
1143 for i = 0 to 4:graphic(i) = i % 3 * 2:next:altGraphic = 0
1144 endproc
1145 '
1146 ' "Reset the player"
1147 '
1148 proc resetPlayer()
1149 xPlayer = 160:xBullet = 0:yBullet = -1
1150 movePlayerEvent = 0
1151 endproc
1152 '
1153 ' "Set up new level"
1154 '
1155 proc resetlevel()
1156 local i
1157 for i = 0 to 7:colHeight(i) = 5:next
1158 for i = 1 to missileCount:yMissile(i) = -1:sprite i+50 off:next
1159 invTotal = 5*8
1160 xInvaders = 160-7*12:yInvaders = 26+skillLevel*8:xiInvaders = 8
1161 drawInvaders(xInvaders,yInvaders)
1162 invaderSpeed = 4+invTotal*2
1163 moveInvadersEvent = 0:currentMissile = 0
1164 recalculateEdge():recalculateSpeed()
1165 endproc
1166 '
1167 ' "Recalaulate speed"
1168 '
1169 proc recalculateSpeed()
1170 invaderSpeed = 2+invTotal*3\2
1171 endproc
1172 '
1173 ' "Recalculate left/right edge"
1174 '
1175 proc recalculateEdge()
1176 local i
1177 leftEdge = 8
1178 i = 0:while colHeight(i) = 0:i = i + 1:leftEdge = leftEdge-24:wend
1179 rightEdge = 320-8-7*24
1180 i = 7:while colHeight(i) = 0:i = i - 1:rightEdge = rightEdge+24:wend
1181 endproc
1182 '
1183 ' "Simple title screen"
1184 '
1185 proc title(name$)
1186 bitmap on:bitmap clear 0:cls
1187 centre(210,1,$1F,"Press FIRE to Start")
1188 centre(120,1,$FC,"A Foenix F256 Demo Game in BASIC")
1189 centre(130,1,$F0,"Written by Paul Robson 2022")
1190 n = 0
1191 while joyb(0) = 0
1192 drawTitleAt(n$,n):n = (n + 1) & 7
1193 wend
1194 while joyb(0) <> 0:wend
1195 bitmap off
1196 endproc
1197 '
1198 proc centre(y,size,c,msg$)
1199 text msg$ dim size colour c to 160-len(msg$)*size*4,y
1200 endproc
1201 '
1202 proc drawTitleAt(n$,offset)
1203 text name$ colour random() & $FF dim 3 to 160-len(name$)*12+offset,32+offset
1204 endproc
ÿÿÿÿ

