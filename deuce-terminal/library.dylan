module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library deuce-terminal
  use dylan;
  use common-dylan;
  use io;
  use deuce;
  use terminal;
  use terminal-ui;

  export deuce-terminal;
end library;

define module deuce-terminal
  use common-dylan, exclude: { format-to-string };
  use threads, import: { dynamic-bind };
  use format-out;
  use deuce;
  use deuce-internals, rename: { position => deuce/position };
  use terminal;
  use terminal-ui;
  use tickit;

  export <deuce-editor>,
         <deuce-frame>;

  export start-frame;
end module;
