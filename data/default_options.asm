DefaultOptions:
; wOptions: instant text, hold to mash, menu account
	db TEXT_SPEED_INSTANT | HOLD_TO_MASH_VAL | MENU_ACCOUNT_VAL
; other options bytes: all false
rept NUM_OPTIONS_BYTES - 1
	db $00
endr
; wSaveFileExists: no
	db FALSE
; wTextboxFlags: use text speed
	db 1 << FAST_TEXT_DELAY_F
; wPermanentOptions: nothing yet
rept NUM_PERMAOPTIONS_BYTES
	db $00
endr

; padding
rept 6 - (NUM_OPTIONS_BYTES + NUM_PERMAOPTIONS_BYTES)
	db $00
endr
