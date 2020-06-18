PermaOptionsP4String::
	db "START WITH BIKE<LF>"
	db "        :@"

PermaOptionsP4Pointers::
	dw Options_StartWithBike
	dw Options_PermaOptionsPage
PermaOptionsP4PointersEnd::

Options_StartWithBike:
	ld hl, START_WITH_BIKE_ADDRESS
	lb bc, START_WITH_BIKE, 3
	jp Options_OnOff
