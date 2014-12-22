module: tickit

define interface
  #include {
      "tickit.h",
      "tickit-window.h"
    },
    exclude: {
      "tickit_pen_new_attrs",
      "tickit_renderbuffer_get_cell_linemask",
      "tickit_rect_bottom",
      "tickit_rect_right",
      "tickit_stringpos_limit_bytes",
      "tickit_stringpos_limit_codepoints",
      "tickit_stringpos_limit_columns",
      "tickit_stringpos_limit_graphemes",
      "tickit_stringpos_limit_none",
      "tickit_stringpos_zero",
      "tickit_term_await_started_tv",
      "tickit_term_input_wait_tv",
      "tickit_term_printf",
      "tickit_term_vprintf"
    },
    rename: {
      "tickit_term_await_started_msec" => tickit-term-await-started,
      "tickit_term_input_check_timeout_msec" => tickit-term-input-check-timeout,
      "tickit_term_input_wait_msec" => tickit-term-input-wait
    },
    equate: {
      "char *" => <c-string>
    };

  function "tickit_rect_intersect",
    output-argument: 1;

  function "tickit_term_get_size",
    output-argument: 2,
    output-argument: 3;

  function "tickit_term_getctl_int",
    output-argument: 3;

  function "tickit_renderbuffer_get_size",
    output-argument: 2,
    output-argument: 3;
end interface;
