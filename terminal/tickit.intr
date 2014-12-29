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
      "tickit.h",
      "tickit-window.h"
    },
    exclude: {
      "tickit_pen_new_attrs",
      "tickit_renderbuffer_get_cell_linemask",
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
      "tickit_term_vprintf"
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

  function "tickit_window_set_on_expose",
    map-argument: { 3 => <C-dylan-object> };

  function "tickit_window_set_on_geometry_changed",
    map-argument: { 3 => <C-dylan-object> };
end interface;

define constant $everywhere = null-pointer(<TickitRect*>);
define constant $default-pen = null-pointer(<TickitPen*>);

define method tickit-window-set-pen
    (window :: <TickitWindow*>, pen :: false-or(<TickitPen*>))
 => ()
  %tickit-window-set-pen(window, if (pen) pen else $default-pen end);
end;

define method %window-expose-callback
    (window :: <TickitWindow*>, rect :: <TickitRect*>,
     rb :: <TickitRenderBuffer*>, data :: <C-dylan-object>)
=> ()
  let object = import-c-dylan-object(data);
  note-window-exposed(object, window, rect, rb);
end;

define C-callable-wrapper %expose-callback of %window-expose-callback
  parameter window :: <TickitWindow*>;
  parameter rect :: <TickitRect*>;
  parameter rb :: <TickitRenderBuffer*>;
  parameter data :: <C-dylan-object>;
end;

define method tickit-window-notify-on-expose
    (window :: <TickitWindow*>, object)
 => ()
  register-c-dylan-object(object);
  let data = export-c-dylan-object(object);
  tickit-window-set-on-expose(window, %expose-callback, data);
end method;

define method %window-geometry-changed-callback
    (window :: <TickitWindow*>, data :: <C-dylan-object>)
=> ()
  let object = import-c-dylan-object(data);
  note-window-geometry-changed(object, window);
end;

define C-callable-wrapper %geometry-changed-callback of %window-geometry-changed-callback
  parameter window :: <TickitWindow*>;
  parameter data :: <C-dylan-object>;
end;

define method tickit-window-notify-on-geometry-changed
    (window :: <TickitWindow*>, object)
 => ()
  register-c-dylan-object(object);
  let data = export-c-dylan-object(object);
  tickit-window-set-on-geometry-changed(window, %geometry-changed-callback, data);
end method;
