type layer_proto

	declare sub add_path ()
	declare sub delete_all_paths ()
	declare sub delete_working_path ()
	
	declare property get_path() as path_proto ptr
	
	declare destructor()

	path as path_proto ptr
	
end type

property layer_proto.get_path() as path_proto ptr

	return path

end property

sub layer_proto.delete_working_path()

	dim as path_proto ptr p, prev
	
	p = this.path
	
	if p <> NULL andalso p->is_working_path then
	
		this.path = p->next_p
		delete (p)
		p = NULL
		
		this.add_path ()
		
		exit sub
	
	end if
	
	while p <> NULL andalso p->is_working_path = false
	
		prev = p
		p = p->next_p
	
	wend
	
	if p = NULL then exit sub
	
	prev->next_p = p->next_p
	
	delete (p)
	p = NULL
	

end sub

sub layer_proto.add_path ()

	if path <> NULL then
		path->is_working_path = false
	end if

	dim as path_proto ptr p = callocate(sizeof(path_proto))
	
	if p <> NULL then
	
		p->is_closed = false
		p->is_selected = false
		p->is_working_path = true
	
		p->next_p = path
		path = p
		
		#IFDEF DEBUG
			utility_consmessage    ("added a path  @ " + hex(p))
		#ENDIF
	
	end if	

end sub

destructor layer_proto()

	#IFDEF DEBUG
		utility_consmessage    ("--- DELETING ALL PATHS ---")
	#ENDIF

	this.delete_all_paths

end destructor

sub layer_proto.delete_all_paths()


	dim temp as path_proto ptr
	while (path <> NULL)
		
		temp = path
		path = temp->next_p
		#IFDEF DEBUG
			utility_consmessage    ("deleting path ->" + hex(temp))
		#ENDIF
	
		delete(temp)
		temp = NULL
	wend

end sub
