#INCLUDE ONCE "crt/math.bi" 

type pan_and_zoom_proto

	declare sub update(hWheel as integer, _x as integer, _y as integer)
	declare constructor(x_ as integer, y_ as integer, w as integer, h as integer)
	
	declare property 	_pan 	() as vec_2d
	declare property 	_pan 	(_val as vec_2d)
	declare property  	_zoom 	() as single
	
	private:

	scalechange 			as single
	pan 					as vec_2d
	zoom 					as single
	old_zoom 				as single
	hWheel_value_old		as integer
	
	artwork_w				as integer
	artwork_h				as integer

end type

property pan_and_zoom_proto._pan (_val as vec_2d) 
	this.pan = _val
end property

property pan_and_zoom_proto._pan () as vec_2d
	return ( this.pan )
end property

property pan_and_zoom_proto._zoom () as single
	return ( this.zoom )
end property

constructor pan_and_zoom_proto (x_ as integer, y_ as integer, w as integer, h as integer)

	zoom 			= 1.0f
	old_zoom 		= 1.0f
	pan 			= type<vec_2d> (x_,y_)
	scalechange 	= 0.0f
	
	artwork_w		= w
	artwork_h		= h
	
end constructor

sub pan_and_zoom_proto.update(hWheel as integer, _x as integer, _y as integer)

	dim mouse as vec_2d = vec_2d(_x, _y)
	dim mouse_abs as vec_2d 
	
	'see https://stackoverflow.com/questions/2916081/zoom-in-on-a-point-using-scale-and-translate
	
	if (hWheel - hWheel_value_old) then
	
		zoom = pow (1.1f, hWheel)
		
		'if zoom > MAX_ZOOM then zoom = MAX_ZOOM
		'if zoom < MIN_ZOOM then zoom = MIN_ZOOM
		
		mouse_abs 	= mouse / old_zoom  + ( -pan / old_zoom )
		scalechange = zoom - old_zoom
		pan 		= pan + (-(mouse_abs * scalechange))
		
		#IFDEF DEBUG	
			utility_consmessage    ("---" )
			utility_consmessage    ("mouse coords:         " + str(mouse.x) + " " + str(mouse.y))
			utility_consmessage    ("absolute mouse coords:" + str(mouse_abs.x) + " " + str(mouse_abs.y))
			utility_consmessage    ("zoom factor:          " + str(zoom))
			utility_consmessage    ("pan:                  " + str(pan.x) + " " + str(pan.y))
			utility_consmessage    ("scalechange:          " + str(scalechange))
		#ENDIF
		
		old_zoom = zoom
		
	end if
	
	hWheel_value_old = hWheel


end sub
