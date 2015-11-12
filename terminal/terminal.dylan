module: terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define variable *tickit-term* :: false-or(<TickitTerm*>) = #f;

define c-function terminal-stdin-fileno
  result fileno :: <C-int>;
  c-name: "terminal_get_stdin_fileno";
end;

define c-function terminal-stdout-fileno
  result fileno :: <C-int>;
  c-name: "terminal_get_stdout_fileno";
end;

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
  *tickit-term* := tickit-term-new();
  assert(~null-pointer?(*tickit-term*));

  tickit-term-set-input-fd(*tickit-term*, terminal-stdin-fileno());
  tickit-term-set-output-fd(*tickit-term*, terminal-stdout-fileno());

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
