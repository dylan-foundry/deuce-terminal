module: deuce-terminal
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define class <deuce-frame> (<basic-editor-frame>)
  // slot frame-status-bar;
end class <deuce-frame>;

define method initialize (frame :: <deuce-frame>, #key) => ()
  next-method();
  frame-window(frame) := make(<deuce-terminal-window>, frame: frame, line-spacing: 0);
  // frame-status-bar(frame) := make-deuce-status-bar(frame);
end method initialize;

define method start-frame (frame :: <deuce-frame>)
  // Set up thread variables and initial buffer
  let window :: false-or(<basic-window>) = frame-window(frame);
  let buffer :: false-or(<basic-buffer>) = frame-buffer(frame);
  *editor-frame* := frame;
  *buffer*       := buffer;
  let policy = editor-policy(frame-editor(frame));
  window-note-policy-changed(frame-window(frame), policy, #f);
  unless (window & buffer == window-buffer(window))
    select-buffer(window, buffer);
    queue-redisplay(window, $display-all);
    redisplay-window(window)
  end
end method start-frame;
