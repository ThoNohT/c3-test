module std::allocators::memory_allocator;

import std::allocators::allocator;
import std::core::wasm_memory;

// An allocator that works directly on the WASM memory.
MemoryAllocator allocator = {};

// Zero length structs are not allowed, but this is only a wrapper for accessing wasm_memory.
// Multiple instances of this struct can exist, but only one instance of WasmMemory can be used.
struct MemoryAllocator (Allocator) { bool initialized; }

// Allocates the specified number of bytes.
fn any MemoryAllocator.alloc(&self, usz num_bytes) @dynamic {
    if (!self.initialized) self.initialized = true;
    return wasm_memory::alloc(num_bytes);
}

// Frees the memory segment starting with the specified pointer.
fn void MemoryAllocator.free(&self, any segment) @dynamic {
    if (!self.initialized) self.initialized = true;
    wasm_memory::free(segment);
}

// Re-allocates the specified segment, extending it or moving it to a new segment if it cannot be extended far enough.
fn any MemoryAllocator.realloc(&self, any segment, usz num_bytes) {
    if (!self.initialized) self.initialized = true;
    return wasm_memory::realloc(segment, num_bytes);
}
