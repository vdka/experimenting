//
// #ifndef MemoryArena_H
// #define MemoryArena_H
//
// #include "gb.h"
// #include <SDL.h>
//
// #define DEFAULT_BLOCK_SIZE 1024 * 1024
//
// typedef struct Arena {
//
//     void* base;
//     u64   blockSize;
//
//     u64 allocated;
//     u64 count;
// } Arena;
//
// enum ArenaFlag {
//     ARENA_CLEAR_WITH_ZEROS = 0x1,
// };
//
// inline void Arena_init(Arena* arena, u64 blockSize) {
//
//     arena->blockSize = blockSize ?: DEFAULT_BLOCK_SIZE;
//     arena->allocated = arena->blockSize;
//
//     arena->count = 0;
//     arena->base  = SDL_malloc(arena->allocated);
// }
//
// typedef struct ArenaPushParams {
//     u32 flags;
//     u32 alignment;
// } ArenaPushParams;
//
// inline ArenaPushParams defaultArenaPushParams(void) {
//     ArenaPushParams params;
//     params.flags     = ARENA_CLEAR_WITH_ZEROS;
//     params.alignment = 4;
//     return params;
// }
//
// #define Arena_PushStruct(arena, type, ...)                                                         \
//     (type*) PushSize_(arena, sizeof(type), ##__VA_ARGS__) // 305 131
//
// // inline void Arena_pushSize(Arena* arena, u64 size,
// //                            ArenaPushParams params = defaultArenaPushParams()) {}
//
// #endif
