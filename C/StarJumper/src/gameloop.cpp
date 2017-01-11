
#define GB_IMPLEMENTATION
#include "World.h"
#include "Renderer.h"
#include "Entity.h"
#include "gameMemory.h"
#include "gb.h"
#include "inputManager.h"
#include "math.h"
#include "player.h"
#include <SDL.h>
#include <SDL_gpu.h>
#include <SDL_ttf.h>

extern "C" {
void* init(void* memory) {

    memory = SDL_malloc(sizeof(GameMemory));

    GameMemory* game = (GameMemory*) memory;

    if (TTF_Init() < 0) return NULL;
    GPU_SetDebugLevel(GPU_DEBUG_LEVEL_MAX);
    game->renderer = GPU_Init(640, 480, GPU_DEFAULT_INIT_FLAGS);
    if (game->renderer == NULL) return NULL;

    SDL_Window* window = SDL_GL_GetCurrentWindow();
    SDL_SetWindowPosition(window, 0, 0);

    game->dt         = 0;
    game->shouldQuit = false;

    PlayerInput* input = (PlayerInput*) SDL_calloc(1, sizeof(PlayerInput));
    game->playerInputs = Array_make(input, 1);

    game->debugInfo      = {0};
    game->debugInfo.font = loadFont("data/SourceCodePro-Regular.ttf", 12);

    game->world = World_make();

    Entity camera = Entity_make();
    camera.kind   = EntityKind_Camera;
    camera.size   = {32, 24}; // TODO(vdka): Set to window frame

    {
        Entity wall     = Entity_make();
        wall.kind       = EntityKind_Wall;
        wall.wall.color = 0x0000FF; // blue
        wall.position   = {10, 10};
        wall.size       = {2, 2};
        Array_append(&game->world.entities, wall);
    }
    {
        Entity wall     = Entity_make();
        wall.kind       = EntityKind_Wall;
        wall.wall.color = 0xFF0000; // red
        wall.position   = {-10, -10};
        wall.size       = {2, 2};
        Array_append(&game->world.entities, wall);
    }
    {
        Entity wall     = Entity_make();
        wall.kind       = EntityKind_Wall;
        wall.wall.color = 0xBBBB00; // blue
        wall.position   = {-16, 12};
        wall.size       = {2, 2};
        Array_append(&game->world.entities, wall);
    }

    {
        for (i32 i = 0; i < 1000; i++) {
            Entity wall     = Entity_make();
            wall.kind       = EntityKind_Wall;
            wall.wall.color = 0xFF0000;
        }
    }

    game->world.camera = camera;

    Asset* playerSprite = Asset_loadTexture("data/player-sheet.png");

    GPU_SetImageFilter(playerSprite->texture, GPU_FILTER_NEAREST);

    game->assets[EntityKind_Player] = playerSprite;

    if (!playerSprite) return NULL;

    return memory;
}

void load(void* memory) {
    GameMemory* game = (GameMemory*) memory;

    for (i32 i = 0; i < EntityKind_Last; i++) {
        Entity::assets[i] = game->assets[i];
    }

    Entity::traits[EntityKind_Wall].collides   = true;
    Entity::traits[EntityKind_Player].collides = true;
}

b32 loop(void* memory) {

    GameMemory* game = (GameMemory*) memory;

    readInput(&game->playerInputs[0], &game->shouldQuit);

    if (game->playerInputs[0].wasEvent && game->playerInputs[0].target == NULL) {

        V2 spawnPosition = {0, 0};

        Entity* entity = Player_spawn(spawnPosition, &game->world);

        game->world.camera.position = spawnPosition;

        game->playerInputs[0].target = entity;

        entity->player.input = &game->playerInputs[0];
    }

    if (game->playerInputs[0].target != NULL)
        Player_handleInput(game->playerInputs[0].target, game->world.camera, game->playerInputs[0],
                           game->dt);

    World_update(&game->world, game->dt);

    Camera_update(&game->world.camera, *game->playerInputs[0].target, game->dt);

    render(game->renderer, &game->world);
    renderPresent(game->renderer, &game->debugInfo, &game->dt);

    //    GPU_Clear(game->renderer);
    //    GPU_Rect r = GPU_MakeRect(0, 0, 6, 6);
    //    GPU_Blit(Entity::assets[EntityKind_Player]->texture, &r, game->renderer, 50, 50);
    //    GPU_Flip(game->renderer);

    if (game->shouldQuit) {
        GPU_Quit();
        TTF_Quit();
    }

    return game->shouldQuit;
}
}
