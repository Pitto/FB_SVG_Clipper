type path_proto
	
	declare constructor()
	declare destructor()
	
	declare sub add_point (v1 as vec_2d, v2 as vec_2d, v3 as vec_2d, zoom as single, is_loading_from_file as boolean)
	declare sub delete_all_points ()
	declare sub delete_last_point ()
	declare sub delete_first_point ()
	
	declare function number_of_points() as Ulong
	
	_point 		as _point_proto ptr
		
	next_p 		as path_proto ptr
	
	is_selected 	as boolean
	is_working_path as boolean
	is_closed 		as boolean
	
	private:
	
	declare function _first_point() as vec_2d
	

end type

sub path_proto.delete_first_point ()

	dim as _point_proto ptr p
	
	p = this._point
	
	if p andalso p->next_p then
	
		this._point = p->next_p
		
		delete (p)
	
		p = NULL
		
	end if
	
end sub


sub path_proto.delete_last_point ()

	dim as _point_proto ptr p, t
	
	p = this._point
	
	if p->next_p = NULL then exit sub
	
	while p->next_p->next_p <> NULL
	
		p = p->next_p
	
	wend
	
	t = p->next_p
	
	p->next_p = NULL
	
	delete (t)

	t = NULL
	
end sub

function path_proto.number_of_points() as Ulong

	dim p as _point_proto ptr
	dim i as Ulong = 1
	
	p = _point
	
	while p->next_p
	
		p = p->next_p
		i += 1

	wend
	
	return i

end function

function path_proto._first_point() as vec_2d

	dim p as _point_proto ptr
	
	p = _point
	
	while p->next_p
	
		p = p->next_p

	wend
	
	return p->position

end function

sub path_proto.delete_all_points ()

	dim temp as _point_proto ptr
	
	#IFDEF DEBUG
		utility_consmessage    ("---deleting path")
	#ENDIF
	
	while (_point <> NULL)
		
		temp = _point
		_point = temp->next_p
		#IFDEF DEBUG
			utility_consmessage    ("    deleting point  ->" + hex(temp))
		#ENDIF
		delete(temp)
		temp = NULL
		
	wend

end sub

sub path_proto.add_point(v1 as vec_2d, v2 as vec_2d, v3 as vec_2d, zoom as single, is_loading_from_file as boolean)

	dim as _point_proto ptr p = callocate(sizeof(_point_proto))
	
	if p <> NULL then
	
		p->is_selected = false
	
		p->next_p = _point
		
		_point = p
		
		dim _dist as vec_2d = ( v1 - this._first_point() )
		
		
		'snap to the first point of the path and close the path itself
		'disable this function when loading from a file 
				
		if 	is_loading_from_file = false andalso _
			this.number_of_points() > 1 andalso _
			(_dist.lenght() * zoom ) < MIN_SNAP_DIST   then
			
		
			v1.x = this._first_point().x
			v1.y = this._first_point().y
			this.is_closed = true
			this.is_working_path = false
		
		end if
		
		_point->position = v1
		_point->control_prev = v2
		_point->control_next = v3
		
		_point->is_slope_constant  = iif (v2.x = -v3.x andalso v2.y = -v3.y, true, false)
		

		#IFDEF DEBUG
			utility_consmessage    ("added a point @ " + hex(p) + ": " _
									+ str(v1.x) + ", "+ str(v1.y) + " | " _
									+ str(v2.x) + ", "+ str(v2.y) + " | " _
									+ str(v3.x) + ", "+ str(v3.y) + " | " _
									+ str(_point->is_slope_constant))
									
		#ENDIF
	
	end if	

end sub

constructor path_proto ()

	#IFDEF DEBUG
		utility_consmessage    ("here's the path constructor")
	#ENDIF

end constructor

destructor path_proto
	
	'important
	this.delete_all_points ()

end destructor
