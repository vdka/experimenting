
#ifndef game_h
#define game_h

#include <SDL_gpu.h>
#include <SDL_ttf.h>
#include <SDL_net.h>
#include "common.h"
#include "entity.h"
#include "input.h"
#include "asset.h"
#include "world.h"
#include "array.h"

void loop(void* memory);
void setup(void** memory);

enum GameState {
    GameState_Uninitialized,
    GameState_Initialized,
    GameState_Running,
    GameState_Quiting,
};

#define FRAMES 10

struct Game {

    UDPsocket sock;
    UDPpacket* pack;

    GameState state;

    f32 dt;

    f32 fps;
    f32 lastFrameTime;
    f32 frameTimes[FRAMES];
    u64 countedFrames;

    Input input;

    GPU_Target* target;

    TTF_Font* font;
    Map<u64, Asset> assets;

    World world;
};

#endif /* game_h */
