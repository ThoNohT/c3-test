module std::list(<Type>);

import std::browser;
import std::allocators::memory_allocator;

// Default initial capacity of a list.
const usz LIST_INIT_CAP = 256;

struct List {
    Type* elems;
    usz count;
    usz capacity;
    MemoryAllocator* allocator;
}

/**
 * Appends an element to the list, expanding the list if needed.
 */
fn void List.append(&self, Type elem) {
    if (self.allocator == null) self.allocator = &memory_allocator::allocator;
    browser::log_num((usz)self.allocator);

    if (self.count >= self.capacity) {
        self.capacity = self.capacity == 0 ? LIST_INIT_CAP : self.capacity * 2;
        any res = self.allocator.realloc(&self.elems, self.capacity * Type.sizeof);
        browser::log("List.append::res");
        browser::log_num((usz)((any*)res));
        self.elems = (Type*)res;
    }

    self.elems[self.count++] = elem;
}

/**
 * Gets the element at the specified index.
 */
fn Type List.get(&self, usz index) @operator([]) {
    if (index >= self.count) errors::throw("Index out of range.")!!;
    return self.elems[index];
}

/**
 * Gets a pointer to the element at the specified index.
 */
fn Type* List.get_ref(&self, usz index) @operator(&[]) {
    return &self.elems[index];
}