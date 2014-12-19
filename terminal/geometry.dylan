module: terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <region> (<object>)
end;

define open generic region-contains-position?
    (region :: <region>, line :: <integer>, col :: <integer>)
 => (contained? :: <boolean>);

define open generic region-contains-region?
    (region1 :: <region>, region2 :: <region>)
 => (contained? :: <boolean>);

define method region-contains-position?
    (region :: <region>, line :: <integer>, col :: <integer>)
 => (contained? :: <boolean>)
  #f
end;

define method region-contains-region?
    (region1 :: <region>, region2 :: <region>)
 => (contained? :: <boolean>)
  #f
end;

define class <position> (<region>)
  sealed constant slot position-line :: <integer> = 0,
    init-keyword: line:;
  sealed constant slot position-col :: <integer> = 0,
    init-keyword: col:;
end;

define inline function make-position (line :: <integer>, col :: <integer>)
 => (position :: <position>)
  make(<position>, line: line, col: col)
end;

define method position-position (position :: <position>)
 => (line :: <integer>, col :: <integer>)
  values(position-line(position), position-col(position))
end;

define method region-contains-position?
    (position :: <position>, line :: <integer>, col :: <integer>)
 => (contained? :: <boolean>)
  position-line(position) = line & position-col(position) = col
end;

define method region-contains-region?
    (position1 :: <position>, position2 :: <position>)
 => (contained? :: <boolean>)
  position-line(position1) = position-line(position2) & position-col(position1) = position-col(position2)
end;

define method region-contains-region?
    (region :: <region>, position :: <position>)
 => (contained? :: <boolean>)
  region-contains-position?(region, position-line(position), position-col(position))
end;

define class <rectangle> (<region>)
  sealed constant slot %rect-min-line :: <integer> = 0,
    required-init-keyword: min-line:;
  sealed constant slot %rect-min-col :: <integer> = 0,
    required-init-keyword: min-col:;
  sealed constant slot %rect-max-line :: <integer> = 0,
    required-init-keyword: max-line:;
  sealed constant slot %rect-max-col :: <integer> = 0,
    required-init-keyword: max-col:;
end;

define inline function make-rectangle
    (line1, col1, line2, col2)
 => (rectangle :: <rectangle>)
  assert(line1 <= line2 & col1 <= col2,
         "The min position must be to the upper-left of the max position");
  make(<rectangle>,
       min-line: line1, min-col: col1, max-line: line2, max-col: col2)
end;

define method rectangle-min-position (rect :: <rectangle>)
  values(rect.%rect-min-line, rect.%rect-min-col)
end;

define method rectangle-max-position (rect :: <rectangle>)
  values(rect.%rect-max-line, rect.%rect-max-col)
end;

define method rectangle-size (rect :: <rectangle>)
 => (width :: <integer>, height :: <integer>)
  values(rect.%rect-max-line - rect.%rect-min-line,
         rect.%rect-max-col - rect.%rect-min-col)
end;

define method rectangle-width (rect :: <rectangle>)
  rect.%rect-max-line - rect.%rect-min-line
end;

define method rectangle-height (rect :: <rectangle>)
  rect.%rect-max-col - rect.%rect-min-col
end;

define method region-contains-position?
    (rect :: <rectangle>, line :: <integer>, col :: <integer>)
 => (contained? :: <boolean>)
  rect.%rect-min-line <= line & rect.%rect-min-col <= col
  & rect.%rect-max-line >= line & rect.%rect-max-col >= col
end;

define method region-contains-region?
    (rect1 :: <rectangle>, rect2 :: <rectangle>)
 => (contained? :: <boolean>)
  rect1.%rect-min-line <= rect2.%rect-min-line
  & rect1.%rect-min-col <= rect2.%rect-min-col
  & rect1.%rect-max-line >= rect2.%rect-max-line
  & rect1.%rect-max-col >= rect2.%rect-max-col
end method region-contains-region?;
