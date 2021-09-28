ENUM svg_export_mode_enum 

	DISTINCT_PATHS,
	COMPOUND_PATH,
	BITMAP_LINKED,
	BITMAP_EMBEDDED

END ENUM

type file_handler_proto

	declare constructor (fn as string, layer as layer_proto ptr)

	declare sub save (path as path_proto ptr)
	declare sub load (layer as layer_proto ptr)
	declare sub export_svg (path as path_proto ptr)
	
	declare property svg_set_export_mode (mode as svg_export_mode_enum)
	
	private:
	
	declare sub split (array() as string, textline as string, divider as string)
	
	filename as string
	
	svg_export_mode as svg_export_mode_enum

end type

property file_handler_proto.svg_set_export_mode (mode as svg_export_mode_enum)

	this.svg_export_mode = mode

end property

constructor file_handler_proto (fn as string, layer as layer_proto ptr)

	this.filename = fn
	this.load(layer)
	
	this.svg_export_mode = DISTINCT_PATHS

end constructor

sub file_handler_proto.export_svg(path as path_proto ptr)

	
	#IFDEF DEBUG
		utility_consmessage    ("")
		utility_consmessage    ("---------------------------------")
		utility_consmessage    ("please wait... exporting SVG FILE")
	#ENDIF
	
	dim t as double = Timer

	dim _point as _point_proto ptr
	dim file_extension as string = ".svg"
	
	Dim ff As UByte
	ff = FreeFile
	Open this.filename + file_extension for output As #ff
	
	'SVG file header info
	
	Print #ff, "<?xml version='1.0' standalone='no'?>"
	Print #ff, "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>"
	Print #ff, "<svg  version='1.1' xmlns='http://www.w3.org/2000/svg'>"
	Print #ff, "<desc>" + APP_NAME + " " + APP_VERSION + " - Export file</desc>"
	
	while path 
	
		_point = path->_point
		
		dim line_output as string = ""
		
		line_output += "<path stroke-width = '0.2' d = 'M "

		dim first_coord as boolean = true
		dim first_coord_txt as string = ""
		
		while _point
		
			if _point->next_p then
			
				first_coord_txt = iif (first_coord, str(_point->position.x) + " "+ str(_point->position.y) + " C " , " ")

				line_output = 	line_output + _
								first_coord_txt + _
								str(_point->position.x + _point->control_next.x) + " " + _
								str(_point->position.y + _point->control_next.y) + " " + _
								str(_point->next_p->position.x + _point->next_p->control_prev.x) + " " + _
								str(_point->next_p->position.y + _point->next_p->control_prev.y) + " " + _
								str(_point->next_p->position.x ) + " " + _
								str(_point->next_p->position.y ) + " " 
		
			end if
			
			first_coord = false
			
			_point = _point->next_p
		
		wend
		
		path = path->next_p
		
		
		
		
		line_output += "' stroke='black' fill='transparent'/>"
			
		Print #ff, line_output
		
	wend
	
	Print #ff, "</svg>"
	
	Close #ff
	
	#IFDEF DEBUG
		utility_consmessage    ("SVG FILE EXPORTED -> " + filename + file_extension)
	#ENDIF
	
	
	#IFDEF DEBUG
			utility_consmessage    ("---")
			utility_consmessage    ("exported in " + str(Timer-t) + " sec.")
	#ENDIF
	

end sub

sub file_handler_proto.load (layer as layer_proto ptr)

	dim as integer filenum, res
	dim as string txt_line

	filenum = Freefile
	res 	= Open (this.filename, For Input, As #filenum)

	if res = 0 then 
		While (Not Eof(filenum))
			
			'Get one whole text line
			Line Input #filenum, txt_line
			
			if len (txt_line) then
			
				'split the semicolon
				redim splitted_semicolon (0 to 0) as string
				
				'len(textline)-1 to avoid last comma of the line
				split (splitted_semicolon(), mid(txt_line,1,len(txt_line)-1), ";")
				
				layer->add_path()
				
				for i as integer = Ubound(splitted_semicolon) to 0 step -1
				
					#IFDEF DEBUG
						utility_consmessage    (str (i) + " " + splitted_semicolon (i))
					#ENDIF

					redim splitted_comma (0 to 0) as string
					
					'split the comma
					split(splitted_comma(), splitted_semicolon(i), ",")
					
					
					layer->path->add_point (type <vec_2d> (Csng (splitted_comma(0)), Csng (splitted_comma(1))), _
											type <vec_2d> (Csng (splitted_comma(2)), Csng (splitted_comma(3))), _
											type <vec_2d> (Csng (splitted_comma(4)), Csng (splitted_comma(5))), _
											1.0, true)
				next i
				
			
			end if

		Wend

		Close #filenum
	else
	
		#IFDEF DEBUG
			
				utility_consmessage    ("error opening file: " + this.filename)
				
		#ENDIF
	
	end if

end sub

sub file_handler_proto.split (array() as string, textline as string, divider as string)

	'modified version of a snippet by MrSwiss
	'Loading a CSV file into an array
	'https://www.freebasic.net/forum/viewtopic.php?t=25693

	dim as string token
	dim as integer pos1 = 1, pos2   

	do
		'' next divider position
		pos2 = instr(pos1, textline, divider)
		'' if new divider found, take the substring between the last divider and it
		
		if pos2 > 0 Then
			token = mid(textline, pos1, pos2 - pos1)    ' calc. len (new)
			array(ubound(array)) = token
			redim preserve array(0 to ubound(array) + 1)
		else
			token = Mid(textline, pos1)
			array(ubound(array)) = token
		end if
	   
		pos1 = pos2 + 1 ' added + 1
		
	loop until pos2 = 0

end sub

sub file_handler_proto.save (path as path_proto ptr)

	dim _point as _point_proto ptr
	
	Dim ff As UByte
	ff = FreeFile
	Open this.filename for output As #ff
	
	while path 
	
		_point = path->_point
		
		dim line_output as string = ""
		
		while _point

			line_output = 	line_output + _
							str(_point->position.x) + "," + _
							str(_point->position.y) + "," + _
							str(_point->control_prev.x) + "," + _
							str(_point->control_prev.y) + "," + _
							str(_point->control_next.x) + "," + _
							str(_point->control_next.y)	+ ";"				
		
			_point = _point->next_p
		
		wend
		
		path = path->next_p
		
		Print #ff, line_output
		
	wend
	
	Close #ff
	
	#IFDEF DEBUG
		utility_consmessage    ("FILE SAVED -> " + this.filename)
	#ENDIF
	
		

end sub
