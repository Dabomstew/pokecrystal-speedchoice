DelayFrame::
; Wait for one frame
	ld a, 1
	ld [wVBlankOccurred], a

; Wait for the next VBlank, halting to conserve battery
.halt
	halt ; rgbasm adds a nop after this instruction by default
	ld a, [wVBlankOccurred]
	and a
	jr nz, .halt
	ret

DelayFrames::
; Wait c frames
;	ldh a, [hJoypadDown]
;	and A_BUTTON | B_BUTTON
 ;       cp  A_BUTTON | B_BUTTON

;;        and B_BUTTON
;        ret z
	call DelayFrame
	dec c
	jr nz, DelayFrames
	ret
