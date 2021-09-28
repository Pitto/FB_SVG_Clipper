ENUM tool_enum

	TOOL_SELECTION,
	TOOL_DIRECT_SELECTION,
	TOOL_PEN,
	TOOL_HAND

END ENUM

type tool_proto

	declare constructor()
	
	declare property selected as tool_enum
	'declare property is_hand_panning as boolean
	
	'declare property previous_selected as tool_enum
	
	declare sub update (keyb as KeyboardInput ptr)
	'declare function is_tool_changed () as boolean
	
	
	
	private:
	
	tool 		as tool_enum
	tool_old	as tool_enum
	hand_panning as boolean
	
end type

property tool_proto.selected as tool_enum

	return this.tool

end property

'property tool_proto.is_hand_panning as boolean

	'return this.hand_panning

'end property

'property tool_proto.previous_selected as tool_enum

	'return this.tool_old

'end property

constructor tool_proto ()

	tool = TOOL_PEN
	tool_old = tool
	hand_panning = false
	
end constructor

'function tool_proto.is_tool_changed () as boolean

	'dim result as boolean = iif (tool <> tool_old, true, false)

	'return result

'end function


sub tool_proto.update (keyb as KeyboardInput ptr)

	'if (keyb->pressed (Fb.SC_V)) then
		'this.tool = TOOL_SELECTION
		'#IFDEF DEBUG
			'utility_consmessage    ("TOOL: TOOL_SELECTION")
		'#ENDIF
	'end if
	
	'if (keyb->pressed (Fb.SC_A)) then
		'this.tool = TOOL_DIRECT_SELECTION
		'#IFDEF DEBUG
			'utility_consmessage    ("TOOL: TOOL_DIRECT_SELECTION")
		'#ENDIF
	'end if
	
	if (keyb->pressed (Fb.SC_P)) then
		this.tool = TOOL_PEN
		#IFDEF DEBUG
			utility_consmessage    ("TOOL: TOOL_PEN")
		#ENDIF
	end if
	
	'hand tool
	if (keyb->pressed (Fb.SC_H)) then
		this.tool = TOOL_HAND
		#IFDEF DEBUG
			utility_consmessage    ("TOOL: TOOL_HAND")
		#ENDIF
	end if
	''the hand tool may be used in conjunction with others tools
	'if (keyb->pressed (Fb.SC_SPACE)) then
		'this.tool_old = this.tool
		'this.tool = TOOL_HAND
		
		'this.hand_panning = true
		'#IFDEF DEBUG
			'utility_consmessage    ("TOOL: TOOL_HAND - start drag")
		'#ENDIF
	'end if
	
	'if (keyb->released (Fb.SC_SPACE)) then
		'this.tool = this.tool_old
		
		'this.hand_panning = false
		'#IFDEF DEBUG
			'utility_consmessage    ("TOOL: TOOL_HAND - end drag")
		'#ENDIF
	'end if

end sub



