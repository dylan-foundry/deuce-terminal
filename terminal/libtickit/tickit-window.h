#ifdef __cplusplus
extern "C" {
#endif

#ifndef __TICKIT_WINDOW_H__
#define __TICKIT_WINDOW_H__

#include "tickit.h"

typedef struct TickitWindow TickitWindow;

/* Root window */

TickitWindow *tickit_window_new_root(TickitTerm *term);

/* Windows */

TickitWindow *tickit_window_new_subwindow(TickitWindow *parent, int top, int left, int lines, int cols);
TickitWindow *tickit_window_new_hidden_subwindow(TickitWindow *parent, int top, int left, int lines, int cols);
TickitWindow *tickit_window_new_float(TickitWindow *parent, int top, int left, int lines, int cols);
TickitWindow *tickit_window_new_popup(TickitWindow *parent, int top, int left, int lines, int cols);

void tickit_window_destroy(TickitWindow *window);

/* Layering */

void tickit_window_raise(TickitWindow *window);
void tickit_window_raise_to_front(TickitWindow *window);
void tickit_window_lower(TickitWindow *window);
void tickit_window_lower_to_back(TickitWindow *window);

/* Visibility */

void tickit_window_show(TickitWindow *window);
void tickit_window_hide(TickitWindow *window);
bool tickit_window_is_visible(TickitWindow *window);

/* Geometry management */

int tickit_window_top(const TickitWindow *window);
int tickit_window_abs_top(const TickitWindow *window);
int tickit_window_left(const TickitWindow *window);
int tickit_window_abs_left(const TickitWindow *window);
int tickit_window_lines(const TickitWindow *window);
int tickit_window_cols(const TickitWindow *window);

void tickit_window_resize(TickitWindow *window, int lines, int cols);
void tickit_window_reposition(TickitWindow *window, int top, int left);
void tickit_window_set_geometry(TickitWindow *window, int top, int left, int lines, int cols);

typedef void TickitWindowGeometryChangedFn(TickitWindow *window, void *data);
void tickit_window_set_on_geometry_changed(TickitWindow *window, TickitWindowGeometryChangedFn *fn, void *data);

/* Drawing */
void tickit_window_set_pen(TickitWindow *window, TickitPen *pen);

void tickit_window_expose(TickitWindow *window, const TickitRect *exposed);

typedef void TickitWindowExposeFn(TickitWindow *window, const TickitRect *rect, TickitRenderBuffer *rb, void *data);
void tickit_window_set_on_expose(TickitWindow *window, TickitWindowExposeFn *fn, void *data);

#endif

#ifdef __cplusplus
}
#endif
