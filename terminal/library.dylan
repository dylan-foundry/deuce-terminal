module: dylan-user
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define library terminal
  use dylan;
  use common-dylan;
  use c-ffi;
  use io;

  export terminal, tickit;
end library;

define module tickit
  use common-dylan;
  use c-ffi;

  export
    $default-pen,
    $everywhere,
    $TICKIT-EV-CHANGE,
    $TICKIT-EV-KEY,
    $TICKIT-EV-MOUSE,
    $TICKIT-EV-RESIZE,
    $TICKIT-EV-UNBIND,
    $TICKIT-KEYEV-KEY,
    $TICKIT-KEYEV-TEXT,
    $TICKIT-LINE-DOUBLE,
    $TICKIT-LINE-SINGLE,
    $TICKIT-LINE-THICK,
    $TICKIT-LINECAP-BOTH,
    $TICKIT-LINECAP-END,
    $TICKIT-LINECAP-START,
    $TICKIT-MAYBE,
    $TICKIT-MOD-ALT,
    $TICKIT-MOD-CTRL,
    $TICKIT-MOD-SHIFT,
    $TICKIT-MOUSEEV-DRAG,
    $TICKIT-MOUSEEV-PRESS,
    $TICKIT-MOUSEEV-RELEASE,
    $TICKIT-MOUSEEV-WHEEL,
    $TICKIT-MOUSEWHEEL-DOWN,
    $TICKIT-MOUSEWHEEL-UP,
    $TICKIT-N-PEN-ATTRS,
    $TICKIT-NO,
    $TICKIT-PEN-ALTFONT,
    $TICKIT-PEN-BG,
    $TICKIT-PEN-BLINK,
    $TICKIT-PEN-BOLD,
    $TICKIT-PEN-FG,
    $TICKIT-PEN-ITALIC,
    $TICKIT-PEN-REVERSE,
    $TICKIT-PEN-STRIKE,
    $TICKIT-PEN-UNDER,
    $TICKIT-PENTYPE-BOOL,
    $TICKIT-PENTYPE-COLOUR,
    $TICKIT-PENTYPE-INT,
    $TICKIT-TERM-CURSORSHAPE-BLOCK,
    $TICKIT-TERM-CURSORSHAPE-LEFT-BAR,
    $TICKIT-TERM-CURSORSHAPE-UNDER,
    $TICKIT-TERM-MOUSEMODE-CLICK,
    $TICKIT-TERM-MOUSEMODE-DRAG,
    $TICKIT-TERM-MOUSEMODE-MOVE,
    $TICKIT-TERM-MOUSEMODE-OFF,
    $TICKIT-TERMCTL-ALTSCREEN,
    $TICKIT-TERMCTL-COLORS,
    $TICKIT-TERMCTL-CURSORBLINK,
    $TICKIT-TERMCTL-CURSORSHAPE,
    $TICKIT-TERMCTL-CURSORVIS,
    $TICKIT-TERMCTL-ICON-TEXT,
    $TICKIT-TERMCTL-ICONTITLE-TEXT,
    $TICKIT-TERMCTL-KEYPAD-APP,
    $TICKIT-TERMCTL-MOUSE,
    $TICKIT-TERMCTL-TITLE-TEXT,
    $TICKIT-YES,
    <TickitEvent*>,
    <TickitEvent>,
    <TickitEventType>,
    <TickitKeyEventType>,
    <TickitLineCaps>,
    <TickitLineStyle>,
    <TickitMaybeBool>,
    <TickitMouseEventType>,
    <TickitPen*>,
    <TickitPen>,
    <TickitPenAttr>,
    <TickitPenAttrType>,
    <TickitPenEventFn*>,
    <TickitPenEventFn>,
    <TickitRect*>,
    <TickitRect<@3>>,
    <TickitRect<@4>>,
    <TickitRect<@>>,
    <TickitRect>,
    <TickitRectSet*>,
    <TickitRectSet>,
    <TickitRenderBuffer*>,
    <TickitRenderBuffer>,
    <TickitRenderBufferLineMask>,
    <TickitRenderBufferSpanInfo*>,
    <TickitRenderBufferSpanInfo>,
    <TickitStringPos*>,
    <TickitStringPos>,
    <TickitTerm*>,
    <TickitTerm>,
    <TickitTermCtl>,
    <TickitTermCursorShape>,
    <TickitTermEventFn*>,
    <TickitTermEventFn>,
    <TickitTermMouseMode>,
    <TickitTermOutputFunc*>,
    <TickitTermOutputFunc>,
    <TickitWindow*>,
    <TickitWindow>,
    <TickitWindowExposeFn*>,
    <TickitWindowExposeFn>,
    <TickitWindowGeometryChangedFn*>,
    <TickitWindowGeometryChangedFn>,
    <int*>,
    TickitEvent$button,
    TickitEvent$button-setter,
    TickitEvent$col,
    TickitEvent$col-setter,
    TickitEvent$cols,
    TickitEvent$cols-setter,
    TickitEvent$line,
    TickitEvent$line-setter,
    TickitEvent$lines,
    TickitEvent$lines-setter,
    TickitEvent$mod,
    TickitEvent$mod-setter,
    TickitEvent$str,
    TickitEvent$str-setter,
    TickitEvent$type,
    TickitEvent$type-setter,
    TickitRect$cols,
    TickitRect$cols-setter,
    TickitRect$left,
    TickitRect$left-setter,
    TickitRect$lines,
    TickitRect$lines-setter,
    TickitRect$top,
    TickitRect$top-setter,
    TickitRenderBufferLineMask$east,
    TickitRenderBufferLineMask$east-setter,
    TickitRenderBufferLineMask$north,
    TickitRenderBufferLineMask$north-setter,
    TickitRenderBufferLineMask$south,
    TickitRenderBufferLineMask$south-setter,
    TickitRenderBufferLineMask$west,
    TickitRenderBufferLineMask$west-setter,
    TickitRenderBufferSpanInfo$is-active,
    TickitRenderBufferSpanInfo$is-active-setter,
    TickitRenderBufferSpanInfo$len,
    TickitRenderBufferSpanInfo$len-setter,
    TickitRenderBufferSpanInfo$n-columns,
    TickitRenderBufferSpanInfo$n-columns-setter,
    TickitRenderBufferSpanInfo$pen,
    TickitRenderBufferSpanInfo$pen-setter,
    TickitRenderBufferSpanInfo$text,
    TickitRenderBufferSpanInfo$text-setter,
    TickitStringPos$bytes,
    TickitStringPos$bytes-setter,
    TickitStringPos$codepoints,
    TickitStringPos$codepoints-setter,
    TickitStringPos$columns,
    TickitStringPos$columns-setter,
    TickitStringPos$graphemes,
    TickitStringPos$graphemes-setter,
    note-window-exposed,
    note-window-geometry-changed,
    tickit-pen-attrname,
    tickit-pen-attrtype,
    tickit-pen-bind-event,
    tickit-pen-clear,
    tickit-pen-clear-attr,
    tickit-pen-clone,
    tickit-pen-copy,
    tickit-pen-copy-attr,
    tickit-pen-destroy,
    tickit-pen-equiv,
    tickit-pen-equiv-attr,
    tickit-pen-get-bool-attr,
    tickit-pen-get-colour-attr,
    tickit-pen-get-int-attr,
    tickit-pen-has-attr,
    tickit-pen-is-nondefault,
    tickit-pen-is-nonempty,
    tickit-pen-lookup-attr,
    tickit-pen-new,
    tickit-pen-nondefault-attr,
    tickit-pen-set-bool-attr,
    tickit-pen-set-colour-attr,
    tickit-pen-set-colour-attr-desc,
    tickit-pen-set-int-attr,
    tickit-pen-unbind-event-id,
    tickit-rect-add,
    tickit-rect-contains,
    tickit-rect-init-bounded,
    tickit-rect-init-sized,
    tickit-rect-intersect,
    tickit-rect-intersects,
    tickit-rect-subtract,
    tickit-rect-translate,
    tickit-rectset-add,
    tickit-rectset-clear,
    tickit-rectset-contains,
    tickit-rectset-destroy,
    tickit-rectset-get-rects,
    tickit-rectset-intersects,
    tickit-rectset-new,
    tickit-rectset-rects,
    tickit-rectset-subtract,
    tickit-renderbuffer-blit,
    tickit-renderbuffer-char,
    tickit-renderbuffer-char-at,
    tickit-renderbuffer-clear,
    tickit-renderbuffer-clip,
    tickit-renderbuffer-destroy,
    tickit-renderbuffer-erase,
    tickit-renderbuffer-erase-at,
    tickit-renderbuffer-erase-to,
    tickit-renderbuffer-eraserect,
    tickit-renderbuffer-flush-to-term,
    tickit-renderbuffer-get-cell-active,
    tickit-renderbuffer-get-cell-pen,
    tickit-renderbuffer-get-cell-text,
    tickit-renderbuffer-get-cursorpos,
    tickit-renderbuffer-get-size,
    tickit-renderbuffer-get-span,
    tickit-renderbuffer-goto,
    tickit-renderbuffer-has-cursorpos,
    tickit-renderbuffer-hline-at,
    tickit-renderbuffer-mask,
    tickit-renderbuffer-new,
    tickit-renderbuffer-reset,
    tickit-renderbuffer-restore,
    tickit-renderbuffer-save,
    tickit-renderbuffer-savepen,
    tickit-renderbuffer-setpen,
    tickit-renderbuffer-skip,
    tickit-renderbuffer-skip-at,
    tickit-renderbuffer-skip-to,
    tickit-renderbuffer-text,
    tickit-renderbuffer-text-at,
    tickit-renderbuffer-textn,
    tickit-renderbuffer-textn-at,
    tickit-renderbuffer-translate,
    tickit-renderbuffer-ungoto,
    tickit-renderbuffer-vline-at,
    tickit-string-byte2col,
    tickit-string-col2byte,
    tickit-string-count,
    tickit-string-countmore,
    tickit-string-mbswidth,
    tickit-string-ncount,
    tickit-string-ncountmore,
    tickit-string-putchar,
    tickit-string-seqlen,
    tickit-term-await-started,
    tickit-term-bind-event,
    tickit-term-chpen,
    tickit-term-clear,
    tickit-term-destroy,
    tickit-term-erasech,
    tickit-term-flush,
    tickit-term-get-input-fd,
    tickit-term-get-output-fd,
    tickit-term-get-size,
    tickit-term-get-termtype,
    tickit-term-get-utf8,
    tickit-term-getctl-int,
    tickit-term-goto,
    tickit-term-input-check-timeout,
    tickit-term-input-push-bytes,
    tickit-term-input-readable,
    tickit-term-input-wait,
    tickit-term-move,
    tickit-term-new,
    tickit-term-new-for-termtype,
    tickit-term-print,
    tickit-term-printn,
    tickit-term-refresh-size,
    tickit-term-scrollrect,
    tickit-term-set-input-fd,
    tickit-term-set-output-buffer,
    tickit-term-set-output-fd,
    tickit-term-set-output-func,
    tickit-term-set-size,
    tickit-term-set-utf8,
    tickit-term-setctl-int,
    tickit-term-setctl-str,
    tickit-term-setpen,
    tickit-term-unbind-event-id,
    tickit-window-abs-left,
    tickit-window-abs-top,
    tickit-window-cols,
    tickit-window-cursor-at,
    tickit-window-cursor-shape,
    tickit-window-cursor-visible,
    tickit-window-destroy,
    tickit-window-expose,
    tickit-window-focus,
    tickit-window-hide,
    tickit-window-is-focused,
    tickit-window-is-visible,
    tickit-window-left,
    tickit-window-lines,
    tickit-window-lower,
    tickit-window-lower-to-back,
    tickit-window-new-float,
    tickit-window-new-hidden-subwindow,
    tickit-window-new-popup,
    tickit-window-new-root,
    tickit-window-new-subwindow,
    tickit-window-notify-on-expose,
    tickit-window-notify-on-geometry-changed,
    tickit-window-raise,
    tickit-window-raise-to-front,
    tickit-window-reposition,
    tickit-window-resize,
    tickit-window-set-geometry,
    tickit-window-set-on-focus,
    tickit-window-set-pen,
    tickit-window-show,
    tickit-window-take-focus,
    tickit-window-tick,
    tickit-window-top;
end module;

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

  export <position>,
         make-position,
         position-position,
         position-line,
         position-col;

  export <rectangle>,
         make-rectangle,
         rectangle-min-position,
         rectangle-max-position,
         rectangle-width,
         rectangle-height,
         rectangle-size;

  export region-contains-position?,
         region-contains-region?;
end module;
