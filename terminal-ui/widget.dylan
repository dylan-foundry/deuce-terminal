module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define open class <widget> (<object>)
  constant slot widget-parent :: false-or(<widget>) = #f,
    init-keyword: parent:;
  constant slot widget-children :: <stretchy-vector> = make(<stretchy-vector>),
    init-keyword: children:;
  slot widget-origin :: <point> = make(<point>, x: 0, y: 0),
    init-keyword: origin:;
  slot widget-size :: <point> = make(<point>, x: 0, y: 0),
    init-keyword: size:;
end class <widget>;

define method initialize (widget :: <widget>, #key)
 => ()
  next-method();
  let parent = widget-parent(widget);
  if (parent)
    add!(widget-children(parent), widget);
  end if;
end method initialize;

define method draw-widget (widget :: <widget>, renderbuffer :: <TickitRenderBuffer*>)
  do(method (w :: <widget>)
       draw-widget(w, renderbuffer);
     end,
     widget-children(widget));
end;
