module: dt
author: Bruce Mitchener, Jr.
copyright: See LICENSE file in this distribution.

define constant $initially-disabled-commands
    = vector(save-file, find-next-string,
             undo-command, redo-command,
             compile-file, load-file,
             evaluate-region, evaluate-buffer, macroexpand-region,
             describe-object, browse-object, browse-class,
             show-arglist, show-documentation);

define function main (name :: <string>, arguments :: <vector>)
  terminal-init();
  let editor = make(<deuce-editor>);
  let frame = make(<deuce-frame>,
                   title: "Deuce",
                   editor: editor,
                   disabled-commands: $initially-disabled-commands);
  let buffer = make-initial-buffer(editor: editor);
  dynamic-bind (*editor-frame* = frame,
                *buffer* = buffer)
    select-buffer(frame-window(frame), buffer);
    start-frame(frame);
    execute-command-in-frame(frame, insert-file);
    terminal-ui-dispatch-events(frame-window(frame));
  end
end function main;

main(application-name(), application-arguments());
