#ifndef NULL
	const NULL as any ptr = 0
#endif

#DEFINE DEBUG		1
#define	SCR_W		800
#define	SCR_H		600
#define APP_NAME	"FBVG"
#define APP_VERSION	"0.0.9"
#define APP_AUTHOR	"Pitto"

'colors
#define C_BLACK			&h000000
#define C_WHITE			&hFFFFFF
#define C_GRAY 			&h7F7F7F
#define C_DARK_GRAY		&h202020
#define C_RED			&hFF0000
#define C_BLUE 			&h0000FF
#define C_GREEN			&h00FF00
#define C_YELLOW		&hFFFF00
#define C_CYAN 			&h00FFFF
#define C_LILIAC		&h7F00FF
#define C_ORANGE		&hFF7F00
#define C_PURPLE		&h7F007F
#define C_DARK_RED 		&h7F0000
#define C_DARK_GREEN	&h005500
#define C_DARK_BLUE		&h00007F

const as double _PI = 4*atn(1)

#define GRID_H_SPACING	20
#define GRID_v_SPACING	20
#define GRID_PATTERN	&b10001000100010001000

#define MIN_ZOOM		0.25
#define MAX_ZOOM		4
#define MIN_SNAP_DIST	10

#define SEGMENT_PRECISION 0.025


#define RGBA_R( c ) ( CULng( c ) Shr 16 And 255 )
#define RGBA_G( c ) ( CULng( c ) Shr  8 And 255 )
#define RGBA_B( c ) ( CULng( c )        And 255 )
