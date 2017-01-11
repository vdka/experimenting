
#ifndef render_h
#define render_h

#include <SDL.h>
#include <SDL_gpu.h>
#include <SDL_ttf.h>
#include "game.h"

inline SDL_Color mkColor(u32 rgb, u8 a = 0xFF) {
    SDL_Color result;
    result.r = (rgb >> 16) & 0xFF;
    result.g = (rgb >> 8) & 0xFF;
    result.b = rgb & 0xFF;
    result.a = a;
    return result;
}

inline void render(Game* game) {

    u64 lastFrameTime = game->lastFrameTime;

    u64 index = game->countedFrames % FRAMES;

    u64 frameEnd = SDL_GetPerformanceCounter();

    game->countedFrames += 1;
    game->frameTimes[index] = frameEnd - game->lastFrameTime;

    game->lastFrameTime = frameEnd;

    u64 count = game->countedFrames < FRAMES ? game->countedFrames : FRAMES;

    game->fps = 0;
    for (i32 i = 0; i < count; i++)
        game->fps += game->frameTimes[i];

    game->fps /= count;

    game->fps = SDL_GetPerformanceFrequency() / game->fps;

    char fpsBuffer[32];

    sprintf(fpsBuffer, "%.2ffps", game->fps);

    GPU_ClearColor(game->target, mkColor(0x000000));

    SDL_Surface* surface = TTF_RenderText_Solid(game->font, fpsBuffer, mkColor(0xFFFFFF));
    if (surface == NULL) return;

    GPU_Image* image = GPU_CopyImageFromSurface(surface);
    if (image == NULL) return;
    SDL_FreeSurface(surface);

    GPU_Blit(image, NULL, game->target, 40, 10);

    GPU_Blit(game->assets.values.first()->sheet, NULL, game->target, 300, 240);

    GPU_FreeImage(image);

    GPU_Flip(game->target);

    game->dt = (f32)(SDL_GetPerformanceCounter() - lastFrameTime) / SDL_GetPerformanceFrequency();
}


#endif /* render_h */
