module std::browser;

import std::core::ffi;

// Creates a string that can be parsed on the Javascript side, containing the start pointer and the length.
fn Str create_string(char* str) @private {
    usz sz = 0;
    char* end = str;
    while (*end != '\0') {
        sz++;
        end++;
    }

    return Str { .data = str, .length = sz };
}

// Opens a popup with the specified message.
fn void alert(char *str) => ffi::alert(&&create_string(str));


// Logs the specified string.
fn void log(char* str) => ffi::log(&&create_string(str));


// Logs the specified number.
fn void log_num(usz num) => ffi::log_num(num);

