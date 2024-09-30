import std::browser;
import std::allocators::memory_allocator;

fn void main() @extern("main") @wasm {

    browser::log("Allocating 1.");
    char* b1 = memory_allocator::allocator.alloc(100);
    browser::log("Allocating 2.");
    char* b2 = memory_allocator::allocator.alloc(100);
    browser::log("Allocating 3.");
    char* b3 = memory_allocator::allocator.alloc(100);
    browser::log("Done allocating.");

    browser::log("Pointer to first.");
    browser::log_num((int)b1);
    browser::log("Pointer to second.");
    browser::log_num((int)b2);
    browser::log("Pointer to third.");
    browser::log_num((int)b3);
    browser::log("Done showing.");

    memory_allocator::allocator.free(b2);
    memory_allocator::allocator.free(b3);
    memory_allocator::allocator.free(b1);
    memory_allocator::allocator.free(b1);
    memory_allocator::allocator.free(b2);

    //char[] bytes = wasm_memory::allocate(WASM_BLOCK_SIZE * 3);

    //for (usz i = 0; i < WASM_BLOCK_SIZE * 3; i++) {
    //    if (bytes[i] != 0) {
    //        browser::log("Not null:");
    //        browser::log_num(i);
    //        browser::log_num(bytes[i]);
    //    }
    //}

    //browser::log("Size after:");
    //browser::log_num($$wasm_memory_size(0));
    //
    //bytes[0] = 0xFF;
    //bytes[1] = 0xA;
    //usz offset = 66688;
    //usz factor = 1;
    //browser::log_num(bytes[offset * factor + 10]);

    return;
}
