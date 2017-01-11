
#include "math.h"
#include "gb.h"
#include <math.h>

f32 rsqrt(f32 a) { return 1.0f / sqrtf(a); }

f32 V2_magSq(V2 v) { return V2_dot(v, v); }
f32 V2_mag(V2 v) { return sqrt(V2_dot(v, v)); }

V2 V2_mul(V2 v, f32 s) {
    V2 d;
    d.x = v.x * s;
    d.y = v.y * s;
    return d;
}

V2 V2_div(V2 v, f32 s) {
    V2 r;
    r.x = v.x / s;
    r.y = v.y / s;
    return r;
}

V2 V2_add(V2 v0, V2 v1) {
    V2 r;
    r.x = v0.x + v1.x;
    r.y = v0.y + v1.y;
    return r;
}

V2 V2_sub(V2 v0, V2 v1) {
    V2 r;
    r.x = v0.x - v1.x;
    r.y = v0.y - v1.y;
    return r;
}

V2 V2_norm(V2 v) {
    f32 inverseMagnitude = rsqrt(V2_dot(v, v));
    return V2_mul(v, inverseMagnitude);
}

V2 V2_norm0(V2 v) {
    if (v.x == 0 && v.y == 0)
        return V2_zero;
    else
        return V2_norm(v);
}

V2 V2_lerp(V2 start, V2 end, f32 factor) {
    V2 diff   = V2_sub(end, start);
    V2 scaled = V2_mul(diff, factor);
    return V2_add(start, scaled);
}

V2 V2_clampMagnitude(V2 v, f32 s) {
    if (V2_mag(v) <= s) return v;
    v = V2_norm0(v);
    return V2_mul(v, s);
}

b32 V2_isZero(V2 v) {
    if (v.x == 0 && v.y == 0)
        return true;
    else
        return false;
}
