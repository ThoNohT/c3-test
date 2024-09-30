module std::allocators::arena;

import std::allocators::allocator;
import std::allocators::memory_allocator;
import std::list;

struct ArenaCheckpoint {
    usz block_id;
    usz offset_in_block;
}

def ArenaCheckpoints = List(<ArenaCheckpoint>);
def ArenaDataBlock = List(<char>);
def ArenaDataBlocks = List(<ArenaDataBlock>);

struct Arena (Allocator) {
    ArenaDataBlocks blocks;
    ArenaCheckpoints checkpoints;
    usz active_block;
}

// Allocates the specified number of bytes.
fn any Arena.alloc(&self, usz num_bytes) @dynamic {
    return memory_allocator::allocator.alloc(num_bytes);
}

// Frees the memory segment starting with the specified pointer.
// This is not a thing, arena's can only be reset.
fn void Arena.free(&self, any segment) @dynamic { }

/*
// Initialize an empty arena with the specified capacity. A checkpoint is also saved at the empty arena.
Noh_Arena noh_arena_init(size_t capacity);

// Resets the size of an arena to 0, keeping the data reserved. Any checkpoints are removed and one is saved at the
// start of the arena. Requires that the arena is initialized with noh_arena_init.
void noh_arena_reset(Noh_Arena *arena);

// Frees all data in an arena. Any checkpoints are removed. The arena is no longer initialized, and cannot be used
// anymore.
void noh_arena_free(Noh_Arena *arena);

// Ensures that there is room available for the requested size of data. Does not return a pointer to the data to the
// caller. Used if you want to pre-allocate a larger set of data that will later be filled by multiple allocations,
// keeping it in a single block.
void noh_arena_reserve(Noh_Arena *arena, size_t size);

// Allocates data in an arena of the requested size, returns the start of the data.
// Requires at least one checkpoint, either from noh_arena_init, noh_arena_reset or noh_arena_save.
void *noh_arena_alloc(Noh_Arena *arena, size_t size);

// Saves the current position in of the arena in a checkpoint. Requires that the arena is initialized with
// noh_arena_init.
void noh_arena_save(Noh_Arena *arena);

// Rewinds an arena to the last saved checkpoint. Requires at least one checkpoint.
void noh_arena_rewind(Noh_Arena *arena);

// Copies a c-string to the arena.
char *noh_arena_strdup(Noh_Arena *arena, const char *cstr);

// Prints the specified formatted string to the arena.
char *noh_arena_sprintf(Noh_Arena *arena, const char *format, ...);
*/

