'this code is released under the terms of
'GNU LESSER GENERAL PUBLIC LICENSE
'Version 3, 29 June 2007
'see COPING.txt in root folder

#include "fbgfx.bi"
#include "file.bi"
#include "crt/string.bi"
#Include "crt/math.bi"
#include "inc/def.bi"
#include "inc/vec2d.bi"
#include "inc/functions.bi"
#include "inc/fbg-keyboard.bi"
#include "inc/fbg-mouse.bi"
#include "inc/tool.bi"
#include "inc/jpgloader.bi"
#include "inc/point.bi"
#include "inc/segment.bi"
#include "inc/path.bi"
#include "inc/layer.bi"
#include "inc/file_handler.bi"
#include "inc/screen_output.bi"
#include "inc/pan_and_zoom.bi"


#IFDEF DEBUG
	utility_consmessage    (APP_NAME + " " + Str(APP_VERSION))
	utility_consmessage    ("---------------------")
#ENDIF

dim fbvg_filename 			as string = str(Command(1))
dim img_filename 			as string = str(Command(2))
'dim svg_export_mode			as string = str(Command(3))

if __FB_ARGC__ > 1 then
	if not (FileExists(img_filename))  then
		print "ERROR: image file doesn't exist"
		print "ENDING PROGRAM"
		sleep
		end
	end if
	if not (FileExists(fbvg_filename))  then
		print "WARNING: the specified fbvg file doesnt' exist"
		print "it will be created"
	end if
	'if svg_export_mode  = "" then
		'print "WARNING: no SVG export mode selected"
		'print "using default settings: -P (distinct paths)"
	'end if
	
	
else
	print "ERROR - To launch the program"
	print "input as arguments the name of the fvg file to open"
	print "(if it doesn't exist it will be created)"
	print "a valid JPG file (no progressive JPG)"
	print "and (as optional argument) the SVG export mode:"
	print "-P (distinct paths)"
	print "-C (compound path)"
	print "-L (masked image linked)"
	print "-E (masked image embedded)"
	print "example: fbvg filename.fvg filename.jpg -P"
	print "---"
	print "see help.txt for further commands"
	print ""
	sleep
	end 
end if

var screen_output 	= screen_output_proto (img_filename)
var keyboard 		= KeyboardInput
var mouse 			= MouseInput()
var tool 			= tool_proto()
var pan_and_zoom			= pan_and_zoom_proto( 	(SCR_W - screen_output.bitmap_width) \2 ,_
													(SCR_H - screen_output.bitmap_height) \2, _
													screen_output.bitmap_width,_
													screen_output.bitmap_height )
													
dim layer as layer_proto

dim e as Fb.Event

var file = file_handler_proto (fbvg_filename, img_filename, @layer)


'important!
layer.add_path()

SetMouse SCR_W\2, SCR_H\2,0

do
	'poll events  
	do while( screenEvent( @e ) )
		keyboard.onEvent( @e )
		mouse.onEvent( @e )
	loop
  
	'exit
	if keyboard.pressed (Fb.SC_Q) andalso keyboard.pressed (Fb.SC_CONTROL)  then exit do
	'save file
	if keyboard.pressed (Fb.SC_S) andalso keyboard.pressed (Fb.SC_CONTROL) then file.save(layer.get_path)
	'export SVG
	if keyboard.pressed (Fb.SC_E) andalso keyboard.pressed (Fb.SC_CONTROL) then
		file.svg_set_export_mode = BITMAP_LINKED
		file.export_svg(layer.get_path, screen_output.bitmap_width, screen_output.bitmap_height)
	end if
	
	
	if keyboard.pressed (Fb.SC_DELETE) then
		
		select case tool.selected
		
			case TOOL_PEN
		
				if keyboard.held (Fb.SC_CONTROL) then
					'delete the whole path
					layer.delete_working_path()
				else
					'delete last node of the path
					if layer.path -> is_closed = false then 
						layer.path->delete_first_point ()
					end if
				end if
				
			case TOOL_SELECTION
				
				layer.delete_selected_paths()

		end select
		
	end if
	
	
	tool.update (@keyboard)
	
	static as vec_2d 	position, control_next, control_next_old, _
						control_prev, start_drag_position, end_drag_position
					
		
	select case tool.selected
	
		case TOOL_SELECTION
			if mouse.released(Fb.BUTTON_LEFT) then
			
				layer.select_paths  (	start_drag_position, _
										end_drag_position)				
			
			end if
			
			if mouse.pressed(Fb.BUTTON_LEFT) then
			
				layer.deselect_all_paths () 		
			
			end if
			
			if mouse.held(Fb.BUTTON_LEFT) then
			
				start_drag_position = absolute ( type <vec_2d> (mouse.startX, mouse.startY),_
												pan_and_zoom._zoom, pan_and_zoom._pan)
				end_drag_position	= absolute ( type <vec_2d> (mouse.X, mouse.Y), _
												pan_and_zoom._zoom, pan_and_zoom._pan)
			
			end if
			
		case TOOL_DIRECT_SELECTION
			if mouse.released(Fb.BUTTON_LEFT) then
			end if
	
		case TOOL_HAND
		
			static as vec_2d pan_old
		
			if mouse.held(Fb.BUTTON_LEFT) then
				pan_and_zoom._pan = pan_old + type<vec_2d> (mouse.deltaX, mouse.deltaY)
			else
				pan_old = pan_and_zoom._pan
			end if
		
			if mouse.released(Fb.BUTTON_LEFT) then
				#IFDEF DEBUG	
					utility_consmessage    ("pan (x, y): " + str (pan_and_zoom._pan.x) + " " + str (pan_and_zoom._pan.y))
				#ENDIF
			end if
			
		case TOOL_PEN
		
			if mouse.released(Fb.BUTTON_LEFT) then
			
				if layer.path->is_closed then
				
					layer.add_path()
					layer.path->add_point (	position, control_prev, control_next, pan_and_zoom._zoom, false)
					
				else
				
					layer.path->add_point (	position, control_prev, control_next, pan_and_zoom._zoom, false)
					
				end if
				
			end if
			
			if mouse.held(Fb.BUTTON_LEFT) then
				position = absolute ( type <vec_2d> (mouse.startX, mouse.startY), pan_and_zoom._zoom, pan_and_zoom._pan)
				control_prev = type <vec_2d> (mouse.deltaX, mouse.deltaY) / pan_and_zoom._zoom
				
				if multikey (Fb.SC_ALT) then
					control_next = control_next_old
					
				else
					control_next = type <vec_2d> (-mouse.deltaX, -mouse.deltaY) / pan_and_zoom._zoom
					control_next_old = control_next
					
				end if
				
			else
				position = absolute ( type <vec_2d> (mouse.X, mouse.Y), pan_and_zoom._zoom, pan_and_zoom._pan)
				control_next = type <vec_2d> (0,0) / pan_and_zoom._zoom
				control_prev = type <vec_2d> (0,0) / pan_and_zoom._zoom
			end if
			
	end select
	

 	pan_and_zoom.update	(mouse.verticalWheel, mouse.X, mouse.Y)
	
	screen_output.get_pan_and_zoom (pan_and_zoom._pan, pan_and_zoom._zoom)
	screen_output.is_mouse_held = mouse.held(Fb.BUTTON_LEFT)
	
	screen_output.draw_bitmap ()
	screen_output.draw_grid ()
	screen_output.draw_paths (layer.get_path, position, control_next, control_prev)
	
	screen_output.draw_control_points (position, control_next, control_prev)
	
	if tool.selected = TOOL_SELECTION andalso mouse.held(Fb.BUTTON_LEFT) then
	
			screen_output.draw_selection_area (start_drag_position, end_drag_position)
	
	end if
	
	
	screen_output.draw_pointer (mouse.X, mouse.Y, tool.selected)
	
	screen_output.display_all
   
	sleep 20,1
	
loop








