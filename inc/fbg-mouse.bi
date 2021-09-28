
  type MouseInput
    public:
      declare constructor()
      declare constructor( as integer )
      declare destructor()
     
      declare property X() as integer
      declare property Y() as integer
      declare property deltaX() as integer
      declare property deltaY() as integer
      declare property startX() as integer
      declare property startY() as integer
      declare property horizontalWheel() as integer
      declare property verticalWheel() as integer

     
      declare sub onEvent( as any ptr )
     
      declare function pressed( as integer ) as boolean
      declare function released( as integer ) as boolean
      declare function held( as integer, as double = 0.0 ) as boolean
      declare function repeated( as integer, as double = 0.0 ) as boolean
      declare function drag( byval as integer ) as boolean
      declare function drop( byval as integer ) as boolean
     
    private:
      enum ButtonState
        None
        Pressed             = ( 1 shl 0 )
        AlreadyPressed      = ( 1 shl 1 )
        Released            = ( 1 shl 2 )
        AlreadyReleased     = ( 1 shl 3 )
        Held                = ( 1 shl 4 )
        HeldInitialized     = ( 1 shl 5 )
        Repeated            = ( 1 shl 6 )
        RepeatedInitialized = ( 1 shl 7 )
      end enum
     
      '' The bitflags for the button states
      as ubyte _state( any )
     
      as integer _
        _x, _y, _
        _sx, _sy, _
        _dx, _dy, _
        _hWheel, _
        _vWheel
     
      '' Caches when a button started being held/repeated
      as double _
        _heldStartTime( any ), _
        _repeatedStartTime( any )
     
      '' The mutex for this instance
      as any ptr _mutex
     
      '' Current state
      as boolean _
        _pressed, _
        _dragging, _
        _dropped
  end type
 
  constructor MouseInput()
    constructor( 3 )
  end constructor
 
  constructor MouseInput( buttons as integer )
    _mutex = mutexCreate()
   
    redim _state( 0 to buttons - 1 )
    redim _heldStartTime( 0 to buttons - 1 )
    redim _repeatedStartTime( 0 to buttons - 1 )
    
   
  end constructor
 
  destructor MouseInput()
    mutexDestroy( _mutex )
  end destructor
 
  property MouseInput.X() as integer
    return( _x )
  end property
 
  property MouseInput.Y() as integer
    return( _y )
  end property
 
  property MouseInput.deltaX() as integer
    return( _dx )
  end property
 
  property MouseInput.deltaY() as integer
    return( _dy )
  end property
 
  property MouseInput.startX() as integer
    return( _sx )
  end property
 
  property MouseInput.startY() as integer
    return( _sy )
  end property
 
  property MouseInput.horizontalWheel() as integer
    return( _hWheel )
  end property
 
  property MouseInput.verticalWheel() as integer
    return( _vWheel )
  end property
  

 
  /'
    Handles the events and sets internal state appropriately so we can
    query the other methods individually. This method must be called
    before any other method/property (usually done from the main thread).
  '/
  sub MouseInput.onEvent( e as any ptr )
    mutexLock( _mutex )
      var ev = cptr( Fb.Event ptr, e )
     
      select case as const( ev->type )
        case Fb.EVENT_MOUSE_MOVE
          /'
            This cast is necessary to correctly compute coordinates when dragging
            outside the window. Even though FreeBasic defines the mouse coordinates
            as long in the Fb.Event struct, when you're dragging they get reported
            as a ushort (0..65535).
          '/
          _x = *cast( short ptr, @ev->x )
          _y = *cast( short ptr, @ev->y )
         
          if( _pressed ) then
            _dx = _x - _sx
            _dy = _y - _sy
           
            _dragging = true
            _dropped = false
          end if
         
        case Fb.EVENT_MOUSE_BUTTON_PRESS
          _state( ev->button ) or= _
            ( ButtonState.Pressed or ButtonState.Held or ButtonState.Repeated )
          _state( ev->button ) = _
            _state( ev->button ) and not ButtonState.AlreadyPressed
         
          _dx = 0
          _dy = 0
          _sx = _x
          _sy = _y
          _pressed = true
          _dragging = false
         
        case Fb.EVENT_MOUSE_BUTTON_RELEASE
          _state( ev->button ) or= ButtonState.Released
          _state( ev->button ) = _
            _state( ev->button ) and not ButtonState.AlreadyReleased
          _state( ev->button ) = _state( ev->button ) and not _
            ( ButtonState.Held or ButtonState.HeldInitialized or _
              ButtonState.Repeated or ButtonState.RepeatedInitialized )
         
          _pressed = false
         
          if( _dx <> 0 andAlso _dy <> 0 ) then
            _dropped = true
          else
            _dropped = false
          end if
         
        case _
          Fb.EVENT_MOUSE_WHEEL, _
          Fb.EVENT_MOUSE_HWHEEL
         
          _hWheel = ev->w
          _vWheel = ev->z
          
        
      end select
    mutexUnlock( _mutex )
  end sub
 
  /'
    Returns whether or not a button was pressed.
   
    'Pressed' in this context means that the method will return 'true'
    *once* upon a button press. If you press and hold the button, it will
    not report 'true' until you release the button and press it again.
  '/
  function MouseInput.pressed( aButton as integer ) as boolean
    mutexLock( _mutex )
      dim as boolean isPressed
     
      if( _
        cbool( _state( aButton ) and ButtonState.Pressed ) andAlso _
        not cbool( _state( aButton ) and ButtonState.AlreadyPressed ) ) then
       
        isPressed = true
       
        _state( aButton ) or= ButtonState.AlreadyPressed
      end if
    mutexUnlock( _mutex )
   
    return( isPressed )
  end function
 
  /'
    Returns whether or not a mouse button was released.
   
    'Released' means that a button has to be pressed and then released for
    this method to return 'true' once, just like the 'pressed()' method
    above.
  '/
  function MouseInput.released( aButton as integer ) as boolean
    mutexLock( _mutex )
      dim as boolean isReleased
     
      if( _
        cbool( _state( aButton ) and ButtonState.Released ) andAlso _
        not cbool( _state( aButton ) and ButtonState.AlreadyReleased ) ) then
       
        isReleased = true
       
        _state( aButton ) or= ButtonState.AlreadyReleased
      end if
    mutexUnlock( _mutex )
   
    return( isReleased )
  end function
 
  /'
    Returns whether or not a mouse button is being held.
   
    'Held' means that the button was pressed and is being held pressed, so the
    method behaves pretty much like a call to 'multiKey()', if the 'interval'
    parameter is unspecified.
   
    If an interval is indeed specified, then the method will report the 'held'
    status up to the specified interval, then it will stop reporting 'true'
    until the button is released and held again.
   
    Both this and the 'released()' method expect their intervals to be expressed
    in milliseconds.
  '/
  function MouseInput.held( aButton as integer, interval as double = 0.0 ) as boolean
    mutexLock( _mutex )
      dim as boolean isHeld
     
      if( cbool( _state( aButton ) and ButtonState.Held ) ) then
        isHeld = true
       
        if( cbool( interval > 0.0 ) ) then
          if( not cbool( _state( aButton ) and ButtonState.HeldInitialized ) ) then
            _state( aButton ) or= ButtonState.HeldInitialized
            _heldStartTime( aButton ) = timer()
          else
            dim as double _
              elapsed = ( timer() - _heldStartTime( aButton ) ) * 1000.0d
           
            if( elapsed >= interval ) then
              isHeld = false
             
              _state( aButton ) = _
                _state( aButton ) and not ButtonState.Held
            end if
          end if
        end if
      end if
    mutexUnlock( _mutex )
   
    return( isHeld )
  end function
 
  /'
    Returns whether or not a mouse button is being repeated.
   
    'Repeated' means that the method will intermittently report the 'true'
    status once 'interval' milliseconds have passed. It can be understood
    as the autofire functionality of some game controllers: you specify the
    speed of the repetition using the 'interval' parameter.
   
    Bear in mind, however, that the *first* repetition will be reported
    AFTER one interval has elapsed. In other words, the reported pattern is
    [pause] [repeat] [pause] instead of [repeat] [pause] [repeat].
   
    If no interval is specified, the method behaves like a call to
    'held()'.
  '/
  function MouseInput.repeated( aButton as integer, interval as double = 0.0 ) as boolean
    mutexLock( _mutex )
      dim as boolean isRepeated
     
      if( cbool( _state( aButton ) and ButtonState.Repeated ) ) then
        if( cbool( interval > 0.0 ) ) then
          if( not cbool( _state( aButton ) and ButtonState.RepeatedInitialized ) ) then
            _repeatedStartTime( aButton ) = timer()
            _state( aButton ) or= ButtonState.RepeatedInitialized
          else
            dim as double _
              elapsed = ( timer() - _repeatedStartTime( aButton ) ) * 1000.0d
           
            if( elapsed >= interval ) then
              isRepeated = true
             
              _state( aButton ) = _
                _state( aButton ) and not ButtonState.RepeatedInitialized
            end if
          end if
        else
          isRepeated = true
        end if
      end if
    mutexUnlock( _mutex )
   
    return( isRepeated )
  end function
 
  function MouseInput.drag( aButton as integer ) as boolean
    return( held( aButton ) andAlso _dragging )
  end function
 
  function MouseInput.drop( aButton as integer ) as boolean
    return( released( aButton ) andAlso _dropped )
  end function
