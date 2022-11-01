; ************************************************************************************************
; ************************************************************************************************
;
;		Name:		aa.data.asm
;		Purpose:	Data use for Graphics
;		Created:	6th October 2022
;		Reviewed: 	No
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ************************************************************************************************
; ************************************************************************************************
;
;		Page number to map in/out
;
GXMappingPage = 3
;
;		Address of that page
;
GXMappingAddress = ($2000 * GXMappingPage)
;
;		LUT to use for mapping
;
GXMappingLUT = 0
;
;		LUT Edit slot
;
GXEditSlot = 8 + GXMappingPage

; ************************************************************************************************
;
;									Allocate or Re-Use memory
;
; ************************************************************************************************

.if graphicsIntegrated==1
;
;		Zero Page (reuse BASIC temps)
;
gxzTemp0 = zTemp0
gxzTemp1 = zTemp1
gxzTemp2 = zTemp2
gxzScreen = zsTemp
;
;		Buffer for pixel data. Needs to be 32 pixels minimum. (Reusing number conversion buffer)
;
gxPixelBuffer = numberBuffer
.else
.endif

; ************************************************************************************************
;
;										Drawing macro
;
; ************************************************************************************************

plotpixel .macro
		and 	gxANDValue
		eor 	gxEORValue
		.endm
		
		.section storage

; ************************************************************************************************
;
;										Graphics data area
;								(maintain order for first section)
;
; ************************************************************************************************
;
;		current X/Y coordinates
;
gxCurrentX:
		.fill 	2		
gxCurrentY:
		.fill 	2		
;
;		last pair of X/Y coordinates
;
gxLastX:
		.fill 	2		
gxLastY:
		.fill 	2		
;
;		Working coordinate sets
;		
gxX0:
		.fill 	2
gxY0:
		.fill 	2
gxX1:
		.fill 	2
gxY1:
		.fill 	2
;
;		Sprites/Bitmaps on flags
;		
gxSpritesOn:
		.fill 	1
gxBitmapsOn:
		.fill 	1		
;
;		Base page of bitmap
;
gxBasePage:
		.fill 	1
;
;		Base page of sprite Data
;		
gxSpritePage:
		.fill 	1
;
;		Height of screen
;		
gxHeight:
		.fill 	1
;
;		Mode byte for sprites/chars (vflip|hflip|size2|size1|size0|-|s1|s2)
;		
gxMode:
		.fill 	1
;
;		Colours
;		
gxColour:
		.fill 	1
gxEORValue:
		.fill 	1
gxANDValue:
		.fill 	1
;
;		Original LUT and MMU settings
;		
gxOriginalLUTValue:
		.fill 	1
gxOriginalMMUSetting:
		.fill 	1		
;
;		Offset in calculation.
;
gsOffset:
		.fill 	1
;
;		Address of current selected sprite in I/O (MSB=0 => None)
;		
GSCurrentSprite:
		.fill 	2
;
;		Base address for sprite area
;		
GXSpriteOffsetBase:
		.fill 	2	
;
;		Sprite location store
;
;		Low <Hidden bit> <X Position >> 2>
; 		High <Size (00=8,01=16,10=24,11=32)> <Y Position >> 2>
;
GXSpriteLow:
		.fill 	64
GXSpriteHigh:		
		.fill 	64


		.send storage


; ************************************************************************************************
;
;									Changes and Updates
;
; ************************************************************************************************
;
;		Date			Notes
;		==== 			=====
;
; ************************************************************************************************
