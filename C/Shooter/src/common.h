
#ifndef common_h
#define common_h

#include <SDL.h>

typedef Uint8   u8;
typedef Sint8   i8;
typedef Uint16 u16;
typedef Sint16 i16;
typedef Uint32 u32;
typedef Sint32 i32;
typedef Uint64 u64;
typedef Sint64 i64;

#include <assert.h>

#define sassert3(cond, msg) SDL_COMPILE_TIME_ASSERT(msg, cond)
// NOTE(bill): Token pasting madness!!
#define sassert2(cond, line) sassert3(cond, static_assertion_at_line_##line)
#define sassert1(cond, line) sassert2(cond, line)
#define sassert(cond)        sassert1(cond, __LINE__)

sassert(sizeof(u8)  == sizeof(i8));
sassert(sizeof(u16) == sizeof(i16));
sassert(sizeof(u32) == sizeof(i32));
sassert(sizeof(u64) == sizeof(i64));

sassert(sizeof(u8)  == 1);
sassert(sizeof(u16) == 2);
sassert(sizeof(u32) == 4);
sassert(sizeof(u64) == 8);

typedef float  f32;
typedef double f64;

typedef size_t    usize;
typedef ptrdiff_t isize;

typedef i8   b8;
typedef i16 b16;
typedef i32 b32;

#if !defined(__cplusplus)
    #if defined(_MSC_VER) && _MSC_VER <= 1800
    #define inline __inline
    #elif !defined(__STDC_VERSION__)
    #define inline __inline__
    #else
    #define inline
    #endif
#endif

#if !defined(__cplusplus)
    #if (defined(_MSC_VER) && _MSC_VER <= 1800) || !defined(__STDC_VERSION__)
        #ifndef true
            #define true  (0 == 0)
        #endif
        #ifndef false
            #define false (0 != 0)
        #endif
    #else
        #include <stdbool.h>
    #endif
#endif


#endif /* common_h */
