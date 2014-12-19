module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <region> (<object>)
end;

define open generic region-contains-position?
    (region :: <region>, x :: <integer>, y :: <integer>)
 => (contained? :: <boolean>);

define open generic region-contains-region?
    (region1 :: <region>, region2 :: <region>)
 => (contained? :: <boolean>);

define method region-contains-position?
    (region :: <region>, x :: <integer>, y :: <integer>)
 => (contained? :: <boolean>)
  #f
end;

define method region-contains-region?
    (region1 :: <region>, region2 :: <region>)
 => (contained? :: <boolean>)
  #f
end;

define class <point> (<region>)
  sealed constant slot point-x :: <integer> = 0,
    init-keyword: x:;
  sealed constant slot point-y :: <integer> = 0,
    init-keyword: y:;
end;

define inline function make-point (x :: <integer>, y :: <integer>)
 => (point :: <point>)
  make(<point>, x: x, y: y)
end;

define method point-position (point :: <point>)
 => (x :: <integer>, y :: <integer>)
  values(point-x(point), point-y(point))
end;

define method region-contains-position?
    (point :: <point>, x :: <integer>, y :: <integer>)
 => (contained? :: <boolean>)
  point-x(point) = x & point-y(point) = y
end;

define method region-contains-region?
    (point1 :: <point>, point2 :: <point>)
 => (contained? :: <boolean>)
  point-x(point1) = point-x(point2) & point-y(point1) = point-y(point2)
end;

define method region-contains-region?
    (region :: <region>, point :: <point>)
 => (contained? :: <boolean>)
  region-contains-position?(region, point-x(point), point-y(point))
end;

define class <rectangle> (<region>)
  sealed constant slot %rect-min-x :: <integer> = 0,
    required-init-keyword: min-x:;
  sealed constant slot %rect-min-y :: <integer> = 0,
    required-init-keyword: min-y:;
  sealed constant slot %rect-max-x :: <integer> = 0,
    required-init-keyword: max-x:;
  sealed constant slot %rect-max-y :: <integer> = 0,
    required-init-keyword: max-y:;
end;

define inline function make-rectangle
    (x1, y1, x2, y2)
 => (rectangle :: <rectangle>)
  assert(x1 <= x2 & y1 <= y2,
         "The min point must be to the upper-left of the max point");
  make(<rectangle>,
       min-x: x1, min-y: y1, max-x: x2, max-y: y2)
end;

define method rectangle-min-position (rect :: <rectangle>)
  values(rect.%rect-min-x, rect.%rect-min-y)
end;

define method rectangle-max-position (rect :: <rectangle>)
  values(rect.%rect-max-x, rect.%rect-max-y)
end;

define method rectangle-size (rect :: <rectangle>)
 => (width :: <integer>, height :: <integer>)
  values(rect.%rect-max-x - rect.%rect-min-x,
         rect.%rect-max-y - rect.%rect-min-y)
end;

define method rectangle-width (rect :: <rectangle>)
  rect.%rect-max-x - rect.%rect-min-x
end;

define method rectangle-height (rect :: <rectangle>)
  rect.%rect-max-y - rect.%rect-min-y
end;

define method region-contains-position?
    (rect :: <rectangle>, x :: <integer>, y :: <integer>)
 => (contained? :: <boolean>)
  rect.%rect-min-x <= x & rect.%rect-min-y <= y
  & rect.%rect-max-x >= x & rect.%rect-max-y >= y
end;

define method region-contains-region?
    (rect1 :: <rectangle>, rect2 :: <rectangle>)
 => (contained? :: <boolean>)
  rect1.%rect-min-x <= rect2.%rect-min-x
  & rect1.%rect-min-y <= rect2.%rect-min-y
  & rect1.%rect-max-x >= rect2.%rect-max-x
  & rect1.%rect-max-y >= rect2.%rect-max-y
end method region-contains-region?;
