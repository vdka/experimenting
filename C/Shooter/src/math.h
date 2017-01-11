
#ifndef math_h
#define math_h

#include <SDL_gpu.h>

#define TAU 6.28318530717958647692528676655900576f

union V2 {
    struct {
        f32 x, y;
    };
    f32 e[2];

    b32 operator==(V2 rhs) { return x == rhs.x && y == rhs.y; }
    b32 operator!=(V2 rhs) { return x != rhs.x || y != rhs.y; }
};

union Rect {
    struct {
        f32 x, y, w, h;
    };
    struct {
        V2 position, size;
    };
    GPU_Rect gpu;
    f32      e[4];
};

inline f32 V2_dot(V2 a, V2 b) { return a.x * b.x + a.y * b.y; }
inline f32 V2_cross(V2 a, V2 b) { return a.x * b.y - a.y * b.x; }


#endif /* math_h */
