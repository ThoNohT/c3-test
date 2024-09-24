module std::core::errors;

import std::browser;

// The only exception type to use.
fault Exception { EXCEPTION, NONE }

// Logs the message and throws an exception.
fn int! throw(String message) {
    browser::log("An exception occurred!");
    browser::log(message);
    return Exception.EXCEPTION?;
}
