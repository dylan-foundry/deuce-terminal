#include <stdio.h>
#include "tickit.h"

int terminal_get_stdin_fileno(void)
{
  return fileno(stdin);
}

int terminal_get_stdout_fileno(void)
{
  return fileno(stdout);
}

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

