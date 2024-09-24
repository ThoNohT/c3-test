import std::browser;
import std::wasm_memory;

const usz WASM_BLOCK_SIZE @private = 65536;

fn void main() @extern("main") @wasm {
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
