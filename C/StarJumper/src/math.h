
#ifndef math_H
#define math_H

#include "gb.h"
#include <math.h>
#include <SDL.h>
#include <SDL_gpu.h>

#define TAU 6.28318530717958647692528676655900576f

typedef union V2 {
    struct {
        f32 x, y;
    };
    f32 e[2];

    b32 operator==(V2 rhs) { return x == rhs.x && y == rhs.y; }
} V2;

inline V2 makeV2(f32 x, f32 y) {
    V2 result = {x, y};
    return result;
}

f32 rsqrt(f32 a);
inline f32 V2_dot(V2 a, V2 b) { return a.x * b.x + a.y * b.y; }
inline f32 V2_cross(V2 a, V2 b) { return a.x * b.y - a.y * b.x; }
f32 V2_mag(V2 v);
V2 V2_mul(V2 v, f32 s);
V2 V2_add(V2 v0, V2 v1);
V2 V2_sub(V2 v0, V2 v1);
V2 V2_norm(V2 v);
V2 V2_norm0(V2 v);
b32 V2_isZero(V2 v);
V2 V2_lerp(V2 start, V2 end, f32 factor);
V2 V2_clampMagnitude(V2 v, f32 s);

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))
#define clamp(x, lower, upper) (min(max(x, (lower)), (upper)))
#define V2_undefined {FP_NAN, FP_NAN};
//#define V2_zero {0, 0};

static V2 V2_zero = {0, 0};

inline b32 V2_isUndefined(V2 v) { return v.x == FP_NAN && v.y == FP_NAN; }

inline V2 V2_fromAngle(V2 origin, f32 angle, f32 magnitude = 1) {

    V2 result;
    result.x = SDL_cosf(angle);
    result.y = SDL_sinf(angle);
    return V2_add(origin, V2_mul(result, magnitude));
}

typedef union V3 {
    struct {
        f32 x, y, z;
    };
    struct {
        f32 r, g, b;
    };

    V2  xy;
    f32 e[3];
} V3;

typedef union Rect {
    struct {
        f32 x, y, w, h;
    };
    struct {
        V2 position, size;
    };
    GPU_Rect gpu;
    f32      e[4];
} Rect;

struct Polygon {

    i32 sides;
    V2* vertices;
};

inline V2 Rect_center(Rect rect) {
    V2 center;

    center.x = rect.x + rect.w / 2;
    center.y = rect.y + rect.h / 2;
    return center;
}

inline V2 SDLRect_center(SDL_Rect rect) {
    V2 center;

    center.x = rect.x + rect.w / 2;
    center.y = rect.y + rect.h / 2;
    return center;
}

inline b32 Rect_contains(Rect r, V2 p) {

    f32 halfWidth  = r.w / 2;
    f32 halfHeight = r.h / 2;
    f32 left       = r.x - halfWidth;
    f32 right      = r.x + halfWidth;
    f32 top        = r.x - halfHeight;
    f32 bottom     = r.y + halfHeight;
    return p.x > left && p.x < right && p.y > bottom && p.y < top;
}

inline V2* Rect_vertices(Rect r) {

    f32 halfWidth  = r.w / 2;
    f32 halfHeight = r.h / 2;
    f32 left       = r.x - halfWidth;
    f32 right      = r.x + halfWidth;
    f32 top        = r.y - halfHeight;
    f32 bottom     = r.y + halfHeight;

    V2* vertices = (V2*) SDL_malloc(sizeof(V2) * 4);

    vertices[0] = {right, bottom};
    vertices[1] = {right, top};
    vertices[2] = {left, top};
    vertices[3] = {left, bottom};

    return vertices;
}

typedef union V4 {
    struct {
        f32 x, y, z, w;
    };
    struct {
        f32 r, g, b, a;
    };
    struct {
        V2 xy, zw;
    };
    Rect rect;
    V3   xyz;
    V3   rgb;
    f32  e[4];
} V4;

inline b32 Rect_contanis(V2 point, Rect r) {

    f32 halfWidth  = r.w / 2;
    f32 halfHeight = r.h / 2;
    f32 left       = r.x - halfWidth;
    f32 right      = r.x + halfWidth;
    f32 top        = r.x - halfHeight;
    f32 bottom     = r.y + halfHeight;

    if (point.x > left && point.x < right && point.y > bottom && point.y < top) return true;
    else return false;
}

inline V2 Rect_closestPointOnBounds(V2 point, Rect r) {

    V2 min = {r.x - r.w / 2, r.y - r.h / 2};
    V2 max = {r.x + r.w / 2, r.y + r.h / 2};
    f32 minDist = SDL_fabs(point.x - min.x);
    V2  boundsPoint = {min.x, point.y};
    if (SDL_fabs(max.x - point.x) < minDist) {
        minDist = SDL_abs(max.x - point.x);
        boundsPoint = {max.x, point.y};
    }
    if (SDL_fabs(max.y - point.y) < minDist) {
        minDist = SDL_fabs(max.y - point.y);
        boundsPoint = {point.x, max.y};
    }
    if (SDL_fabs(min.y - point.y) < minDist) {
        minDist = SDL_fabs(min.y - point.y);
        boundsPoint = {point.x, min.y};
    }
    return boundsPoint;
}

inline V2 Rect_raycast(V2 rayStart, V2 rayEnd, V2 padding, Rect r) {

    V2  rayDelta  = V2_sub(rayEnd, rayStart);
    f32 scaleX    = 1.f / rayDelta.x;
    f32 scaleY    = 1.f / rayDelta.y;
    f32 signX     = copysignf(1, scaleX);
    f32 signY     = copysignf(1, scaleY);
    f32 nearTimeX = (r.x - signX * (r.w / 2 + padding.x) - rayStart.x) * scaleX;
    f32 nearTimeY = (r.y - signY * (r.h / 2 + padding.y) - rayStart.y) * scaleY;
    f32 farTimeX  = (r.x + signX * (r.w / 2 + padding.x) - rayStart.x) * scaleX;
    f32 farTimeY  = (r.y + signY * (r.h / 2 + padding.y) - rayStart.y) * scaleY;

    if (nearTimeX > farTimeY || nearTimeY > farTimeX) return rayEnd;

    f32 nearTime = nearTimeX > nearTimeY ? nearTimeX : nearTimeY;
    f32 farTime  = farTimeX < farTimeY ? farTimeX : farTimeY;

    if (nearTime >= 1 || farTime <= 0) return rayEnd;

    // at this point we have a collision.

    return V2_lerp(rayStart, rayEnd, nearTime);
}

inline V2 V2_raycast(V2 p1, V2 p2, V2 p3, V2 p4) {
    f32 s = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) /
            ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y));
    V2 p = {p1.x + s * (p2.x - p1.x), p1.y + s * (p2.y - p1.y)};
    return p;
}

#endif
