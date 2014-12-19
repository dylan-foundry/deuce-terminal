module: terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define function terminal-move-cursor (line :: <integer>, col :: <integer>)
 => ()
  tickit-term-goto(*tickit-term*, line, col);
end;

define function terminal-show-cursor ()
 => ()
  tickit-term-setctl-int(*tickit-term*, $TICKIT-TERMCTL-CURSORVIS, 1);
end;

define function terminal-hide-cursor ()
 => ()
  tickit-term-setctl-int(*tickit-term*, $TICKIT-TERMCTL-CURSORVIS, 0);
end;
