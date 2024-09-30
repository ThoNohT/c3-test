module std::core::wasm_memory @private;

import std::core::errors;

// The memory block size WASM uses (64KB). We can determine the number of available bytes by multiplying
// $$wasm_memory_size(0) with this constant. Growing memory also happens one block size at a time.
const usz WASM_BLOCK_SIZE = 65536;

// A reserved segment of memory in the available memory.
struct MemorySegment {
    bool used; // Whether it is being used to store an allocated or free segment.
    bool free; // If used is true, whether the value is free or allocated.
    char* start;
    uptr size;

    // Every used segment that is allocated always has a following used free segment.
    // This ensures that we can always end at a free segment that is too small and extend it by growing.
    MemorySegment* next;
    // Only the first segment does not have a previous segment. This will always be the first segment in the 
    // array of segments.
    MemorySegment* prev;
}

// Sets every byte of this segment to the specified value.
fn void MemorySegment.set(&self, char value) {
    self.start[:self.size] = value;
}

// Assigns a block of memory to a memory segment, and places it in the linked list.
fn void MemorySegment.assign(&self, bool free, char* start, uptr size, MemorySegment* next, MemorySegment* prev) {
    self.used = true;
    self.free = free;
    self.start = start;
    self.size = size;
    self.next = next;
    self.prev = prev;
}

// Marks a segment as not used, and resets it values.
fn void MemorySegment.deinit(&self) {
    self.used = false;
    self.free = true;
    self.start = null;
    self.size = 0;
    self.next = null;
    self.prev = null;
}

// Struct keeping track how much memory is allocated and being used.
struct WasmMemory {
    // The number of bytes allocated.
    usz allocated;

    // For now, 1024 segments reserved should be good enough, since using Arena's should keep the number of allocations
    // low. When it becomes a problem, look into fixing this.
    MemorySegment[1024] used_memory;
}

// Pre-reserved data for all memory management memory, so we don't have to allocate our own data.
WasmMemory wasm_memory;

// Initializes all memory segments as unused, and gets the number of avalable bytes.
fn void WasmMemory.init(&self) {
    self.allocated = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
    foreach (&mem : self.used_memory) {
        mem.deinit();
    }

    // The first one always references the start of the memory block.
    self.used_memory[0].assign(true, null, self.allocated, null, null);
}

// Grows the available memory by the specified number of blocks.
fn void WasmMemory.grow(&self, usz blocks) {
    if ($$wasm_memory_grow(0, blocks) == -1) errors::throw("Out of memory")!!;
    self.allocated = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
}

fn MemorySegment* WasmMemory.find_unused_segment(&self) {
    foreach (&segment : self.used_memory) {
        if (!segment.used) {
            segment.used = true;
            segment.free = true;
            return segment;
        }
    }

    errors::throw("No more unused segments.")!!;
    return null;
}

fn MemorySegment WasmMemory.find_free_segment(&self, usz num_bytes) {
    MemorySegment* cur = &self.used_memory[0];

    int lim = 0;
    // Find the first segment that is not allocated, and that fits.
    while ((cur.size < num_bytes || !cur.free) && cur.next != null) {
        cur = cur.next;
    }

    // We are now either at the first fitting segment, or at the end of the segments.
    if (cur.size < num_bytes) {
        // If the segment is not big enough, we must be at the end, and can extend it.
        usz old_size = self.allocated;
        usz blocks_required = (num_bytes - cur.size + WASM_BLOCK_SIZE + 1) / WASM_BLOCK_SIZE;
        self.grow(blocks_required);
        usz grown = self.allocated - old_size;
        cur.size += grown;
    }

    // Now we have a large enough segment. Use it, and let the next one be the remaining space.
    cur.free = false;
    cur.size = num_bytes;

    usz remaining = cur.size - num_bytes;
    MemorySegment* next = cur.next;
    if (next != null) {
        errors::throw("MERGEADD")!!;
        // Merge or add remaining empty space after the current block. If there is no remaining space,
        // leave the next segment as is.
        if (next.free) {
            // Merge the remaining space with the next block.
            next.size += remaining;
            next.start -= remaining;
        } else {
            // Create a new freed block inbetween the current and previous next one.
            MemorySegment* between = self.find_unused_segment();
            between.start = cur.start + num_bytes;
            between.size = remaining;
            between.prev = cur;
            between.next = next;

            cur.next = between;
        }
    } else {
        // Create a new freed block at the end.
        next = self.find_unused_segment();
        next.start = cur.start + num_bytes;
        next.size = remaining;
        next.prev = cur;
        next.next = null;

        cur.next = next;
    }
    
    return *cur;
}

fn void WasmMemory.free_segment(&self, char *start) {
    MemorySegment* cur = null;
    foreach (&segment : self.used_memory) {
        if (segment.start == start) {
            // Free this segment.

            if (segment.free) {
                // This segment was already freed.
                return;
            }

            // Otherwise, go on with freeing it.
            cur = segment;
            break;
        }
    }

    // If the segment was not found, don't do anything.
    if (cur == null) return;

    // Every used and allocated segment has a next one. So we can always check for a merge with the next one
    // if it is also freed.
    MemorySegment* prev = cur.prev;
    MemorySegment* next = cur.next;
    if (prev == null || !prev.free) {
        // No previous segment, or there is one but it is allocated.
        if (next.free) {
            // Merge next segment with this one, making that one unused.
            cur.size = cur.size + next.size;
            cur.next = next.next;

            next.deinit();
        } else {
            cur.free = true;
        }
    } else {
        // There is a previous segment that is free.
        if (next.free) {
            // Merge previous and next segments, making this one and next unused.
            prev.next = next.next;
            prev.size = prev.size + cur.size + next.size;

            cur.deinit();
            next.deinit();
        } else {
            // Merge the previous segment making this one unused.
            prev.next = cur.next;
            prev.size = prev.size + cur.size;

            cur.deinit();
        }
    }
}

// Public interface.

// Allocates the specified number of bytes.
fn char[] alloc(usz num_bytes) @public {
    if (wasm_memory.allocated == 0) wasm_memory.init();
    MemorySegment segment = wasm_memory.find_free_segment(num_bytes);
    return ((char*)segment.start)[:segment.size];
}

// Frees the memory segment starting with the specified pointer.
fn void free(char* ptr) @public {
    if (wasm_memory.allocated == 0) wasm_memory.init();
    wasm_memory.free_segment(ptr);
}

