type layer_proto

	declare sub add_path ()
	declare sub delete_all_paths ()
	declare sub delete_working_path ()
	declare sub delete_selected_paths ()
	
	declare sub select_paths (	start_pos as vec_2d, _
								end_pos as vec_2d )
								
	declare sub deselect_all_paths ()
	
	declare property get_path() as path_proto ptr
	
	declare destructor()

	path as path_proto ptr
	
	private:
	
	declare function node_in_rect (_point as vec_2d, top_left as vec_2d, bottom_right as vec_2d) as boolean
	
end type

property layer_proto.get_path() as path_proto ptr

	return path

end property

sub layer_proto.deselect_all_paths ()

	dim as path_proto ptr p
	
	p = this.path
	
	while p <> NULL
	
		p->is_selected = false
		p = p->next_p
	
	wend

end sub

'transverse each path and each point of each path
sub layer_proto.select_paths  (	start_pos as vec_2d, _
								end_pos as vec_2d )								
								
	'get boundings of the selection
	
	dim as vec_2d top_left, bottom_right
	
	top_left.x = iif (start_pos.x < end_pos.x, start_pos.x, end_pos.x)
	top_left.y = iif (start_pos.y < end_pos.y, start_pos.y, end_pos.y)
	
	bottom_right.x = iif (start_pos.x > end_pos.x, start_pos.x, end_pos.x)
	bottom_right.y = iif (start_pos.y > end_pos.y, start_pos.y, end_pos.y)
	
	#IFDEF DEBUG
		utility_consmessage    ("Paths selected: ")
	#ENDIF
	
	dim as path_proto ptr p
	
	p = this.path
	
	while p <> NULL
	
		dim node as _point_proto ptr
		node = p->_point
		
		while node <> NULL
			
			if node_in_rect (node->position, top_left, bottom_right) then
						
				p->is_selected = true
				
				#IFDEF DEBUG
					utility_consmessage    (str (hex(p)))
				#ENDIF
				
				exit while
				
			end if
		
			node = node->next_p
			
		wend
	
		p = p->next_p
	
	wend
	
	delete (p)
	p = NULL
	
	#IFDEF DEBUG
		utility_consmessage    ("---")
	#ENDIF
	
end sub

function layer_proto.node_in_rect (_point as vec_2d, top_left as vec_2d, bottom_right as vec_2d) as boolean

	if 	_point.x > top_left.x andalso _point.x < bottom_right.x andalso _
		_point.y > top_left.y andalso _point.y < bottom_right.y then
		
		return true
		
	else
	
		return false
		
	end if

end function

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

sub layer_proto.delete_selected_paths()

    dim as path_proto ptr tmp = path, prev
       
    dim path_deleted as boolean = false
        
    while (tmp <> NULL andalso tmp->is_selected) 
    
        path = tmp->next_p
        delete(tmp) 
        path_deleted = true
        tmp = path  
        
    wend 
    
    while (tmp <> NULL) 
    
        while (tmp <> NULL andalso tmp->is_selected = false) 
        
            prev = tmp
            tmp = tmp->next_p
            
        wend 
        
        if (tmp = NULL) then exit sub
    
        prev->next_p = tmp->next_p
        
        delete(tmp) 
        
        path_deleted = true
        
        tmp = prev->next_p 
    wend
    
    if path_deleted then this.add_path()
    
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
