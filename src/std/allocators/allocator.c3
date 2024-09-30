module std::allocators::allocator;

// A interface for an allocator that can allocate and free memory.
interface Allocator {
    fn any alloc(usz num_bytes);
    fn void free(any segment);
}

