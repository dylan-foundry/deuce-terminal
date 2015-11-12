module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <label> (<widget>)
  slot label-text :: <string> = "",
    init-keyword: text:, setter: %label-text-setter;
  slot label-pen :: <TickitPen*> = null-pointer(<TickitPen*>),
    init-keyword: pen:;
end class <label>;

define method label-text-setter
    (text :: <string>, label :: <label>)
 => (text :: <string>)
  %label-text(label) := text;
  queue-repaint(label, $everywhere);
  text
end method label-text-setter;

define method handle-repaint
    (label :: <label>, renderbuffer :: <TickitRenderBuffer*>,
     rect :: <TickitRect*>)
 => ()
  tickit-renderbuffer-setpen(renderbuffer, label-pen(label));
  tickit-renderbuffer-text-at(renderbuffer, 0, 0, label-text(label));
end method handle-repaint;
