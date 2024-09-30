module std::list(<Type>);

import std::allocators::memory_allocator;

// Default initial capacity of a list.
const usz LIST_INIT_CAP = 256;

struct List {
    Type[]* elems;
    usz count;
    usz capacity;
    MemoryAllocator* allocator;
}

/**
 * Appends an elemend to the list, expanding the list if needed.
 */
fn void List.append(&self, Type elem) {
    if (self.count >= self.capacity) {
        self.capacity = self.capacity == 0 ? LIST_INIT_CAP : self.capacity * 2;
        self.elems = (Type[]*)self.allocator.realloc(&self.elems, self.capacity * Type.sizeof);
    }

    (*self.elems)[self.count++] = elem;
}
