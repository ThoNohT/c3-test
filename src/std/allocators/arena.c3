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
fn char* Arena.alloc(&self, usz num_bytes) @dynamic {
    return memory_allocator::allocator.alloc(num_bytes);
}

// Frees the memory segment starting with the specified pointer.
// This is not a thing, arena's can only be reset.
fn void Arena.free(&self, char *segment) @dynamic { }