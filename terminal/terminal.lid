library: terminal
files: library
       geometry
       terminal
       tickit
C-libraries: -lncurses
c-source-files: helper.c
       libtermkey/driver-csi.c
       libtermkey/driver-ti.c
       libtermkey/termkey.c
       libtickit/hooklists.c
       libtickit/mockterm.c
       libtickit/pen.c
       libtickit/rect.c
       libtickit/rectset.c
       libtickit/renderbuffer.c
       libtickit/string.c
       libtickit/term.c
       libtickit/termdriver-ti.c
       libtickit/termdriver-xterm.c
       libtickit/window.c
c-header-files: libtermkey/termkey-internal.h
       libtermkey/termkey.h
       libtickit/hooklists.h
       libtickit/termdriver.h
       libtickit/tickit-mockterm.h
       libtickit/tickit-termdrv.h
       libtickit/tickit-window.h
       libtickit/tickit.h
       libtickit/unicode.h
       libtickit/linechars.inc
       libtickit/xterm-palette.inc
