module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define variable *quit-signaled?* :: <boolean> = #f;

define function handle-resize-event
    (window :: <TickitWindow*>, event-type :: <integer>,
     event :: <TickitResizeEventInfo*>, user-data :: <C-void*>)
 => ()
  *quit-signaled?* := #t;
end;

define function handle-key-event
    (window :: <TickitWindow*>, event-type :: <integer>,
     event :: <TickitKeyEventInfo*>, user-data :: <C-void*>)
 => ()
  *quit-signaled?* := #t;
end;

define function handle-mouse-event
    (window :: <TickitWindow*>, event-type :: <integer>,
     event :: <TickitMouseEventInfo*>, user-data :: <C-void*>)
 => ()
  *quit-signaled?* := #t;
end;

define C-callable-wrapper handle-resize-event-callback of handle-resize-event
  input parameter window :: <TickitWindow*>;
  input parameter event-type :: <TickitEventType>;
  input parameter event :: <TickitResizeEventInfo*>;
  input parameter user-data :: <C-void*>;
end;

define C-callable-wrapper handle-key-event-callback of handle-key-event
  input parameter window :: <TickitWindow*>;
  input parameter event-type :: <TickitEventType>;
  input parameter event :: <TickitKeyEventInfo*>;
  input parameter user-data :: <C-void*>;
end;

define C-callable-wrapper handle-mouse-event-callback of handle-mouse-event
  input parameter window :: <TickitWindow*>;
  input parameter event-type :: <TickitEventType>;
  input parameter event :: <TickitMouseEventInfo*>;
  input parameter user-data :: <C-void*>;
end;

// XXX: This should really dispatch them to the application or
//      something, but not just to a widget.
define function terminal-ui-dispatch-events (widget :: <widget>)
  let window = widget.widget-window;
  tickit-window-bind-event(window,
                           $TICKIT-EV-RESIZE,
                           handle-resize-event-callback,
                           null-pointer(<C-void*>));
  tickit-window-bind-event(window,
                           $TICKIT-EV-KEY,
                           handle-key-event-callback,
                           null-pointer(<C-void*>));
  tickit-window-bind-event(window,
                           $TICKIT-EV-MOUSE,
                           handle-mouse-event-callback,
                           null-pointer(<C-void*>));
  while (~*quit-signaled?*)
    tickit-window-tick(widget-window(widget));
    tickit-term-input-wait(*tickit-term*, 5);
    tickit-window-tick(widget-window(widget));
  end;
end function;
