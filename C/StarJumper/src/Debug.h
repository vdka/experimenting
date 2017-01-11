
#ifndef Debug_h
#define Debug_h

#include "gb.h"
#include <SDL_ttf.h>

#define FRAME_TIMES 10

struct DebugInfo {
    u64 frameTimes[FRAME_TIMES];
    u64 frameTimeLast;
    f32 fps;
    u64 countedFrames;

    Asset* font;
};

#endif
