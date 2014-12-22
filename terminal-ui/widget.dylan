module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define open class <widget> (<object>)
  slot widget-window :: false-or(<TickitWindow*>) = #f,
    setter: %widget-window-setter;
  constant slot widget-parent :: false-or(<widget>) = #f,
    init-keyword: parent:;
  constant slot widget-children :: <stretchy-vector> = make(<stretchy-vector>),
    init-keyword: children:;
end class <widget>;

define open generic note-widget-window-lost
    (widget :: <widget>, window :: <TickitWindow*>)
 => ();

define open generic note-widget-window-gained
    (widget :: <widget>, window :: <TickitWindow*>)
 => ();

define open generic queue-repaint
    (widget :: <widget>, rect :: <TickitRect*>)
 => ();

define open generic handle-repaint
    (widget :: <widget>, renderbuffer :: <TickitRenderBuffer*>,
     rect :: <TickitRect*>)
 => ();

define method initialize (widget :: <widget>, #key)
 => ()
  next-method();
  let parent = widget-parent(widget);
  if (parent)
    add!(widget-children(parent), widget);
  end if;
end method initialize;

define method widget-window-setter (window :: <TickitWindow*>, widget :: <widget>)
  block (return)
    if (~window & ~widget-window(widget))
      return();
    end if;

    if (window == widget-window(widget))
      return();
    end if;

    if (widget-window(widget) & ~window)
      tickit-window-set-pen(window, #f);
      note-widget-window-lost(widget, widget-window(widget));
    end if;

    %widget-window(widget) := window;

    if (window)
      note-widget-window-gained(widget, window);
      // TODO: Take focus if focus is pending.
      reshape-widget(widget);
      queue-repaint(widget, $everywhere);
    end if;
  end block;
end method widget-window-setter;

define method note-widget-window-lost
    (widget :: <widget>, window :: <TickitWindow*>)
 => ()
  // TODO: Clear callbacks on the window.
end method note-widget-window-lost;

define method note-widget-window-gained
    (widget :: <widget>, window :: <TickitWindow*>)
 => ()
  tickit-window-notify-on-expose(window, widget);
  tickit-window-notify-on-geometry-changed(window, widget);
end method note-widget-window-gained;

define method note-window-exposed
    (widget :: <widget>, window :: <TickitWindow*>,
     rect :: <TickitRect*>, rb :: <TickitRenderBuffer*>)
 => ()
  handle-repaint(widget, rb, rect);
end method note-window-exposed;

define method note-window-geometry-changed
    (widget :: <widget>, window :: <TickitWindow*>)
 => ()
  reshape-widget(widget);
end method note-window-geometry-changed;

define method reshape-widget (widget :: <widget>)
end method reshape-widget;

define method queue-repaint
    (widget :: <widget>, rect :: <TickitRect*>)
 => ()
  if (widget-window(widget))
    tickit-window-expose(widget-window(widget), rect);
  end if;
end method queue-repaint;

define method handle-repaint
    (widget :: <widget>, renderbuffer :: <TickitRenderBuffer*>,
     rect :: <TickitRect*>)
 => ()
end method handle-repaint;
