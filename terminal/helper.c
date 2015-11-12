#include "tickit.h"

int terminal_window_lines(TickitWindow *window)
{
  TickitRect rect = tickit_window_get_geometry(window);
  return rect.lines;
}

int terminal_window_cols(TickitWindow *window)
{
  TickitRect rect = tickit_window_get_geometry(window);
  return rect.cols;
}

