module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library dt
  use dylan;
  use common-dylan;
  use io;
  use deuce;
  use deuce-terminal;
  use terminal;
  use terminal-ui;

  export dt;
end library;

define module dt
  use common-dylan;
  use threads, import: { dynamic-bind };
  use format-out;
  use deuce;
  use deuce-internals,
    import: {
      execute-command-in-frame,
      make-initial-buffer
    };
  use deuce-terminal;
  use terminal;
  use terminal-ui;
end module;
