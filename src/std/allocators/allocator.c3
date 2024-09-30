module std::allocators::allocator;

// A interface for an allocator that can allocate and free memory.
interface Allocator {
    fn char* alloc(usz num_bytes);
    fn void free(char *segment);
}