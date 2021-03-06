module: terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define variable *tickit-term* :: false-or(<TickitTerm*>) = #f;

define c-function terminal-window-cols
  input parameter window :: <TickitWindow*>;
  result cols :: <C-int>;
  c-name: "terminal_window_cols";
end;

define c-function terminal-window-lines
  input parameter window :: <TickitWindow*>;
  result lines :: <C-int>;
  c-name: "terminal_window_lines";
end;

define function terminal-init ()
  *tickit-term* := tickit-term-open-stdio();
  assert(~null-pointer?(*tickit-term*));

  tickit-term-await-started(*tickit-term*, 5);

  tickit-term-setctl-int(*tickit-term*, $TICKIT-TERMCTL-MOUSE, $TICKIT-TERM-MOUSEMODE-DRAG);
  tickit-term-setctl-int(*tickit-term*, $TICKIT-TERMCTL-ALTSCREEN, 1);

  tickit-term-clear(*tickit-term*);

  register-application-exit-function(terminal-shutdown);
end function;

define function terminal-shutdown ()
  tickit-term-destroy(*tickit-term*);
  *tickit-term* := #f;
end function;
