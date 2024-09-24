module std::wasm_memory @private;

import std::core::errors;

// The memory block size WASM uses (64KB). We can determine the number of available bytes by multiplying
// $$wasm_memory_size(0) with this constant. Growing memory also happens one block size at a time.
const usz WASM_BLOCK_SIZE = 65536;

// A reserved segment of memory in the available memory.
struct MemorySegment {
    bool used;
    char* start;
    uptr size;
    // This pointer is used to determine how much space there is between this segment and the next one,
    // if there is one. If used is true, there has to be a next segment (even if it is 0 size).
    MemorySegment* next;
}

// Sets every byte of this segment to the specified value.
fn void MemorySegment.set(&self, char value) {
    self.start[:self.size] = value;
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
        mem.used = false;
    }

    // The first one always references the start of the memory block.
    self.used_memory[0].start = null;
    self.used_memory[0].size = self.allocated;
}

// Grows the available memory by the specified number of blocks.
fn void WasmMemory.grow(&self, usz blocks) {
    if ($$wasm_memory_grow(0, blocks) == -1) errors::throw("Out of memory")!!;
    self.allocated = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
}

// Allocates the required data.
//fn char[]! WasmMemory.allocate_block(&self, usz bytes) {
//    if (!self.allocated) self.allocated = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
//
//    isz extra_bytes_required = bytes - self.available_bytes();
//    if (extra_bytes_required <= 0)
//    {
//        defer self.used += bytes;
//        return ((char*)self.used)[:bytes];
//    }
//
//    usz blocks_required = (extra_bytes_required + WASM_BLOCK_SIZE + 1) / WASM_BLOCK_SIZE;
//    if ($$wasm_memory_grow(0, blocks_required) == -1) errors::throw("Out of memory")!!;
//    self.allocated = $$wasm_memory_size(0) * WASM_BLOCK_SIZE;
//
//    defer self.used += bytes;
//    return ((char*)self.used)[:bytes];
//}

fn MemorySegment* WasmMemory.find_unused_segment(&self) {
    foreach (&segment : self.used_memory) {
        if (!segment.used && segment.next == null) {
            return segment;
        }
    }

    errors::throw("No more unused segments.")!!;
    return null;
}

fn MemorySegment WasmMemory.find_free_segment(&self, usz num_bytes) {
    MemorySegment* cur = &self.used_memory[0];

    // Find the first segment that is not used, and that fits.
    while ((cur.used || cur.size < num_bytes) && cur.next != null) {
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
    usz remaining = cur.size - num_bytes;
    if (cur.next != null) {
        // Merge or add remaining empty space after the current block. If there is no remaining space,
        // leave the next segment as is.
        if (remaining > 0) {
            if (!cur.next.used) {
                // Merge the remaining space with the next block.
                MemorySegment *next = cur.next;
                next.size += remaining;
                next.start -= remaining;
            } else {
                // Create a new block inbetween the current and previous next one.
                MemorySegment* next = self.find_unused_segment();
                next.start = cur.start + num_bytes;
                next.size = remaining;
                next.next = cur.next;
                cur.next = next;
            }
        }
    } else {
        // Create a new unused block at the end.
        MemorySegment* next = self.find_unused_segment();
        next.start = cur.start + num_bytes;
        next.size = remaining;
        next.next = null;
        cur.next = next;
    }
    
    cur.used = true;
    cur.size = num_bytes;
    return *cur;
}

fn MemorySegment*! WasmMemory.find_prev_segment(&self, MemorySegment* segment) {
    foreach (&prev : self.used_memory) {
        if (prev.next == segment) {
            return prev;
        }
    }

    return Exception.NONE?;
}

fn void WasmMemory.free_segment(&self, char *start) {
    foreach (&segment : self.used_memory) {
        if (segment.start == start) {
            // Free this segment.

            MemorySegment*! prev = self.find_prev_segment(segment);
            if (catch exuse = prev) {
                // No previous segment.
                if (!segment.next.used) {
                    MemorySegment* next = segment.next;
                    // Merge next segment with this one, making that one unused.
                    segment.size = segment.size + next.size;
                    segment.next = next.next;

                    next.used = false;
                    next.size = 0;
                    next.start = null;
                    next.next = null;
                }
            } else {
                if (!prev.used) {
                    if (!segment.next.used) {
                        MemorySegment* next = segment.next;
                        // Merge previous and next segments, making this one and next unused.
                        prev.size = prev.size + segment.size + next.size;
                        prev.next = next.next;

                        segment.used = false;
                        segment.size = 0;
                        segment.start = null;
                        segment.next = null;

                        next.used = false;
                        next.size = 0;
                        next.start = null;
                        next.next = null;
                    } else {
                        // Merge the previous segment making this one unused.
                        prev.size = prev.size + segment.size;
                        prev.next = segment.next;

                        segment.used = false;
                        segment.size = 0;
                        segment.start = null;
                        segment.next = null;
                    }
                }
            }

            return;
        }
    }
}

// Public interface.

// Allocates the specified number of bytes.
fn char[] alloc(usz num_bytes) @public {
    MemorySegment segment = wasm_memory.find_free_segment(num_bytes);
    return ((char*)segment.start)[:segment.size];
}

// Frees the memory segment starting with the specified pointer.
fn void free(char* ptr) @public {
    wasm_memory.free_segment(ptr);
}

