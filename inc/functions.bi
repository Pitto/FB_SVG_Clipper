declare function absolute (position as vec_2d, zoom as single, pan as vec_2d) as vec_2d

function absolute (position as vec_2d, zoom as single, pan as vec_2d) as vec_2d

	return position / zoom  + ( -pan / zoom)

end function

Sub utility_consmessage (Byref e As String)
  Dim As Integer f = Freefile()
  Open cons For Output As #f
  Print #f, e
  Close #f
End Sub




' public domain function by Darel Rex Finley, 2006
' Determines the intersection point of the line segment defined by points A and B
' with the line segment defined by points C and D.

' Returns true if the intersection point was found, and stores that point in X,Y.
' Returns false if there is no determinable intersection point, in which case X,Y will
' be unmodified.

function lineSegmentIntersection	(Ax as single, Ay as single,_
								Bx as single, By as single,_
								Cx as single, Cy as single,_
								Dx as single, Dy as single,_
								X as single ptr, Y as single ptr) as boolean

	dim as single distAB, theCos, theSin, newX, ABpos 

	' Fail if either line segment is zero-length.
	if (Ax = Bx andalso Ay = By orelse Cx = Dx andalso Cy = Dy) then return false

	' Fail if the segments share an end-point.
		if (	Ax = Cx andalso Ay = Cy orelse Bx = Cx andalso By = Cy _
				orelse 	Ax = Dx andalso Ay = Dy orelse Bx = Dx andalso By = Dy) then
				return false
		end if

	' (1) Translate the system so that point A is on the origin.
	Bx- = Ax
	By- = Ay
	Cx- = Ax
	Cy- = Ay
	Dx- = Ax
	Dy- = Ay

	' Discover the length of segment A-B.
	distAB = sqr(Bx*Bx+By*By)

	' (2) Rotate the system so that point B is on the positive X axis.
	theCos = Bx/distAB
	theSin = By/distAB
	newX = Cx*theCos+Cy*theSin
	Cy = Cy*theCos-Cx*theSin
	Cx = newX
	newX = Dx*theCos+Dy*theSin
	Dy = Dy*theCos-Dx*theSin
	Dx = newX

	' Fail if segment C-D doesn't cross line A-B.
	if (Cy<0. andalso Dy<0. orelse Cy> = 0. andalso Dy> = 0.) then return false

	' (3) Discover the position of the intersection point along line A-B.
	ABpos = Dx+(Cx-Dx)*Dy/(Dy-Cy)

	' Fail if segment C-D crosses line A-B outside of segment A-B.
	if (ABpos<0. orelse ABpos>distAB) then return false

	' (4) Apply the discovered position to line A-B in the original coordinate system.
	*X = Ax+ABpos*theCos
	*Y = Ay+ABpos*theSin

	' Success.
	return true

end function
