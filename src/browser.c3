module browser;

import ffi;

fn Str create_string(char* str) @private {
    usz sz = 0;
    char* end = str;
    while (*end != '\0') {
        sz++;
        end++;
    }

    return Str { .data = str, .length = sz };
}

fn void alert(char *str) {
    ffi::alert(&&create_string(str));
}

fn void log(char* str) {
    ffi::log(&&create_string(str));
}