#include <stdio.h>

int terminal_get_stdin_fileno(void)
{
  return fileno(stdin);
}

int terminal_get_stdout_fileno(void)
{
  return fileno(stdout);
}

