#include "tickit-window.h"

#include <stdio.h>

/* TODO:
 * Event handling.
 * Focus handling.
 * The "later" system that lets us trigger actual changes.
 */

#define ROOT_AS_WINDOW(root) (TickitWindow*)root
#define WINDOW_AS_ROOT(window) (TickitRootWindow*)window

typedef enum {
  TICKIT_HIERARCHY_INSERT_FIRST,
  TICKIT_HIERARCHY_INSERT_LAST,
  TICKIT_HIERARCHY_REMOVE,
  TICKIT_HIERARCHY_RAISE,
  TICKIT_HIERARCHY_RAISE_FRONT,
  TICKIT_HIERARCHY_LOWER,
  TICKIT_HIERARCHY_LOWER_BACK
} TickitHierarchyChangeType;

typedef enum {
  TICKIT_IMMEDIATE,
  TICKIT_DEFER
} TickitWhen;

struct TickitWindowCursorData {
  int line;
  int col;
  TickitTermCursorShape shape;
  bool visible;
};

struct TickitWindow {
  TickitWindow *parent;
  TickitWindow *children;
  TickitWindow *next;
  TickitWindow *focused_child;
  TickitPen *pen;
  TickitRect rect;
  struct TickitWindowCursorData cursor;
  bool is_visible;
  bool is_focused;
  bool steal_input;
  bool focus_child_notify;

  /* Callbacks */
  TickitWindowExposeFn *on_expose;
  void *on_expose_data;
  TickitWindowFocusFn *on_focus;
  void *on_focus_data;
  TickitWindowGeometryChangedFn *on_geometry_changed;
  void *on_geometry_changed_data;
};

typedef struct HierarchyChange HierarchyChange;
struct HierarchyChange {
  TickitHierarchyChangeType change;
  TickitWindow *parent;
  TickitWindow *window;
  HierarchyChange *next;
};

typedef struct TickitRootWindow TickitRootWindow;
struct TickitRootWindow {
  TickitWindow window;

  TickitTerm *term;
  TickitRectSet *damage;
  HierarchyChange *hierarchy_changes;
  bool needs_expose;
  bool needs_restore;
  bool needs_later_processing;
};

static void _request_restore(TickitRootWindow *root);
static void _request_later_processing(TickitRootWindow *root);
static void _request_hierarchy_change(TickitHierarchyChangeType, TickitWindow*, TickitWhen);
static void _do_hierarchy_change(TickitHierarchyChangeType change, TickitWindow *parent, TickitWindow *window);
static void _purge_hierarchy_changes(TickitWindow *window);

static void init_window(TickitWindow *window, TickitWindow *parent, int top, int left, int lines, int cols)
{
  window->parent = parent;
  window->children = NULL;
  window->next = NULL;
  window->focused_child = NULL;
  window->pen = NULL;
  window->rect.top = top;
  window->rect.left = left;
  window->rect.lines = lines;
  window->rect.cols = cols;
  window->cursor.line = 0;
  window->cursor.col = 0;
  window->cursor.shape = TICKIT_TERM_CURSORSHAPE_BLOCK;
  window->cursor.visible = false;
  window->is_visible = true;
  window->is_focused = false;
  window->steal_input = false;
  window->focus_child_notify = false;

  window->on_expose = NULL;
  window->on_expose_data = NULL;
  window->on_focus = NULL;
  window->on_focus_data = NULL;
  window->on_geometry_changed = NULL;
  window->on_geometry_changed_data = NULL;
}

static TickitWindow* new_window(TickitWindow *parent, int top, int left, int lines, int cols)
{
  TickitWindow *window = malloc(sizeof(TickitWindow));
  if(!window)
    return NULL;

  init_window(window, parent, top, left, lines, cols);

  return window;
}

TickitWindow* tickit_window_new_root(TickitTerm *term)
{
  int lines, cols;
  tickit_term_get_size(term, &lines, &cols);

  TickitRootWindow *root = malloc(sizeof(TickitRootWindow));
  if(!root)
    return NULL;

  init_window(ROOT_AS_WINDOW(root), NULL, 0, 0, lines, cols);

  root->term = term;
  root->hierarchy_changes = NULL;
  root->needs_expose = false;
  root->needs_restore = false;
  root->needs_later_processing = false;

  root->damage = tickit_rectset_new();
  if(!root->damage) {
    tickit_window_destroy(ROOT_AS_WINDOW(root));
    return NULL;
  }
  return ROOT_AS_WINDOW(root);
}

static TickitRootWindow *_get_root(TickitWindow *window)
{
  TickitWindow *root = window;
  while(root->parent) {
    root = root->parent;
  }
  return WINDOW_AS_ROOT(root);
}

TickitWindow *tickit_window_new_subwindow(TickitWindow *parent, int top, int left, int lines, int cols)
{
  TickitWindow *window = new_window(parent, top, left, lines, cols);
  _request_hierarchy_change(TICKIT_HIERARCHY_INSERT_LAST, window, TICKIT_DEFER);
  return window;
}

TickitWindow *tickit_window_new_hidden_subwindow(TickitWindow *parent, int top, int left, int lines, int cols)
{
  TickitWindow *window = new_window(parent, top, left, lines, cols);
  _request_hierarchy_change(TICKIT_HIERARCHY_INSERT_LAST, window, TICKIT_DEFER);
  window->is_visible = false;
  return window;
}

TickitWindow *tickit_window_new_float(TickitWindow *parent, int top, int left, int lines, int cols)
{
  TickitWindow *window = new_window(parent, top, left, lines, cols);
  _request_hierarchy_change(TICKIT_HIERARCHY_INSERT_FIRST, window, TICKIT_DEFER);
  return window;
}

TickitWindow *tickit_window_new_popup(TickitWindow *parent, int top, int left, int lines, int cols)
{
  TickitWindow *root = parent;
  while(root->parent) {
    top += root->rect.top;
    left += root->rect.left;
    root = root->parent;
  }
  TickitWindow *window = new_window(root, top, left, lines, cols);
  _request_hierarchy_change(TICKIT_HIERARCHY_INSERT_FIRST, window, TICKIT_DEFER);
  window->steal_input = true;
  return window;
}

void tickit_window_destroy(TickitWindow *window)
{
  window->pen = NULL;

  window->on_expose = NULL;
  window->on_expose_data = NULL;
  window->on_focus = NULL;
  window->on_focus_data = NULL;
  window->on_geometry_changed = NULL;
  window->on_geometry_changed_data = NULL;

  TickitWindow *child = window->children;
  while(child) {
   tickit_window_destroy(child);
   child = window->children;
  }

  _purge_hierarchy_changes(window);

  if(window->parent) {
    _request_hierarchy_change(TICKIT_HIERARCHY_REMOVE, window, TICKIT_IMMEDIATE);
  }

  /* Root cleanup */
  if(!window->parent) {
    TickitRootWindow *root = WINDOW_AS_ROOT(window);
    if(root->damage) {
      tickit_rectset_destroy(root->damage);
    }
  }
  free(window);
}

void tickit_window_raise(TickitWindow *window)
{
  _request_hierarchy_change(TICKIT_HIERARCHY_RAISE, window, TICKIT_DEFER);
}

void tickit_window_raise_to_front(TickitWindow *window)
{
  _request_hierarchy_change(TICKIT_HIERARCHY_RAISE_FRONT, window, TICKIT_DEFER);
}

void tickit_window_lower(TickitWindow *window)
{
  _request_hierarchy_change(TICKIT_HIERARCHY_LOWER, window, TICKIT_DEFER);
}

void tickit_window_lower_to_back(TickitWindow *window)
{
  _request_hierarchy_change(TICKIT_HIERARCHY_LOWER_BACK, window, TICKIT_DEFER);
}

void tickit_window_show(TickitWindow *window)
{
  window->is_visible = true;
  if(window->parent) {
    if(!window->parent && (window->focused_child || window->is_focused)) {
      window->focused_child = window;
    }
  }
  tickit_window_expose(window, NULL);
}

void tickit_window_hide(TickitWindow *window)
{
  window->is_visible = false;

  if(window->parent) {
    TickitWindow *parent = window->parent;
    if(parent->focused_child && (parent->focused_child == window)) {
      parent->focused_child = NULL;
    }
    tickit_window_expose(parent, &window->rect);
  }
}

bool tickit_window_is_visible(TickitWindow *window)
{
  return window->is_visible;
}

int tickit_window_top(const TickitWindow *window)
{
  return window->rect.top;
}

int tickit_window_abs_top(const TickitWindow *window)
{
  int top = window->rect.top;
  TickitWindow* parent = window->parent;
  while(parent) {
    top += parent->rect.top;
    parent = parent->parent;
  }
  return top;
}

int tickit_window_left(const TickitWindow *window)
{
  return window->rect.left;
}

int tickit_window_abs_left(const TickitWindow *window)
{
  int left = window->rect.left;
  TickitWindow* parent = window->parent;
  while(parent) {
    left += parent->rect.left;
    parent = parent->parent;
  }
  return left;
}

int tickit_window_lines(const TickitWindow *window)
{
  return window->rect.lines;
}

int tickit_window_cols(const TickitWindow *window)
{
  return window->rect.cols;
}

void tickit_window_resize(TickitWindow *window, int lines, int cols)
{
  tickit_window_set_geometry(window, window->rect.top, window->rect.left, lines, cols);
}

void tickit_window_reposition(TickitWindow *window, int top, int left)
{
  tickit_window_set_geometry(window, top, left, window->rect.lines, window->rect.cols);
  if(window->is_focused) {
    _request_restore(_get_root(window));
  }
}

void tickit_window_set_geometry(TickitWindow *window, int top, int left, int lines, int cols)
{
  if((window->rect.top != top) ||
     (window->rect.left != left) ||
     (window->rect.lines != lines) ||
     (window->rect.cols != cols))
  {
    window->rect.top = top;
    window->rect.left = left;
    window->rect.lines = lines;
    window->rect.cols = cols;

    if(window->on_geometry_changed) {
      window->on_geometry_changed(window, window->on_geometry_changed_data);
    }
  }
}

void tickit_window_set_on_geometry_changed(TickitWindow *window, TickitWindowGeometryChangedFn *fn, void *data)
{
  window->on_geometry_changed = fn;
  window->on_geometry_changed_data = data;
}

void tickit_window_set_pen(TickitWindow *window, TickitPen *pen)
{
  /* TODO: Refcounting the pen would be nice. Until then, we assume we don't own it. */
  window->pen = pen;
}

void tickit_window_expose(TickitWindow *window, const TickitRect *exposed)
{
  TickitRect damaged;
  if(exposed) {
    if(!tickit_rect_intersect(&damaged, &window->rect, exposed)) {
      return;
    }
  } else {
    damaged = window->rect;
  }

  if(!window->is_visible) {
    return;
  }

  if(window->parent) {
    tickit_rect_translate(&damaged, window->rect.top, window->rect.left);
    tickit_window_expose(window->parent, &damaged);
    return;
  }

  /* If we're here, then we're a root window. */
  TickitRootWindow *root = WINDOW_AS_ROOT(window);
  if(tickit_rectset_contains(root->damage, &damaged)) {
    return;
  }

  #ifdef DEBUG
  fprintf(stderr, "Damage root %d, %d, %d, %d\n", damaged.top, damaged.left, damaged.lines, damaged.cols);
  #endif

  tickit_rectset_add(root->damage, &damaged);

  root->needs_expose = true;
  _request_later_processing(root);
}

void tickit_window_set_on_expose(TickitWindow *window, TickitWindowExposeFn *fn, void *data)
{
  window->on_expose = fn;
  window->on_expose_data = data;
}

static void _do_expose(TickitWindow *window, const TickitRect *rect, TickitRenderBuffer *rb)
{
  if(window->pen) {
    tickit_renderbuffer_setpen(rb, window->pen);
  }

  for(TickitWindow* child = window->children; child; child = child->next) {
    if(!child->is_visible) {
      continue;
    }

    TickitRect exposed;
    if(tickit_rect_intersect(&exposed, rect, &child->rect)) {
      tickit_renderbuffer_save(rb);

      tickit_renderbuffer_clip(rb, &exposed);
      tickit_renderbuffer_translate(rb, child->rect.top, child->rect.left);
      tickit_rect_translate(&exposed, -child->rect.top, -child->rect.left);
      _do_expose(child, &exposed, rb);

      tickit_renderbuffer_restore(rb);
    }

    tickit_renderbuffer_mask(rb, &child->rect);
  }

  if(window->on_expose) {
    window->on_expose(window, rect, rb, window->on_expose_data);
  }
}

static void _request_restore(TickitRootWindow *root)
{
  root->needs_restore = true;
  _request_later_processing(root);
}

static void _request_later_processing(TickitRootWindow *root)
{
  root->needs_later_processing = true;
}

static void _do_restore(TickitRootWindow *root)
{
  TickitWindow *window = ROOT_AS_WINDOW(root);
  while(window) {
    if(!window->focused_child) {
      break;
    }
    if(!window->focused_child->is_visible) {
      break;
    }
    window = window->focused_child;
  }

  if(window && window->is_focused && window->cursor.visible) {
    /* TODO finish the visibility check here. */
    tickit_term_setctl_int(root->term, TICKIT_TERMCTL_CURSORVIS, 1);
    int cursor_line = window->cursor.line + tickit_window_abs_top(window);
    int cursor_col = window->cursor.col + tickit_window_abs_left(window);
    tickit_term_goto(root->term, cursor_line, cursor_col);
    tickit_term_setctl_int(root->term, TICKIT_TERMCTL_CURSORSHAPE, window->cursor.shape);
  } else {
    tickit_term_setctl_int(root->term, TICKIT_TERMCTL_CURSORVIS, 0);
  }

  tickit_term_flush(root->term);
}

void tickit_window_tick(TickitWindow *window)
{
  if(window->parent) {
    // Can't tick non-root.
    return;
  }
  TickitRootWindow *root = WINDOW_AS_ROOT(window);
  if(!root->needs_later_processing) {
    return;
  }
  root->needs_later_processing = false;

  if(root->hierarchy_changes) {
    HierarchyChange *req = root->hierarchy_changes;
    while(req) {
       _do_hierarchy_change(req->change, req->parent, req->window);
       HierarchyChange *next = req->next;
       free(req);
       req = next;
    }
    root->hierarchy_changes = NULL;
  }

  if(root->needs_expose) {
    root->needs_expose = false;

    TickitWindow *root_window = ROOT_AS_WINDOW(root);
    TickitRenderBuffer *rb = tickit_renderbuffer_new(root_window->rect.lines, root_window->rect.cols);

    int damage_count = tickit_rectset_rects(root->damage);
    TickitRect *rects = alloca(damage_count * sizeof(TickitRect));
    tickit_rectset_get_rects(root->damage, rects, damage_count);

    tickit_rectset_clear(root->damage);

    for(int i = 0; i < damage_count; i++) {
      TickitRect *rect = &rects[i];
      tickit_renderbuffer_save(rb);
      tickit_renderbuffer_clip(rb, rect);
      _do_expose(root_window, rect, rb);
      tickit_renderbuffer_restore(rb);
    }

    tickit_renderbuffer_flush_to_term(rb, root->term);
    tickit_renderbuffer_destroy(rb);

    root->needs_restore = true;
  }

  if(root->needs_restore) {
    root->needs_restore = false;
    _do_restore(root);
  }
}

static void _do_hierarchy_insert_first(TickitWindow *parent, TickitWindow *window)
{
  window->next = parent->children;
  parent->children = window;
}

static void _do_hierarchy_insert_last(TickitWindow *parent, TickitWindow *window)
{
  TickitWindow *chain = parent->children;
  if(!chain) {
    parent->children = window;
  } else {
    while(chain->next != NULL) {
      chain = chain->next;
    }
    chain->next = window;
  }
}

static void _do_hierarchy_remove(TickitWindow *parent, TickitWindow *window)
{
  if(parent->children == window) {
    parent->children = window->next;
  } else {
    for(TickitWindow *child = parent->children; child; child = child->next) {
      if(child->next == window) {
        child->next = window->next;
        break;
      }
    }
  }
}

static void _do_hierarchy_raise(TickitWindow *parent, TickitWindow *window)
{
  /* If not already at the front */
  if(parent->children != window) {
    TickitWindow *prev = NULL;
    for(TickitWindow *curr = parent->children; curr; curr = curr->next) {
      if(curr->next == window) {
        /* We have:
         *  prev -> curr -> window
         * we want:
         *  prev -> window -> curr */
        prev->next = window;
        curr->next = window->next;
        window->next = curr;
        break;
      }
      prev = curr;
    }
  }
}

static void _do_hierarchy_lower(TickitWindow *parent, TickitWindow *window)
{
  if(!window->next) {
    /* Already at the end */
  } else if(parent->children == window) {
    /* First in the list and we know it has children after it. */
    /* A -> B -> C */
    TickitWindow *successor = window->next;
    parent->children = window->next; /* B -> C, A -> B */
    window->next = successor->next; /* B -> C, A -> C */
    successor->next = window; /* B -> A -> C */
  } else {
    for(TickitWindow *child = parent->children; child; child = child->next) {
      if(child->next == window) {
        TickitWindow *successor = window->next;
        child->next = window->next;
        window->next = successor->next;
        successor->next = window;
        break;
      }
    }
  }
}

static void _do_hierarchy_change(TickitHierarchyChangeType change, TickitWindow *parent, TickitWindow *window)
{
  switch(change) {
    case TICKIT_HIERARCHY_INSERT_FIRST:
      _do_hierarchy_insert_first(parent, window);
      break;
    case TICKIT_HIERARCHY_INSERT_LAST:
      _do_hierarchy_insert_last(parent, window);
      break;
    case TICKIT_HIERARCHY_REMOVE: {
        _do_hierarchy_remove(parent, window);
        if(parent->focused_child && parent->focused_child == window) {
          parent->focused_child = NULL;
        }
        break;
      }
    case TICKIT_HIERARCHY_RAISE:
      _do_hierarchy_raise(parent, window);
      break;
    case TICKIT_HIERARCHY_RAISE_FRONT:
      _do_hierarchy_remove(parent, window);
      _do_hierarchy_insert_first(parent, window);
      break;
    case TICKIT_HIERARCHY_LOWER:
      _do_hierarchy_lower(parent, window);
      break;
    case TICKIT_HIERARCHY_LOWER_BACK:
      _do_hierarchy_remove(parent, window);
      _do_hierarchy_insert_last(parent, window);
      break;
  }
}

static void _request_hierarchy_change(TickitHierarchyChangeType change, TickitWindow *window, TickitWhen when)
{
  if(!window->parent) {
    /* Can't do anything to the root window */
    return;
  }
  switch(when) {
    case TICKIT_IMMEDIATE: {
      _do_hierarchy_change(change, window->parent, window);
      break;
    }
    case TICKIT_DEFER: {
      HierarchyChange *req = malloc(sizeof(HierarchyChange));
      req->change = change;
      req->parent = window->parent;
      req->window = window;
      req->next = NULL;
      TickitRootWindow *root = _get_root(window);
      if(!root->hierarchy_changes) {
        root->hierarchy_changes = req;
      } else {
        HierarchyChange *chain = root->hierarchy_changes;
        while(chain->next) {
          chain = chain->next;
        }
        chain->next = req;
      }
      break;
    }
  }
}

static void _purge_hierarchy_changes(TickitWindow *window)
{
  TickitRootWindow *root = _get_root(window);
  if(!root->hierarchy_changes) {
    return;
  }
  /* First, get rid of anything starting from head */
  while((root->hierarchy_changes->parent == window) || (root->hierarchy_changes->window == window)) {
    HierarchyChange *req = root->hierarchy_changes;
    root->hierarchy_changes = req->next;
    free(req);
  }
  /* Now, iterate through the list removing any other nodes */
  HierarchyChange *chain = root->hierarchy_changes;
  /* TODO: Finish */
}

void tickit_window_cursor_at(TickitWindow *window, int line, int col)
{
  window->cursor.line = line;
  window->cursor.col = col;
  if(window->is_focused) {
    _request_restore(_get_root(window));
  }
}

void tickit_window_cursor_visible(TickitWindow *window, bool visible)
{
  window->cursor.visible = visible;
  if(window->is_focused) {
    _request_restore(_get_root(window));
  }
}

void tickit_window_cursor_shape(TickitWindow *window, TickitTermCursorShape shape)
{
  window->cursor.shape = shape;
  if(window->is_focused) {
    _request_restore(_get_root(window));
  }
}

static void _focus_gained(TickitWindow *window, TickitWindow *child);
static void _focus_lost(TickitWindow *window);

void tickit_window_take_focus(TickitWindow *window)
{
  _focus_gained(window, NULL);
}

void tickit_window_focus(TickitWindow *window, int lines, int cols)
{
  tickit_window_cursor_at(window, lines, cols);
  tickit_window_take_focus(window);
}

static void _focus_gained(TickitWindow *window, TickitWindow *child)
{
  if(window->focused_child && child && window->focused_child != child) {
    _focus_lost(window->focused_child);
  }
  if(window->parent) {
    if(window->is_visible) {
      _focus_gained(window->parent, window);
    }
  } else {
    _request_restore(_get_root(window));
  }
  if(!child) {
    window->is_focused = true;
    if(window->on_focus) {
      window->on_focus(window, true, NULL, window->on_focus_data);
    }
  } else if(window->focus_child_notify) {
    if(window->on_focus) {
      window->on_focus(window, true, child, window->on_focus_data);
    }
  }
  window->focused_child = child;
}

static void _focus_lost(TickitWindow *window)
{
  if(window->focused_child) {
   _focus_lost(window->focused_child);
   if(window->on_focus && window->focus_child_notify) {
     window->on_focus(window, false, window->focused_child, window->on_focus_data);
   }
  }
}

bool tickit_window_is_focused(TickitWindow *window)
{
  return window->is_focused;
}

void tickit_window_set_on_focus(TickitWindow *window, TickitWindowFocusFn *fn, void *data)
{
  window->on_focus = fn;
  window->on_focus_data = data;
}
