
#include <SDL_gpu.h>
#include <SDL_ttf.h>
#include <SDL_net.h>
#include "game.h"
#include "render.h"
#include "networking.h"

void setup(void** memory) {

    Game* game = (Game*) SDL_calloc(1, sizeof(Game));

    b32 err = false;
    
    GPU_SetDebugLevel(GPU_DEBUG_LEVEL_MAX);

    game->state = GameState_Initialized;
    game->dt = 0;
    game->target = GPU_Init(640, 480, GPU_DEFAULT_INIT_FLAGS);
    if (game->target == NULL)
        err |= true;

    if (TTF_Init() < 0)
        err |= true;

    if (SDLNet_Init() < 0)
        err |= true;

    game->font = loadFont("data/SourceCodePro-Regular.ttf", 12);

    game->sock = SDLNet_UDP_Open(7070);
    game->pack = SDLNet_AllocPacket(1500);

    if (game->sock == NULL)
        err |= true;

    IPaddress addr;
    addr.host = 0x8F000001;
    addr.port = 7070;
    if (SDLNet_ResolveIP(&addr) == NULL)
        exit(28);

    SDL_Window* window = SDL_GL_GetCurrentWindow();
    SDL_SetWindowPosition(window, 0, 0);

    Asset player = loadAsset("data/player-sheet.png");
    player.spriteW = 4;
    player.spriteH = 6;
    player.sheetH = 1;
    player.sheetW = 6;

    game->assets.insert(EntityKind_Player, player);

    game->world = World::make();

    LiveEntity* entity = game->world.spawnEntity();

    game->world.entityData[entity->id]->kind = EntityKind_Player;
    game->world.entityData[entity->id]->size = {1, 1};

    if (!err)
        game->state = GameState_Initialized;
    else
        game->state = GameState_Uninitialized;

    *memory = game;
}

void loop(void* memory) {
    Game* game = (Game*) memory;

    b32 didSend = false;
    didSend = SDLNet_UDP_Send(game->sock, -1, game->pack);

    b32 shouldQuit = false;
    readInput(&game->input, &shouldQuit);

    render(game);

    if (!shouldQuit)
        game->state = GameState_Running;
    else
        game->state = GameState_Quiting;
}
