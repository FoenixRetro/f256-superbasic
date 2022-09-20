;
;	This is automatically generated.
;
ERRID_BREAK = 1
error_break .macro
	lda	#1
	jmp	ErrorHandler
	.endm
ERRID_SYNTAX = 2
error_syntax .macro
	lda	#2
	jmp	ErrorHandler
	.endm
ERRID_DIVZERO = 3
error_divzero .macro
	lda	#3
	jmp	ErrorHandler
	.endm
ERRID_RANGE = 4
error_range .macro
	lda	#4
	jmp	ErrorHandler
	.endm
ERRID_TYPE = 5
error_type .macro
	lda	#5
	jmp	ErrorHandler
	.endm
ERRID_MEMORY = 6
error_memory .macro
	lda	#6
	jmp	ErrorHandler
	.endm
ERRID_ARGUMENT = 7
error_argument .macro
	lda	#7
	jmp	ErrorHandler
	.endm
ERRID_STOP = 8
error_stop .macro
	lda	#8
	jmp	ErrorHandler
	.endm
ERRID_STRING = 9
error_string .macro
	lda	#9
	jmp	ErrorHandler
	.endm
ERRID_ASSERT = 10
error_assert .macro
	lda	#10
	jmp	ErrorHandler
	.endm
ERRID_DATA = 11
error_data .macro
	lda	#11
	jmp	ErrorHandler
	.endm
