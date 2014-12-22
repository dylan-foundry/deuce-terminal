module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define variable *quit-signaled?* :: <boolean> = #f;

define function dump-event (event :: <TickitEvent*>)
  format-out("Event: %=\n", event);
  format-out("  lines: %=\n", TickitEvent$lines(event));
  format-out("  cols: %=\n", TickitEvent$cols(event));
  format-out("  type: %=\n", TickitEvent$type(event));
  format-out("  str: %=\n", TickitEvent$str(event));
  format-out("  button: %=\n", TickitEvent$button(event));
  format-out("  line: %=\n", TickitEvent$line(event));
  format-out("  col: %=\n", TickitEvent$col(event));
  format-out("  mod: %=\n", TickitEvent$mod(event));
  format-out("--\n");
end;

define function handle-event
    (term :: <TickitTerm*>, event-type :: <integer>,
     event :: <TickitEvent*>, user-data :: <C-void*>)
 => ()
  dump-event(event);
  *quit-signaled?* := #t;
end;

define C-callable-wrapper handle-event-callback of handle-event
  input parameter term :: <TickitTerm*>;
  input parameter event-type :: <TickitEventType>;
  input parameter event :: <TickitEvent*>;
  input parameter user-data :: <C-void*>;
end;

// XXX: This should really dispatch them to the application or
//      something, but not just to a widget.
define function terminal-ui-dispatch-events (widget :: <widget>)
  tickit-term-bind-event(*tickit-term*,
                         logior($TICKIT-EV-RESIZE,
                                $TICKIT-EV-KEY,
                                $TICKIT-EV-MOUSE),
                         handle-event-callback,
                         null-pointer(<C-void*>));
  while (~*quit-signaled?*)
    tickit-window-tick(widget-window(widget));
    tickit-term-input-wait(*tickit-term*, 0);
    tickit-window-tick(widget-window(widget));
  end;
end function;
