module: terminal-ui
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <label> (<widget>)
  slot label-text :: <string> = "", init-keyword: text:;
end class <label>;

define method draw-widget(label :: <label>, renderbuffer :: <TickitRenderBuffer*>)
 => ()
  let pen = tickit-pen-new();
  tickit-renderbuffer-save(renderbuffer);
  let origin = widget-origin(label);
  tickit-renderbuffer-translate(renderbuffer, origin.position-line, origin.position-col);
  tickit-renderbuffer-text-at(renderbuffer, 0, 0, label-text(label), pen);
  tickit-renderbuffer-restore(renderbuffer);
end method draw-widget;
