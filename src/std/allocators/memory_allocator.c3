module std::allocators::memory_allocator;

import std::allocators::allocator;
import std::core::wasm_memory;

// An allocator that works directly on the WASM memory.
MemoryAllocator allocator = {};

struct MemoryAllocator (Allocator) { bool initialized; }

// Allocates the specified number of bytes.
fn char* MemoryAllocator.alloc(&self, usz num_bytes) @dynamic {
    if (!self.initialized) self.initialized = true;
    return wasm_memory::alloc(num_bytes);
}

// Frees the memory segment starting with the specified pointer.
fn void MemoryAllocator.free(&self, char *segment) @dynamic {
    if (!self.initialized) self.initialized = true;
    wasm_memory::free(segment);
}