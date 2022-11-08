PermaOptionsP5String::
	db "BIKE INDOORS<LF>"
	db "        :@"

PermaOptionsP5Pointers::
	dw Options_BikeIndoors
	dw Options_PermaOptionsPage
PermaOptionsP5PointersEnd::

Options_BikeIndoors:
	ld hl, BIKE_INDOORS_ADDRESS
	lb bc, BIKE_INDOORS, 3
	jp Options_OnOff