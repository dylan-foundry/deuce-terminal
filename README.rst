deuce-terminal
==============

``deuce-terminal`` is a terminal-based interface to the Deuce editor
written in `Dylan`_.

It provides a minimal UI toolkit for working with the terminal which
is layered on top of `libtickit`_ and `libtermkey`_. It then provides
an implementation of the Deuce interfaces required to hook it up to
this new user interface library.

What is Deuce?
--------------

Deuce is a descendant of ZWEI, which was itself a descendant of early
emacs and was written by Scott McKay at `Harlequin`_.

Scott wrote a bit about what makes Deuce different in a `newsgroup
posting`_::

    gnuemacs is quite different from the Eine/Zwei family of
    editors, in that it uses the "bigline" structure to model the
    contents of its buffers.  Hemlock and the LW editor also
    use this representation.  Buffer pointers (BPs) are then simply
    integers that point into the bigline.  This can be a very space-
    efficient structure, but the downside is that it is very hard to
    have any sort of polymorphic "line" object.  This makes it
    much tougher to do things like graphics; a friend from Lucid
    told me that Jamie Zawinski, a formidable hacker, spent about
    a year a year wrestling with gnuemacs before he could make
    it general enough to do the sorts of things he got Xemacs to do.

    Zwei models buffers as linked lists of line objects, and BPs
    are a pair {line,index}.  This makes it easier to do some
    clever stuff in Zwei, but IIRC lines in Zwei are structures,
    not classes, so it turned out that we had to wrestle quite a
    bit with Zwei to get display of multiple fonts and graphics
    to work (on the order of many weeks).

    The editor for FunO's Dylan product -- Deuce --  is the
    next generation of Zwei in many ways.  It has first class
    polymorphic lines, first class BPs, and introduces the idea
    first class "source containers" and "source sections".  A
    buffer is then dynamically composed of "section nodes".
    This extra generality costs in space (it takes about 2 bytes of
    storage for every byte in a source file, whereas gnuemacs
    and the LW editor takes about 1 byte), and it costs a little
    in performance, but in return it's much easier to build some
    cool features:

    - Multiple fonts and colors fall right out (it took me about
      1 day to get this working, and most of the work for fonts
      was because FunO Dylan doesn't have built-in support for
      "rich characters", so I had to roll my own).
    - Graphics display falls right out (e.g., the display of a buffer
      can show lines that separate sections, and there is a column
      of icons that show where breakpoints are set, where there
      are compiler warnings, etc.  Doing both these things took
      less than 1 day, but a comparable feature in Zwei took a
      week.  I wonder how long it took to do the icons in Lucid's
      C/C++ environment, whose name I can't recall.)
    - "Composite buffers" (buffers built by generating functions
      such as "callers of 'foo'" or "subclasses of 'window') fall right
      out of this design, and again, it took less than a day to do this.
      It took a very talented hacker more than a month to build a
      comparable (but non-extensible) version in Zwei for an in-house
      VC system, and it never really worked right.

    Of course, the Deuce design was driven by knowing about the
    sorts of things that gnuemacs and Zwei didn't get right (*).  It's so
    much easier to stand on other people shoulders...

    (*) By "didn't get right" I really mean that gnuemacs and Zwei had
    design goals different from Deuce, and in fact, they both had initial
    design goals that were different from where they ended up.

Build
-----

Be sure that you have cloned this repository recursively or have
initialized and updated the submodules. (Without doing this, the
``tickit`` binding library won't be found.)

The sources for Deuce itself are part of the standard Open Dylan
distribution.

For now, customized versions of `libtermkey`_ and `libtickit`_ have
been included within ``deuce-terminal``, so you won't have to install
these on your own.

Once that is done, building ``deuce-terminal`` should be as easy
as running ``make``. The resulting binary will be ``_build/bin/dt``.

.. _Dylan: http://opendylan.org/
.. _libtickit: http://www.leonerd.org.uk/code/libtickit/
.. _libtermkey: http://www.leonerd.org.uk/code/libtermkey/
.. _Harlequin: http://en.wikipedia.org/wiki/Harlequin_(software_company)
.. _newsgroup posting: https://groups.google.com/forum/#!msg/comp.lang.dylan/3uuUb3Z9pAc/6NbE9gYpeAIJ
