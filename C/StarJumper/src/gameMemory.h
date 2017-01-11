
#ifndef gameMemory_H
#define gameMemory_H

#include "Array.h"
#include "Assets.h"
#include "Debug.h"
#include "Entity.h"
#include "World.h"
#include "gb.h"
#include "inputManager.h"
#include <SDL.h>
#include <SDL_ttf.h>
#include <SDL_gpu.h>

struct GameMemory {

    f32       dt;
    b32       shouldQuit;
    DebugInfo debugInfo;

    World              world;
    Asset*             assets[EntityKind_Last];
    Array<PlayerInput> playerInputs;

    GPU_Target* renderer;
};

#endif
