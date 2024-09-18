module ffi;

struct Str { char* data; usz length; }

extern fn void log(Str*);
extern fn void alert(Str*);
