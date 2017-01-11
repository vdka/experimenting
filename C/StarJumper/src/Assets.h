
#ifndef Assets_h
#define Assets_h

#include <SDL.h>
#include <SDL_ttf.h>
#include <SDL_gpu.h>

enum AssetKind {
    AssetKind_Invalid,
    AssetKind_Texture,
    AssetKind_Font,
};

struct Asset {

    AssetKind kind;

    union {
        GPU_Image* texture;
        TTF_Font*  font;
    };
};

inline Asset* loadFont(char* path, i32 size) {

    TTF_Font* font = TTF_OpenFont(path, size);
    if (font == NULL) return NULL;

    Asset* asset = (Asset*) SDL_malloc(sizeof(Asset));
    asset->kind  = AssetKind_Font;
    asset->font  = font;
    return asset;
}

inline Asset* Asset_loadTexture(char* path) {

    GPU_Image* image = GPU_LoadImage(path);
    if (image == NULL) return NULL;

    Asset* asset = (Asset*) SDL_malloc(sizeof(Asset));

    asset->kind    = AssetKind_Texture;
    asset->texture = image;

    return asset;
}

#endif
