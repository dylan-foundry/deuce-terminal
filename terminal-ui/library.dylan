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

  export <label>,
         label-text,
         label-text-setter,
         <status-bar>,
         <widget>,
         draw-widget,
         widget-children,
         widget-origin,
         widget-origin-setter,
         widget-parent,
         widget-size,
         widget-size-setter;
end module;
