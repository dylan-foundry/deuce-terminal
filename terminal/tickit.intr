module: tickit

define open generic note-window-exposed
    (object, window :: <TickitWindow*>,
     rect :: <TickitRect*>, rb :: <TickitRenderBuffer*>)
 => ();

define open generic note-window-geometry-changed
    (object, window :: <TickitWindow*>)
 => ();

define interface
  #include {
      "tickit.h"
    },
    inline-functions: inline,
    exclude: {
      "tickit_debug_logf",
      "tickit_debug_set_fh",
      "tickit_debug_set_func",
      "tickit_debug_vlogf",
      "tickit_pen_new_attrs",
      "tickit_renderbuffer_get_cell_linemask",
      "tickit_renderbuffer_textf_at",
      "tickit_renderbuffer_textf",
      "tickit_renderbuffer_vtextf_at",
      "tickit_renderbuffer_vtextf",
      "tickit_rect_bottom",
      "tickit_rect_right",
      "tickit_stringpos_limit_bytes",
      "tickit_stringpos_limit_codepoints",
      "tickit_stringpos_limit_columns",
      "tickit_stringpos_limit_graphemes",
      "tickit_stringpos_limit_none",
      "tickit_stringpos_zero",
      "tickit_term_await_started_tv",
      "tickit_term_input_wait_tv",
      "tickit_term_printf",
      "tickit_term_vprintf",
      "tickit_window_get_abs_geometry",
      "tickit_window_get_geometry"
    },
    rename: {
      "tickit_term_await_started_msec" => tickit-term-await-started,
      "tickit_term_input_check_timeout_msec" => tickit-term-input-check-timeout,
      "tickit_term_input_wait_msec" => tickit-term-input-wait,
      "tickit_window_set_pen" => %tickit-window-set-pen
    },
    equate: {
      "char *" => <c-string>
    };

  function "tickit_rect_intersect",
    output-argument: 1;

  function "tickit_term_get_size",
    output-argument: 2,
    output-argument: 3;

  function "tickit_term_getctl_int",
    output-argument: 3;

  function "tickit_renderbuffer_get_size",
    output-argument: 2,
    output-argument: 3;

  function "tickit_renderbuffer_get_cursorpos",
    output-argument: 2,
    output-argument: 3;
end interface;

define C-pointer-type <TickitExposeEventInfo*> => <TickitExposeEventInfo>;
define C-pointer-type <TickitFocusEventInfo*> => <TickitFocusEventInfo>;
define C-pointer-type <TickitGeomchangeEventInfo*> => <TickitGeomchangeEventInfo>;
define C-pointer-type <TickitKeyEventInfo*> => <TickitKeyEventInfo>;
define C-pointer-type <TickitMouseEventInfo*> => <TickitMouseEventInfo>;
define C-pointer-type <TickitResizeEventInfo*> => <TickitResizeEventInfo>;

define constant $everywhere = null-pointer(<TickitRect*>);
define constant $default-pen = null-pointer(<TickitPen*>);

define method tickit-window-set-pen
    (window :: <TickitWindow*>, pen :: false-or(<TickitPen*>))
 => ()
  %tickit-window-set-pen(window, if (pen) pen else $default-pen end);
end;

define method %window-expose-callback
    (window :: <TickitWindow*>, event-type :: <integer>,
     info :: <TickitExposeEventInfo*>, data :: <C-dylan-object>)
=> ()
  let object = import-c-dylan-object(data);
  let rect = TickitExposeEventInfo$rect(info);
  let rb = TickitExposeEventInfo$rb(info);
  note-window-exposed(object, window, rect, rb);
end;

define C-callable-wrapper %expose-callback of %window-expose-callback
  parameter window :: <TickitWindow*>;
  parameter event-type :: <TickitEventType>;
  parameter info :: <TickitExposeEventInfo*>;
  parameter data :: <C-dylan-object>;
end;

define method tickit-window-notify-on-expose
    (window :: <TickitWindow*>, object)
 => ()
  register-c-dylan-object(object);
  let data = export-c-dylan-object(object);
  tickit-window-bind-event(window, $TICKIT-EV-EXPOSE, %expose-callback, data);
end method;

define method %window-geometry-changed-callback
    (window :: <TickitWindow*>, event-type :: <integer>,
     info :: <TickitExposeEventInfo*>, data :: <C-dylan-object>)
=> ()
  let object = import-c-dylan-object(data);
  note-window-geometry-changed(object, window);
end;

define C-callable-wrapper %geometry-changed-callback of %window-geometry-changed-callback
  parameter window :: <TickitWindow*>;
  parameter event-type :: <TickitEventType>;
  parameter info :: <TickitExposeEventInfo*>;
  parameter data :: <C-dylan-object>;
end;

define method tickit-window-notify-on-geometry-changed
    (window :: <TickitWindow*>, object)
 => ()
  register-c-dylan-object(object);
  let data = export-c-dylan-object(object);
  tickit-window-bind-event(window, $TICKIT-EV-GEOMCHANGE, %geometry-changed-callback, data);
end method;
