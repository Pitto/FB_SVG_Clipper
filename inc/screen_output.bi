type screen_output_proto
	declare constructor (image_filename as string)
	declare destructor ()

	declare sub draw_pointer(x as Long, y as Long, tool_selected as tool_enum)
	declare sub draw_bitmap()
	declare sub display_all()
	declare sub get_pan_and_zoom (_pan as vec_2d, _zoom as single) 
	
	declare sub scale_bitmap () 
	
	declare sub draw_grid () 
	declare sub draw_paths (	path as path_proto ptr, _
								position as vec_2d, _
								control_next as vec_2d, _
								control_prev as vec_2d)
								
	declare sub draw_control_points (	position as vec_2d, _
										control_next as vec_2d, _
										control_prev as vec_2d)
										
	declare sub draw_selection_area (	start_pos as vec_2d, _
										end_pos as vec_2d)
	
	declare property is_mouse_held () as boolean
	declare property is_mouse_held (value as boolean) 
	
	declare property bitmap_width () as integer
	declare property bitmap_height () as integer
	
		
	private:
	
	declare function mix (a as single, b as single, t as single) as single
    declare function BezierQuadratic(A as single, B as single, C as single, t as single) as single
    declare function BezierCubic(A as single, B as single, C as single, D as single, t as single) as single
	
	declare function projected (v as vec_2d) as vec_2d
	
	declare sub jpg_load (byval image_filename as string)
	declare sub clear_canvas()
	
	declare sub bresenham_line (x0 As Integer, y0 As Integer, x1 As Integer, y1 As Integer, _color As Ulong)
	
	declare sub draw_segment (	x1 as single, 	y1 as single,  _
								x1h as single, 	y1h as single, _
								x2 as single, 	y2 as single,  _
								x2h as single, 	y2h as single, _
								_color as Ulong, is_working_path as boolean)
								
	declare sub draw_thick_line(x0 As Long, y0 As Long, x1 As Long, y1 As Long, th As Single, _color As Ulong)	
	
	declare function rgb_best_contrast (c as Ulong, value as byte) as Ulong 					
	
	declare function imagescale(byval s as fb.Image ptr, _
                    byval w as integer, _
                    byval h as integer) as fb.Image ptr
	
	pan 			as vec_2d
	zoom 			as single
	is_zoom_changed as boolean
	
	workpage as integer
	
	canvas as FB.Image ptr

	bitmap as FB.Image ptr
	bitmap_scaled as FB.Image ptr
	
	_is_mouse_held as boolean
	
end type

'https://stackoverflow.com/questions/38063499/how-to-invert-rgb-hex-values-by-contrast-in-php
function screen_output_proto.rgb_best_contrast(c as Ulong, value as byte) as Ulong

    dim as ulong r, g, b
    
    r = iif (RGBA_R (c) < 128, RGBA_R (c) + value, 0)
    g = iif (RGBA_R (c) < 128, RGBA_R (c) + value, 0)
    b = iif (RGBA_R (c) < 128, RGBA_R (c) + value, 0)
    
    return rgb(r,g,b)
    
    
end function

sub screen_output_proto.scale_bitmap()

	this.bitmap_scaled = this.imagescale (this.bitmap, this.bitmap->width*this.zoom, this.bitmap->height*this.zoom)

end sub

' Ported from the C version
'https://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#FreeBASIC
Sub screen_output_proto.bresenham_line(x0 As Integer, y0 As Integer, x1 As Integer, y1 As Integer, _color As Ulong)
 
    Dim As Integer dx = Abs(x1 - x0), dy = Abs(y1 - y0)
    Dim As Integer sx = IIf(x0 < x1, 1, -1)
    Dim As Integer sy = IIf(y0 < y1, 1, -1)
    Dim As Integer er = IIf(dx > dy, dx, -dy) \ 2, e2
 
    Do
        'PSet this.canvas, (x0+1, y0), this.rgb_best_contrast(point (x0+1, y0, this.canvas))
        'PSet this.canvas, (x0-1, y0), this.rgb_best_contrast(point (x0-1, y0, this.canvas))
        'PSet this.canvas, (x0, y0+1), this.rgb_best_contrast(point (x0, y0+1, this.canvas))
        'PSet this.canvas, (x0, y0-1), this.rgb_best_contrast(point (x0, y0-1, this.canvas))
        PSet this.canvas, (x0, y0) ', this.rgb_best_contrast(point (x0, y0, this.canvas))
        If (x0 = x1) And (y0 = y1) Then Exit Do
        e2 = er
        If e2 > -dx Then Er -= dy : x0 += sx
        If e2 <  dy Then Er += dx : y0 += sy
    Loop
 
End Sub

'translated by UEZ
' https://www.freebasic.net/forum/viewtopic.php?f=3&t=29154&p=279754&hilit=thick+line#p279754
' from source http://members.chello.at/easyfilter/canvas.html
Sub screen_output_proto.draw_thick_line(x0 As Long, y0 As Long, x1 As Long, y1 As Long, th As Single, _color As Ulong)
   Dim As Long dx = Abs(x1 - x0), sx = Iif(x0 < x1, 1, -1), dy = Abs(y1 - y0), sy = Iif(y0 < y1, 1, -1)
   Dim As Single er, e2 = Sqr(dx * dx + dy * dy), alpha
   If (th <= 1 or e2 = 0) Then
      Line this.canvas, (x0, y0) - (x1, y1), _color
      Exit Sub
   End If
   
   dx *= 255 / e2
   dy *= 255 / e2
   th = 255 * (th - 1)
  ' Dim As Ulong c = (_color And &hFFFFFF)
   
   If (dx < dy) Then
      x1 = round((e2 + th / 2) / dy)
      er = x1 * dy - th / 2
      x0 -= x1 * sx
      While (y0 <> y1)
         y0 += sy
         x1 = x0
         'alpha = 255 - er
         Pset this.canvas, (x1, y0), _color
         e2 = dy - er - th
         While (e2 + dy < 255)
            e2 += dy
            x1 += sx
            Pset this.canvas, (x1, y0), _color
         Wend
         'alpha = 255 -  e2
         'Pset  this.canvas, (x1 + sx, y0), (alpha Shl 24) Or c
         Pset  this.canvas, (x1 + sx, y0), _color
         er += dx
         If (er > 255) Then
            er -= dy
            x0 += sx
         End If
      Wend
   Else
      y1 = round((e2 + th / 2) / dx)
      er = y1 * dx - th / 2
      y0 -= y1 * sy
      While (x0 <> x1)
         x0 += sx
         y1 = y0
         alpha = 255 - er
         Pset this.canvas, (x0, y1), _color
         e2 = dx - er - th
         While (e2 + dx < 255)
            e2 += dx
            y1 += sy
            Pset this.canvas, (x0, y1), _color
         Wend
         alpha = 255 - e2
         Pset this.canvas, (x0, y1 + sy), _color
         er += dy
         If (er > 255) Then
            er -= dx
            y0 += sy
         End If
      Wend
   End If
End Sub

sub screen_output_proto.get_pan_and_zoom(_pan as vec_2d, _zoom as single)
	
	if (this.zoom <> _zoom) then
		is_zoom_changed = true
	end if
	
	this.pan = _pan
	this.zoom = _zoom
	
	'redraw the bitmap once
	if is_zoom_changed then
	
		this.scale_bitmap()
		is_zoom_changed = false
	
	end if
	
end sub

Property screen_output_proto.bitmap_width() as integer
   Return this.bitmap->width
End Property

Property screen_output_proto.bitmap_height() as integer
   Return this.bitmap->height
End Property

Property screen_output_proto.is_mouse_held() as boolean
   Return this._is_mouse_held
End Property

Property screen_output_proto.is_mouse_held (value as boolean) 
   this._is_mouse_held = value
End Property

sub screen_output_proto.draw_bitmap ()

	put this.canvas, (this.pan.x,this.pan.y), this.bitmap_scaled, pset

end sub

sub screen_output_proto.draw_grid ()

	dim v_spacing as integer = GRID_V_SPACING 
	dim h_spacing as integer = GRID_H_SPACING 
	
	if this.zoom then 
	
		v_spacing *= zoom
		h_spacing *= zoom
		
	end if
	
	dim as integer x, y
	
	for x =  pan.x mod h_spacing - h_spacing to SCR_W + pan.x mod h_spacing + h_spacing step h_spacing
		
		for y =  pan.y mod v_spacing - v_spacing to SCR_H + pan.y mod v_spacing + v_spacing step v_spacing
		
			pset this.canvas, ( x , y ), C_GRAY
		
		next y

	next x
		

end sub

sub screen_output_proto.display_all ()

	screenlock ' Lock the screen
	screenset Workpage, 1 - Workpage
	cls
	
	put (0,0), this.canvas
	
	workpage = 1 - Workpage ' Swap work pages.  
	screenunlock
	
	this.clear_canvas ()
	
end sub



sub screen_output_proto.jpg_load (byval image_filename as string)

	dim as integer   w,h,BytesPerPixel
	dim as ubyte ptr pImageBuffer

	pImageBuffer=LoadJPG(image_filename,w,h,BytesPerPixel)
	
	#IFDEF DEBUG
		utility_consmessage    ("img w: " + str(w) + ", img h: " + str (h))
	#ENDIF
	
	this.bitmap = ImageCreate(w, h)

	if pImageBuffer then
	  'screenres w,h,BytesPerPixel*8
	  dim as ubyte ptr pRGB=pImageBuffer
	  'screenlock
	  for y as integer=0 to h-1
		for x as integer=0 to w-1
		  pset this.bitmap, (x,y),rgb(pRGB[0],pRGB[1],pRGB[2])
		  pRGB+=BytesPerPixel
		next
	  next
	 ' screenunlock
	  if pImageBuffer then deallocate(pImageBuffer)
	end if

end sub

sub screen_output_proto.draw_pointer (x as Long, y as Long, tool_selected as tool_enum)

	dim as Ulong foreground_color, background_color
	
	foreground_color = iif(this._is_mouse_held, C_WHITE, C_DARK_GRAY)
	background_color = iif(this._is_mouse_held, C_DARK_GRAY, C_WHITE)
	
	select case tool_selected
	
		case TOOL_PEN
	
			line this.canvas, (x-7, y-1)-step(4,2), background_color, BF
			line this.canvas, (x+3, y-1)-step(4,2), background_color, BF
			
			line this.canvas, (x-8, y)-step(6,0), background_color
			line this.canvas, (x+2, y)-step(6,0), background_color
			
			line this.canvas, (x-7, y)-step(4,0), foreground_color
			line this.canvas, (x+3, y)-step(4,0), foreground_color
			
			line this.canvas, (x-1, y-7)-step(2,4), background_color, BF
			line this.canvas, (x-1, y+3)-step(2,4), background_color, BF
			
			line this.canvas, (x, y-8)-step(0,6), background_color
			line this.canvas, (x, y+2)-step(0,6), background_color
				
			line this.canvas, (x, y-7)-step(0,4), foreground_color
			line this.canvas, (x, y+3)-step(0,4), foreground_color
		
		case TOOL_HAND
		
			line this.canvas, (x-3, y-3)-step(6,6), background_color, BF
			line this.canvas, (x-2, y-2)-step(4,4), foreground_color, BF
			
		case TOOL_SELECTION
		
			draw_thick_line(x, y, x+10, y+10, 2, background_color)
			draw_thick_line(x+10, y+10, x+5, y+10, 2, background_color)
			draw_thick_line(x+5, y+10, x, y+14, 2, background_color)
			draw_thick_line(x, y+14, x, y, 2, background_color)
		
			draw_thick_line(x, y, x+10, y+10, 1, foreground_color)
			draw_thick_line(x+10, y+10, x+5, y+10, 1, foreground_color)
			draw_thick_line(x+5, y+10, x, y+14, 1, foreground_color)
			draw_thick_line(x, y+14, x, y, 1, foreground_color)
		
		case TOOL_DIRECT_SELECTION
		
			draw_thick_line(x, y, x+10, y+10, 1, background_color)
			draw_thick_line(x+10, y+10, x+5, y+10, 1, background_color)
			draw_thick_line(x+5, y+10, x, y+14, 1, background_color)
			draw_thick_line(x, y+14, x, y, 1, background_color)
		
	end select

end sub

sub screen_output_proto.clear_canvas ()

	line this.canvas, (0,0)-(SCR_W-1, SCR_H-1), &h000000, BF

end sub

constructor screen_output_proto (image_filename as string)

	workpage = 0
	
	screenres (SCR_W, SCR_H, 24, 2)
	screenset workpage, 1 - workpage
	WindowTitle APP_NAME + " " + Str(APP_VERSION) + " by " + str(APP_AUTHOR)
	
	this.canvas = ImageCreate(SCR_W, SCR_H)
	this.clear_canvas ()
	
	this.bitmap = ImageCreate(SCR_W, SCR_H)
	
	
		
	#IFDEF DEBUG
		utility_consmessage    ("loading image")

	dim t as double = Timer
	
	#ENDIF
	
	this.jpg_load(image_filename)
	
	#IFDEF DEBUG
		utility_consmessage    ("image loaded in " + str(Timer -t))
	#ENDIF
	
	
	this.bitmap_scaled = this.imagescale (this.bitmap, this.bitmap->width, this.bitmap->height)
	
	this.pan = type<vec_2d> (0,0)
	
	
	

end constructor

destructor screen_output_proto()

	ImageDestroy this.canvas
	ImageDestroy this.bitmap
	ImageDestroy this.bitmap_scaled
	
end destructor




function screen_output_proto.imagescale(byval s as fb.Image ptr, _
                    byval w as integer, _
                    byval h as integer) as fb.Image ptr
  #macro SCALELOOP()
  for ty = 0 to t->height-1
    ' address of the row
    pr=ps+(y shr 20)*sp
    x=0 ' first column
    for tx = 0 to t->width-1
      *pt=pr[x shr 20]
      pt+=1 ' next column
      x+=xs ' add xstep value
    next
    pt+=tp ' next row
    y+=ys ' add ystep value
  next
  #endmacro
  ' no source image
  if s        =0 then return 0
  ' source widh or height legal ?
  if s->width <1 then return 0
  if s->height<1 then return 0
  ' target min size ok ?
  if w<2 then w=1
  if h<2 then h=1
  ' create new scaled image
  dim as fb.Image ptr t=ImageCreate(w,h,RGB(0,0,0))
  ' x and y steps in fixed point 12:20
  dim as Long xs=&H100000*(s->width /t->width ) ' [x] [S]tep
  dim as Long ys=&H100000*(s->height/t->height) ' [y] [S]tep
  dim as integer x,y,ty,tx
  select case as const s->bpp
  case 1 ' color palette
    dim as ubyte    ptr ps=cptr(ubyte ptr,s)+32 ' [p]ixel   [s]ource
    dim as uinteger     sp=s->pitch             ' [s]ource  [p]itch
    dim as ubyte    ptr pt=cptr(ubyte ptr,t)+32 ' [p]ixel   [t]arget
    dim as uinteger     tp=t->pitch - t->width  ' [t]arget  [p]itch
    dim as ubyte    ptr pr                      ' [p]ointer [r]ow
    SCALELOOP()
  case 2 ' 15/16 bit
    dim as ushort   ptr ps=cptr(ushort ptr,s)+16
    dim as uinteger     sp=(s->pitch shr 1)
    dim as ushort   ptr pt=cptr(ushort ptr,t)+16
    dim as uinteger     tp=(t->pitch shr 1) - t->width
    dim as ushort   ptr pr
    SCALELOOP()
  case 4 ' 24/32 bit
    dim as ulong    ptr ps=cptr(Ulong ptr,s)+8
    dim as uinteger     sp=(s->pitch shr 2)
    dim as ulong    ptr pt=cptr(Ulong ptr,t)+8
    dim as uinteger     tp=(t->pitch shr 2) - t->width
    dim as ulong    ptr pr
    SCALELOOP()
  end select
  return t
  #undef SCALELOOP
end function


sub screen_output_proto.draw_paths (	path as path_proto ptr, _
										position as vec_2d, _
										control_next as vec_2d, _
										control_prev as vec_2d)
	
	dim _point as _point_proto ptr

	dim segment as segment_proto
	
	dim _color as Ulong
	
	while (path <> NULL)
	
		_point = path->_point

		
		'draw the last segment (mouse position)
		if (_point <> NULL) andalso path->is_working_path then 
		
				segment.p1 = projected ( _point->position )
				segment.p2 = projected ( position ) 
				 
				segment.h1 = projected (_point->position + _point->control_prev)
				segment.h2 = projected ( position + control_next )				
				 
				draw_segment ( segment.p1.x, segment.p1.y, _
							   segment.h1.x, segment.h1.y, _
							   segment.p2.x, segment.p2.y, _
							   segment.h2.x, segment.h2.y, _
							   C_BLUE, path->is_working_path)
							   
				circle this.canvas, ( projected (position).x, projected (position).y), 3, C_ORANGE,,,, F
							   
				line this.canvas, 	( segment.p1.x, segment.p1.y) - _
									( segment.h1.x, segment.h1.y), C_DARK_GRAY
				circle this.canvas, (segment.h1.x, segment.h1.y), 2, C_RED,,,, F

		
		end if
		
		'draw the whole path				
		while (_point <> NULL)
		
			
			if (_point->next_p) then
			
				segment.p1 = projected ( _point->position ) 
				segment.p2 = projected (  _point->next_p->position ) 
				
				segment.h1 = projected (_point->position + _point->control_next) 				
				segment.h2 = projected (_point->next_p->position + _point->next_p->control_prev) 
				
				if path->is_working_path then
					_color = C_BLUE 'this.rgb_best_contrast(point (segment.p1.x, segment.p1.y, this.canvas), 100)
				elseif path->is_selected then
					_color = C_RED
				else
					_color = C_GRAY
				end if
				
				'_color = iif (path->is_working_path, C_BLUE, C_DARK_GRAY)
				
				draw_segment ( segment.p1.x, segment.p1.y, _
							   segment.h1.x, segment.h1.y, _
							   segment.p2.x, segment.p2.y, _
							   segment.h2.x, segment.h2.y, _
							   _color, path->is_working_path)
				
				if 	path->is_selected then			   
					line this.canvas, (segment.p1.x-2, segment.p1.y-2)- step(4,4), C_WHITE, BF
					line this.canvas, (segment.p1.x-2, segment.p1.y-2)- step(4,4), C_GRAY, B
				end if
				
				
				if 	path->is_working_path then			   
					circle this.canvas, (segment.p1.x, segment.p1.y), 2, C_RED,,,, F
				end if
				
				
				
			else
				'highlight the last point of the working path if the user's pointer is near
				if 	path->is_working_path then
				
					dim _dist as vec_2d = ( projected ( position ) - projected ( _point->position ) )
					
					if _dist.lenght < MIN_SNAP_DIST then
					
						circle ( projected ( _point->position ).x, projected ( _point->position ).y), 3, C_DARK_GREEN,,,, F
						circle ( projected ( _point->position ).x, projected ( _point->position ).y), 2, C_WHITE,,,, F
					
					else
					
						circle ( projected ( _point->position ).x, projected ( _point->position ).y), 2, C_RED,,,, F
					
					end if

				end if
				
				
			
			end if

			_point = _point->next_p
		
		wend
		
		path = path->next_p
		
	wend

end sub

function screen_output_proto.mix(a as single, b as single, t as single) as single
    ' degree 1
    return (a * (1.0 - t) + b*t)
end function

function screen_output_proto.BezierQuadratic(A as single, B as single, C as single, t as single) as single
    ' degree 2
    dim as single AB, BC
    AB = mix(A, B, t)
    BC = mix(B, C, t)
    return mix(AB, BC, t)
end function

function screen_output_proto.BezierCubic(A as single, B as single, C as single, D as single, t as single) as single
    ' degree 3
    dim as single ABC, BCD
    ABC = this.BezierQuadratic(A, B, C, t)
    BCD = this.BezierQuadratic(B, C, D, t)
    return this.mix(ABC, BCD, t)
end function

sub screen_output_proto.draw_segment (	x1 as single, 	y1 as single,  _
										x1h as single, 	y1h as single, _
										x2 as single, 	y2 as single,  _
										x2h as single, 	y2h as single, _
										_color as Ulong, is_working_path as boolean)
										
	dim as single t, tx, ty, old_tx, old_ty
	
	for t = 0 to 1.0 step SEGMENT_PRECISION
	
		tx = BezierCubic( x1, x1h, x2h, x2, t)
		ty = BezierCubic( y1, y1h, y2h, y2, t)
		
		if (t) then
		
			if is_working_path then
				line this.canvas, (old_tx, old_ty)-(tx,ty), _color
				'draw_thick_line(old_tx, old_ty, tx, ty, 2, _color)	
			else
				line this.canvas, (old_tx, old_ty)-(tx,ty), _color
			end if

		end if
		
		old_tx = tx
		old_ty = ty
		
	next t

end sub

sub screen_output_proto.draw_selection_area (	start_pos as vec_2d, _
												end_pos as vec_2d)
							
	dim as vec_2d p1 , p2
	
	p1 =  projected (start_pos)
	p2 =  projected (end_pos)
	
	line this.canvas, 	( p1.x, p1.y ) - ( p2.x, p2.y ) , C_WHITE, B
	line this.canvas, 	( p1.x+1, p1.y+1 ) - ( p2.x+1, p2.y+1 ) , C_DARK_GRAY, B
										
end sub


function screen_output_proto.projected (v as vec_2d) as vec_2d

	return v * this.zoom + this.pan

end function

sub screen_output_proto.draw_control_points (	position as vec_2d, _
										control_next as vec_2d, _
										control_prev as vec_2d)
										
	dim as vec_2d p, h1, h2
	
	p = projected (position)
	h1 = projected (position + control_next)
	h2 = projected (position + control_prev)
										
	line this.canvas, 	( p.x, p.y ) - ( h1.x, h1.y ) , C_DARK_GRAY
	line this.canvas, 	( p.x, p.y ) - ( h2.x, h2.y ) , C_DARK_GRAY
	
	circle this.canvas, (p.x, p.y), 2, C_RED,,,, F
	circle this.canvas, (h1.x, h1.y), 2, C_RED,,,, F
	circle this.canvas, (h2.x, h2.y), 2, C_RED,,,, F
								
end sub
