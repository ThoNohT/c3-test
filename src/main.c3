import std::browser;
import std::allocators::memory_allocator;

fn void main() @extern("main") @wasm {

    browser::log("Allocating 1.");
    char* b1 = (char*) memory_allocator::allocator.alloc(100);
    browser::log("Allocating 2.");
    char* b2 = (char*) memory_allocator::allocator.alloc(100);
    browser::log("Allocating 3.");
    char* b3 = (char*) memory_allocator::allocator.alloc(100);
    browser::log("Done allocating.");

    browser::log("Pointer to first.");
    browser::log_num((int)b1);
    browser::log("Pointer to second.");
    browser::log_num((int)b2);
    browser::log("Pointer to third.");
    browser::log_num((int)b3);
    browser::log("Done showing.");

    browser::log("Freeing 2.");
    memory_allocator::allocator.free(b2);
    browser::log("Reallocating 1.");
    b1 = (char*)memory_allocator::allocator.realloc((any)b1, 200);

    browser::log("Pointer to first.");
    browser::log_num((int)b1);
    browser::log("Pointer to third.");
    browser::log_num((int)b3);
    browser::log("Done showing.");

    return;
}
