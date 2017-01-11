
#ifndef asset_h
#define asset_h

#include "math.h"
#include "common.h"
#include <SDL_gpu.h>
#include <SDL_ttf.h>

struct Asset {

    u64 id;

    u8 spriteH, spriteW;
    u8 sheetW, sheetH;
    GPU_Image* sheet;
};

inline Asset loadAsset(const char* path) {

    GPU_Image* image = GPU_LoadImage(path);
    if (image == NULL) GPU_LogError("Error loading sprite: %s\n", path);

    static u64 id;
    id += 1;
    Asset asset;
    asset.id = id;
    asset.sheet = image;

    return asset;
}

inline void unloadAsset(Asset asset) {

    GPU_FreeImage(asset.sheet);

    asset.sheet = NULL;
}

inline TTF_Font* loadFont(const char* path, i32 size) {

    TTF_Font* font = TTF_OpenFont(path, size);
    if (font == NULL) GPU_LogError("Error loading font: %s\n", path);

    return font;
}

#endif /* asset_h */
