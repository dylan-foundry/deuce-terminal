module: deuce-terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <deuce-terminal-window> (<basic-window>, <widget>)
  slot read-only-label;
  slot buffer-name-label;
  slot backing-store :: <TickitRenderBuffer*>;
end class <deuce-terminal-window>;

define method initialize (window :: <deuce-terminal-window>, #key)
 => ()
  next-method();
  let root = tickit-window-new-root(*tickit-term*);
  widget-window(window) := root;
  let (window-width, window-height) = window-size(window);
  let status-bar-origin = window-height;
  read-only-label(window) := make(<label>, text: "???");
  let rolw = tickit-window-new-subwindow(root, status-bar-origin, window-width - 3, 1, 3);
  widget-window(read-only-label(window)) := rolw;
  let bnlw = tickit-window-new-subwindow(root, status-bar-origin, 0, 1, 50);
  buffer-name-label(window) := make(<label>, text: "No buffer loaded.");
  widget-window(buffer-name-label(window)) := bnlw;
  backing-store(window) := tickit-renderbuffer-new(window-height, window-width);
end method initialize;

define method handle-repaint
    (window :: <deuce-terminal-window>, renderbuffer :: <TickitRenderBuffer*>,
     rect :: <TickitRect*>)
 => ()
  tickit-renderbuffer-blit(renderbuffer, backing-store(window));
end method handle-repaint;

define method window-note-buffer-changed
    (window :: <deuce-terminal-window>, buffer :: <basic-buffer>, modified? :: <boolean>) => ()
  next-method();
  format-out("DEUCE: window-note-buffer-changed: %= %=\n", buffer, modified?);
end method window-note-buffer-changed;

define method window-note-buffer-read-only
    (window :: <deuce-terminal-window>, buffer :: <basic-buffer>, read-only? :: <boolean>) => ()
  next-method();
  format-out("DEUCE: window-note-buffer-read-only: %= %=\n", buffer, read-only?);
  let new-text = if (read-only?) "R/O" else "R/W" end;
  label-text(read-only-label(window)) := new-text;
end method window-note-buffer-read-only;

define method window-note-buffer-selected
    (window :: <deuce-terminal-window>, buffer :: <basic-buffer>) => ()
  next-method();
  format-out("DEUCE: window-note-buffer-selected: %=\n", buffer);
end method window-note-buffer-selected;

define method window-note-buffer-selected
    (window :: <deuce-terminal-window>, buffer == #f) => ()
  next-method();
  format-out("DEUCE: window-note-buffer-selected: %=\n", buffer);
end method window-note-buffer-selected;

// <<window-back-end>>

define sealed method window-enabled?
    (window :: <deuce-terminal-window>)
 => (enabled? :: <boolean>)
  format-out("DEUCE: window-enabled?\n");
  #t
end method window-enabled?;

define sealed method window-occluded?
    (window :: <deuce-terminal-window>)
 => (occluded? :: <boolean>)
  format-out("DEUCE: window-occluded?\n");
  #f
end method window-occluded?;

define sealed method window-size
    (window :: <deuce-terminal-window>)
 => (width :: <integer>, height :: <integer>)
  format-out("DEUCE: window-size\n");
  window-viewport-size(window)
end method window-size;

define sealed method window-viewport-size
    (window :: <deuce-terminal-window>)
 => (width :: <integer>, height :: <integer>)
  let (height, width) = terminal-size();
  format-out("DEUCE: window-viewport-size => %d %d\n", height - 2, width);
  // Subtract 2 from height for status bar and message area.
  values(width, height - 2)
end method window-viewport-size;

define sealed method update-scroll-bar
    (window :: <deuce-terminal-window>, which,
     total-lines :: <integer>, position :: <integer>, visible-lines :: <integer>)
 => ()
end method update-scroll-bar;

define sealed method scroll-position
    (window :: <deuce-terminal-window>)
 => (x :: <integer>, y :: <integer>)
  values(0, 0)
end method scroll-position;

define sealed method set-scroll-position
    (window :: <deuce-terminal-window>, x :: false-or(<integer>), y :: false-or(<integer>))
 => ()
  let (sx, sy) = scroll-position(window);
  format-out("DEUCE: set-scroll-position: %= %=\n", x, y);
end method set-scroll-position;

define sealed method display-message
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => ()
  format-out("DEUCE: display-message: \"%s\" %=\n", format-string, format-args);
end method display-message;

define sealed method display-error-message
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => ()
  format-out("DEUCE: display-error-message: \"%s\" %=\n", format-string, format-args);
end method display-error-message;

define sealed method display-buffer-name
    (window :: <deuce-terminal-window>, buffer :: false-or(<buffer>))
 => ()
  let name = if (buffer) buffer-name(buffer) else "" end;
  format-out("DEUCE: display-buffer-name: \"%s\"\n", name);
  label-text(buffer-name-label(window)) := name;
end method display-buffer-name;

define sealed method draw-string
    (window :: <deuce-terminal-window>,
     string :: <string>, col :: <integer>, line :: <integer>,
     #key start: _start, end: _end, color, font, align-x, align-y)
 => ()
  format-out("DEUCE: draw-string \"%s\" @ %=, %=\n", string, line, col);
  tickit-renderbuffer-text-at(backing-store(window), line, col, string, $default-pen);
  queue-repaint(window, $everywhere);
end method draw-string;

define sealed method string-size
    (window :: <deuce-terminal-window>, string :: <string>,
     #key start: _start, end: _end, font)
 => (width :: <integer>, height :: <integer>, baseline :: <integer>)
  format-out("DEUCE: string-size \"%s\"\n", string);
  values(size(string), 1, 0)
end method string-size;

define sealed method draw-line
    (window :: <deuce-terminal-window>,
     x1 :: <integer>, y1 :: <integer>, x2 :: <integer>, y2 :: <integer>,
     #key color, thickness)
 => ()
  format-out("DEUCE: draw-line %=, %= -> %=, %=\n", x1, y1, x2, y2);
end method draw-line;

define sealed method draw-rectangle
    (window :: <deuce-terminal-window>,
     left :: <integer>, top :: <integer>, right :: <integer>, bottom :: <integer>,
     #key color, thickness, filled?)
 => ()
  format-out("DEUCE: draw-rectangle %=, %= -> %=, %=\n", left, top, right, bottom);
end method draw-rectangle;

define sealed method draw-image
    (window :: <deuce-terminal-window>,
     image, x :: <integer>, y :: <integer>)
 => ()
  format-out("DEUCE: draw-image %= @ %=, %=\n", image, x, y);
end method draw-image;

define sealed method clear-area
    (window :: <deuce-terminal-window>,
     left :: <integer>, top :: <integer>, right :: <integer>, bottom :: <integer>)
 => ()
  format-out("DEUCE: clear-area %=, %= -> %=, %=\n", left, top, right, bottom);
  let rect = make(<TickitRect*>);
  tickit-rect-init-sized(rect, top, left, bottom, right);
  tickit-renderbuffer-eraserect(backing-store(window), rect, $default-pen);
  queue-repaint(window, rect);
end method clear-area;

define sealed method copy-area
    (window :: <deuce-terminal-window>,
     from-x :: <integer>, from-y :: <integer>, width :: <integer>, height :: <integer>,
     to-x :: <integer>, to-y :: <integer>)
 => ()
  format-out("DEUCE: copy-area %=, %=, %=, %= -> %=, %=\n", from-x, from-y,
             width, height, to-x, to-y);
end method copy-area;

define sealed method cursor-position
    (window :: <deuce-terminal-window>)
 => (x :: <integer>, y :: <integer>)
  format-out("DEUCE: cursor-position\n");
  values(0, 0)
end method cursor-position;

define sealed method set-cursor-position
    (window :: <deuce-terminal-window>, x :: <integer>, y :: <integer>)
 => ()
  format-out("DEUCE: set-cursor-position %= %=\n", x, y);
end method set-cursor-position;

define sealed method do-with-busy-cursor
    (window :: <deuce-terminal-window>, continuation :: <function>)
 => (#rest values)
  continuation()
end method do-with-busy-cursor;

define sealed method caret-position
    (window :: <deuce-terminal-window>)
 => (x :: <integer>, y :: <integer>)
  format-out("DEUCE: caret-position\n");
  values(0, 0)
end method caret-position;

define sealed method set-caret-position
    (window :: <deuce-terminal-window>, x :: <integer>, y :: <integer>)
 => ()
  format-out("DEUCE: set-caret-position %=, %=\n", x, y);
  terminal-move-cursor(x, y);
end method set-caret-position;

define sealed method caret-size
    (window :: <deuce-terminal-window>)
 => (width :: <integer>, height :: <integer>)
  format-out("DEUCE: caret-size\n");
  values(1, 1)
end method caret-size;

define sealed method set-caret-size
    (window :: <deuce-terminal-window>, width :: <integer>, height :: <integer>)
 => ()
  format-out("DEUCE: set-caret-size: %= %=\n", width, height);
end method set-caret-size;

define sealed method show-caret
    (window :: <deuce-terminal-window>, #key tooltip?)
 => ()
  format-out("DEUCE: show-caret tooltip? %=\n", tooltip?);
  terminal-show-cursor();
end method show-caret;

define sealed method hide-caret
    (window :: <deuce-terminal-window>, #key tooltip?)
 => ()
  format-out("DEUCE: hide-caret tooltip? %=\n", tooltip?);
  terminal-hide-cursor();
end method hide-caret;

define sealed method font-metrics
    (window :: <deuce-terminal-window>, font :: false-or(<font>))
 => (width :: <integer>, height :: <integer>, ascent :: <integer>, descent :: <integer>)
  values(1, 1, 0, 0)
end method font-metrics;

define sealed method choose-from-menu
    (window :: <deuce-terminal-window>, items :: <sequence>,
     #key title, value, label-key, value-key, width, height, multiple-sets?)
 => (value :: false-or(<object>), success? :: <boolean>)
  format-out("DEUCE: choose-from-menu: %=\n", items);
  values(#f, #f)
end method choose-from-menu;

define sealed method choose-from-dialog
    (window :: <deuce-terminal-window>, items :: <sequence>,
     #key title, value, label-key, value-key, width, height, selection-mode)
 => (value :: false-or(<object>), success? :: <boolean>,
     width :: false-or(<integer>), height :: false-or(<integer>))
  format-out("DEUCE: choose-from-dialog: %=\n", items);
  values(#f, #f, #f, #f)
end method choose-from-dialog;

define sealed method information-dialog
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => ()
  format-out("DEUCE: information-dialog: %=, %=\n", format-string, format-args);
end method information-dialog;

define sealed method warning-dialog
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => ()
  format-out("DEUCE: warning-dialog: %=, %=\n", format-string, format-args);
end method warning-dialog;

define sealed method yes-or-no-dialog
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => (result :: <boolean>)
  format-out("DEUCE: yes-or-no-dialog\n");
  #f
end method yes-or-no-dialog;

define sealed method yes-no-or-cancel-dialog
    (window :: <deuce-terminal-window>, format-string :: <string>, #rest format-args)
 => (result :: type-union(<boolean>, singleton(#"cancel")))
  format-out("DEUCE: yes-no-or-cancel-dialog\n");
  #f
end method yes-no-or-cancel-dialog;

define sealed method open-file-dialog
    (window :: <deuce-terminal-window>, #key default, default-type)
 => (pathname :: false-or(<pathname>))
  format-out("DEUCE: open-file-dialog\n");
  "LICENSE"
end method open-file-dialog;

define sealed method new-file-dialog
    (window :: <deuce-terminal-window>, #key default, default-type)
 => (pathname :: false-or(<pathname>))
  format-out("DEUCE: new-file-dialog\n");
  #f
end method new-file-dialog;

define sealed method save-buffers-dialog
    (window :: <deuce-terminal-window>,
     #key exit-label :: false-or(<string>), reason :: false-or(<string>),
          buffers :: false-or(<sequence>), default-buffers :: false-or(<sequence>))
 => (buffers :: type-union(<sequence>, singleton(#f), singleton(#"cancel")),
     no-buffers? :: <boolean>)
  format-out("DEUCE: save-buffers-dialog\n");
  values(#f, #f)
end method save-buffers-dialog;

define sealed method choose-buffer-dialog
    (window :: <deuce-terminal-window>, #key title, buffer :: false-or(<buffer>), buffers)
 => (buffer :: false-or(<buffer>))
  format-out("DEUCE: choose-buffer-dialog\n");
  #f
end method choose-buffer-dialog;

define sealed method choose-buffers-dialog
    (window :: <deuce-terminal-window>, #key title, buffer :: false-or(<buffer>), buffers)
 => (buffers :: false-or(<sequence>))
  format-out("DEUCE: choose-buffers-dialog\n");
  #f
end method choose-buffers-dialog;

define sealed method new-buffer-dialog
    (window :: <deuce-terminal-window>, #key title)
 => (buffer-name)
  format-out("DEUCE: new-buffer-dialog\n");
  "New Buffer"
end method new-buffer-dialog;

define sealed method edit-definition-dialog
    (window :: <deuce-terminal-window>, name :: <string>, #key title)
 => (definition)
  format-out("DEUCE: edit-definition-dialog: %=\n", name);
  #f
end method edit-definition-dialog;

define sealed method choose-string-dialog
    (window :: <deuce-terminal-window>, #key default, prompt, title)
 => (string)
  format-out("DEUCE: choose-string-dialog\n");
  ""
end method choose-string-dialog;

define sealed method hack-matching-lines-dialog
    (window :: <deuce-terminal-window>)
 => (string, operation)
  format-out("DEUCE: hack-matching-lines-dialog\n");
  values("", #f)
end method hack-matching-lines-dialog;

define sealed method goto-position-dialog
    (window :: <deuce-terminal-window>, what :: <goto-target-type>)
 => (number :: false-or(<integer>), what :: false-or(<goto-target-type>))
  format-out("DEUCE: goto-position-dialog: %=\n", what);
  values(1, what)
end method goto-position-dialog;

define sealed method string-search-dialog
    (window :: <deuce-terminal-window>,
     #key string,
          reverse? :: <boolean>, case-sensitive? :: <boolean>, whole-word? :: <boolean>)
 => ()
  format-out("DEUCE: string-search-dialog\n");
end method string-search-dialog;

define sealed method string-replace-dialog
    (window :: <deuce-terminal-window>,
     #key string, replace,
          reverse? :: <boolean>, case-sensitive? :: <boolean>, whole-word? :: <boolean>)
 => ()
  format-out("DEUCE: string-replace-dialog\n");
end method string-replace-dialog;

define sealed method configuration-dialog
    (window :: <deuce-terminal-window>)
 => (policy :: false-or(<editor-policy>))
  format-out("DEUCE: configuration-dialog\n");
  #f
end method configuration-dialog;

define sealed method add-to-clipboard
    (window :: <deuce-terminal-window>, data)
 => ()
  format-out("DEUCE: add-to-clipboard: %=\n", data);
end method add-to-clipboard;

define sealed method get-from-clipboard
    (window :: <deuce-terminal-window>, class)
 => (data)
  format-out("DEUCE: get-from-clipboard: %=\n", class);
  "Some data from the clipboard."
end method get-from-clipboard;

define sealed method command-enabled?
    (window :: <deuce-terminal-window>, command :: <function>)
 => (enabled? :: <boolean>)
  format-out("DEUCE: command-enabled? %=\n", command);
  #t
end method command-enabled?;

define sealed method command-enabled?-setter
    (enabled? :: <boolean>, window :: <deuce-terminal-window>, command :: <function>)
 => (enabled? :: <boolean>)
  format-out("DEUCE: command-enabled?-setter %= %=\n", command, enabled?);
  enabled?
end method command-enabled?-setter;

define sealed method read-character
    (window :: <deuce-terminal-window>)
 => (character :: <character>)
  format-out("DEUCE: read-character\n");
  'C'
end method read-character;

define sealed method read-gesture
    (window :: <deuce-terminal-window>)
 => (keysym, char, modifiers)
  format-out("DEUCE: read-gesture\n");
  values('C', 'C', 0)
end method read-gesture;
