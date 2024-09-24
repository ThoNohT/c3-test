module std::core::ffi;

struct Str { char* data; usz length; }

extern fn void log(Str*);
extern fn void log_num(usz);
extern fn void alert(Str*);
