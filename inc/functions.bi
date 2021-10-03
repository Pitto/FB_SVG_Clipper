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
