type _point_proto

	position as vec_2d
	
	control_prev as vec_2d
	control_next as vec_2d
	
	is_selected as boolean
	
	is_slope_constant as boolean
	
	next_p as _point_proto ptr

end type
