module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library terminal-ui
  use dylan;
  use common-dylan;
  use c-ffi;
  use io;
  use terminal;

  export terminal-ui;
end library;

define module terminal-ui
  use common-dylan, exclude: { format-to-string };
  use threads, import: { dynamic-bind };
  use c-ffi;
  use format-out;
  use tickit;
  use terminal;

  export terminal-ui-dispatch-events;

  export <widget>,
         queue-repaint,
         handle-repaint,
         reshape-widget,
         note-widget-window-gained,
         note-widget-window-lost,
         widget-children,
         widget-parent,
         widget-window,
         widget-window-setter;

  export <label>,
         label-pen,
         label-pen-setter,
         label-text,
         label-text-setter;

  export <status-bar>;
end module;
