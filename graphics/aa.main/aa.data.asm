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
;		Sprite Graphics Page
;
GXSpritePage = 24
;
;		Address of that page
;
GXMappingAddress = ($2000 * GXMappingPage)
;
;		LUT to use for mapping
;
GFXMappingLUT = 0
;
;		LUT Edit slot
;
GFXEditSlot = 8 + GXMappingPage

; ************************************************************************************************
;
;									Allocate or Re-Use memory
;
; ************************************************************************************************

.if graphicsIntegrated==1
;
;		Zero Page (reuse BASIC temps)
;
gzTemp0 = zTemp0
gzTemp1 = zTemp1
gzTemp2 = zTemp2
gsTemp = zsTemp
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
;		Base page of bitmap
;
gxBasePage:
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
