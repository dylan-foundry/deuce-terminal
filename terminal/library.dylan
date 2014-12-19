module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library terminal
  use dylan;
  use common-dylan;
  use c-ffi;
  use io;
  use tickit;

  export terminal;
end library;

define module terminal
  use common-dylan, exclude: { format-to-string };
  use threads, import: { dynamic-bind };
  use c-ffi;
  use format-out;
  use tickit;

  export *tickit-term*;

  export terminal-init,
         terminal-shutdown;

  export terminal-size;

  export terminal-move-cursor,
         terminal-show-cursor,
         terminal-hide-cursor;
end module;
