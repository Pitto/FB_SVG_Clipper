type vec_2d

	declare constructor ()
	declare constructor (v as vec_2d)
	declare constructor (x_ as single, y_ as single)

	x as single
	y as single
	w as single
	
	declare function lenght () as single
	declare function sq_lenght () as single
	declare function angle () as single
	
end type

operator + (byref v1 as vec_2d, byref v2 as vec_2d) as vec_2d
	return type<vec_2d> (v1.x + v2.x, v1.y + v2.y)
end operator

operator <> (byref v1 as vec_2d, byref v2 as vec_2d) as boolean
	if v1.x <> v2.x orelse v1.y <> v2.y then
		return true
	else
		return false
	end if
	
end operator

operator - (byref v1 as vec_2d, byref v2 as vec_2d) as vec_2d
	return type<vec_2d> (v1.x - v2.x, v1.y - v2.y)
end operator

operator - (byref v1 as vec_2d) as vec_2d
	return type<vec_2d> (-v1.x, -v1.y)
end operator

operator * (byref v1 as vec_2d, byref v2 as single) as vec_2d
	return type<vec_2d> (v1.x * v2, v1.y * v2)
end operator

operator / (byref v1 as vec_2d, byref v2 as single) as vec_2d
	return type<vec_2d> (v1.x / v2, v1.y / v2)
end operator

function vec_2d.lenght () as single
	return sqr (this.x * this.x + this.y * this.y)
end function

function vec_2d.sq_lenght () as single
	return (this.x * this.x + this.y * this.y)
end function

function vec_2d.angle () as single
	return atan2(this.y, this.x)
end function

function lerp (t as single, byref v1 as vec_2d, byref v2 as vec_2d) as vec_2d
	return type<vec_2d> (v1 * (1-t) + v2 * t)
end function

constructor vec_2d (byref v1 as vec_2d)
	this.x = v1.x
	this.y = v1.y
end constructor

constructor vec_2d (x_ as single, y_ as single)
	this.x = x_
	this.y = y_
end constructor

constructor vec_2d ()
	this.x = 0
	this.y = 0
end constructor





