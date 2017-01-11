
#ifndef Renderer_H
#define Renderer_H

#include "Debug.h"
#include "World.h"
#include "Entity.h"
#include "math.h"
#include "gb.h"
#include <SDL.h>
#include <SDL_ttf.h>
#include <SDL_gpu.h>

inline SDL_Color makeColor(u32 rgb, u8 a) {
    SDL_Color result;
    result.r = (rgb >> 16) & 0xFF;
    result.g = (rgb >> 8) & 0xFF;
    result.b = rgb & 0xFF;
    result.a = a;
    return result;
}

inline SDL_Color makeColor(u32 rgb) {
    SDL_Color result;
    result.r = (rgb >> 16) & 0xFF;
    result.g = (rgb >> 8) & 0xFF;
    result.b = rgb & 0xFF;
    result.a = 0xFF;
    return result;
}

// TODO(vdka): Allow camera update to take a V2
inline void Camera_update(Entity* camera, const Entity player, f32 dt) {

    //    V2 diffPlayer = V2_sub(player.position, camera->position);
    //
    //    if (V2_isZero(player.velocity))
    //        camera->velocity = V2_mul(diffPlayer, dt * 25);
    //    else
    //        camera->velocity = V2_mul(player.velocity, 0.9);
    camera->position.x = player.position.x;
    camera->position.y = player.position.y;

    //    f32 distanceFromPlayer = V2_mag(V2_sub(player.position,
    //    camera->position));
    //    f32 maxDistance        = 5.f;
    //    if (distanceFromPlayer > maxDistance) {
    //        camera->position =
    //            V2_lerp(camera->position, player.position, maxDistance /
    //            distanceFromPlayer);
    //    }
    //
    //    Entity_update(camera, dt);
    // camera->position =
    //    camera->camera.scale = 1 + V2_mag(player.velocity) * .65;
}

// Translates a rect from (center, dimensions) to ()
inline Rect worldToCamera(Rect camera, Rect entity) {
    Rect result = entity;

    // result.x = entity.x - camera.x;
    // result.x = entity.y - camera.y;
    //
    // result.x = (entity.x - camera.x) + camera.w / 2;
    // result.y = -(entity.y - camera.y) - camera.h / 2;

    result.x = (2 * (entity.x - camera.x) - entity.w + camera.w) / 2;
    result.y = -(2 * (entity.y - camera.y) + entity.h + camera.h) / 2;
    return result;
}

inline Rect cameraToWorld(Rect camera, Rect entity) {
    Rect result = entity;

    result.x = (2 * entity.x + entity.w + 2 * camera.x - camera.w) / 2;
    result.y = -(2 * entity.y - entity.h - 2 * camera.y - camera.h) / 2;
    return result;
}

inline Rect cameraToRenderer(Rect camera, Rect entity) {

    // TODO(vdka): Get this from the window
    i32 rendererWidth  = 640;
    i32 rendererHeight = 480;

    f32 horzScale = rendererWidth / camera.w;
    f32 vertScale = rendererHeight / camera.h;

    Rect result;
    result.x = entity.x * horzScale;
    result.y = entity.y * vertScale + rendererHeight;
    result.w = entity.w * horzScale;
    result.h = entity.h * vertScale;
    return result;
}

inline Rect rendererToCamera(Rect camera, Rect entity) {

    // TODO(vdka): Get this from the window
    i32 rendererWidth  = 640;
    i32 rendererHeight = 480;

    f32 horzScale = camera.w / rendererWidth;
    f32 vertScale = camera.h / rendererHeight;

    Rect result;
    result.x = entity.x * horzScale;
    result.y = entity.y * vertScale;
    result.w = entity.w * horzScale;
    result.h = entity.h * vertScale;
    return result;
}

inline Rect worldToRenderer(Rect camera, Rect entity) {
    return cameraToRenderer(camera, worldToCamera(camera, entity));
}

inline V2 worldToRenderer(Rect camera, V2 point) {
    Rect dummy = {.position = point, .size = V2_zero};
    return worldToRenderer(camera, dummy).position;
}

inline Rect rendererToWorld(Rect camera, Rect entity) {
    return cameraToWorld(camera, rendererToCamera(camera, entity));
}

inline V2 rendererToWorld(Rect camera, V2 point) {
    Rect dummy = {.position = point, .size = V2_zero};
    return rendererToWorld(camera, dummy).position;
}

inline void renderTriangle(Entity entity, V2 segStart, V2 segEnd, Entity camera,
                           GPU_Target* renderer) {
    V2 center = entity.position;
    V2 rayEnd;
    rayEnd = V2_mul(V2_norm(V2_sub(segStart, center)), 40);

    V2 t1 = V2_raycast(entity.position, rayEnd, segStart, segEnd);

    rayEnd = V2_mul(V2_norm(V2_sub(segEnd, center)), 40);
    V2 t2  = V2_raycast(entity.position, rayEnd, segStart, segEnd);

    center = worldToRenderer(camera.rect, center);
    t1     = worldToRenderer(camera.rect, t1);
    t2     = worldToRenderer(camera.rect, t2);

    GPU_TriFilled(renderer, center.x, center.y, t1.x, t1.y, t2.x, t2.y,
                  makeColor(0xFFFFFF, 0xAA));
}

inline void World_ridShadows(Entity camera, Entity* emitter, World world,
                             GPU_Target* renderer) {

    V2* vertices = Rect_vertices(camera.rect);

    V2 center = emitter->position;
    V2 t1     = World_detectCollisions(emitter, vertices[1], V2_zero, world);
    V2 t2     = World_detectCollisions(emitter, vertices[2], V2_zero, world);

    center = worldToRenderer(camera.rect, center);
    t1     = worldToRenderer(camera.rect, t1);
    t2     = worldToRenderer(camera.rect, t2);

    GPU_TriFilled(renderer, center.x, center.y, t1.x, t1.y, t2.x, t2.y,
                  makeColor(0xAA8855, 0x55));
}

inline void World_castShadows(Entity camera, Entity* emitter, World world,
                              GPU_Target* renderer) {

    Array<V2> hits;
    Array_init(&hits);

    V2 center = emitter->position;

    for (i32 i = 0; i < world.entities.count; i++) {
        Entity entity = world.entities[i];

        if (entity.kind == EntityKind_Player) continue;
        if (entity.kind == EntityKind_Bullet) continue;

        V2* verts = Rect_vertices(entity.rect);

        for (i32 j = 0; j < 4; j++) {
            V2 vertex = verts[j];
            V2 next   = verts[j + 1 % 4];

            vertex = World_detectCollisions(emitter, vertex, V2_zero, world);
            next   = World_detectCollisions(emitter, next, V2_zero, world);

            center = worldToRenderer(camera.rect, center);
            vertex = worldToRenderer(camera.rect, vertex);
            next   = worldToRenderer(camera.rect, next);

//            GPU_TriFilled(renderer, center.x, center.y,
//                          vertex.x, vertex.y, next.x, next.y,
//                          makeColor(0xAA8855, 0xAA));
        }
    }
}

inline void Entity_render(Entity* entity, Entity camera, World world,
                          GPU_Target* renderer) {

    Rect renderRect = worldToRenderer(camera.rect, entity->rect);

    switch (entity->kind) {
    case EntityKind_Invalid: {
        GPU_RectangleFilled2(renderer, renderRect.gpu, makeColor(0xFF0000));
        break;
    }

    case EntityKind_Player: {

        World_ridShadows(camera, entity, world, renderer);
//        World_castShadows(camera, entity, world, renderer);

        if (!V2_isUndefined(entity->player.aimingTarget)) {

            // V2 end =
            //     Rect_raycast(entity->position, entity->player.aimingTarget,
            //     world.entities[0].rect);

            V2 end = World_raycast(entity->position,
                                   entity->player.aimingTarget, V2_zero, world);

            Rect targetWorld = {.position = end, 0, 0};

            Rect target    = worldToRenderer(camera.rect, targetWorld);
            Rect mouseRect = {.position = entity->player.aimingTarget,
                              .size     = V2_zero};
            Rect mousePos = worldToRenderer(camera.rect, mouseRect);
            V2   source =
                V2_lerp(Rect_center(renderRect), mousePos.position, 0.1);
            GPU_SetLineThickness(2);
            GPU_Line(renderer, source.x, source.y, target.x, target.y,
                     makeColor(0xCCCCCC));
            GPU_SetLineThickness(1);
        }

        GPU_Rect spriteSourceRect = {(u8) entity->player.spriteOffset * 6, 0, 6,
                                     6};

        GPU_Image* sheet = Entity::assets[EntityKind_Player]->texture;

        GPU_BlitTransform(sheet, &spriteSourceRect, renderer,
                          renderRect.x + renderRect.w / 2,
                          renderRect.y + renderRect.h / 2,
                          entity->player.facing * 360 / TAU,
                          renderRect.w / spriteSourceRect.w,
                          renderRect.h / spriteSourceRect.h);

        break;
    }

    case EntityKind_Bullet: {

        GPU_Pixel(renderer, renderRect.x, renderRect.y, makeColor(0xFF0000));

        break;
    }

    case EntityKind_Wall: {

        GPU_RectangleFilled2(renderer, renderRect.gpu,
                             makeColor(entity->wall.color));

        break;
    }

    case EntityKind_Camera: {
        renderRect.x += 0.1;
        renderRect.w -= 0.1;
        renderRect.y += 0.1;
        renderRect.h -= 0.1;
        GPU_Rectangle2(renderer, renderRect.gpu, makeColor(0xFF0000, 0xAA));

        break;
    }
    case EntityKind_Last:
        break;
    }
}

inline void renderText(GPU_Target* renderer, const char* text, TTF_Font* font,
                       SDL_Color fg, V2 targetPoint) {

    SDL_Surface* surface = TTF_RenderText_Solid(font, text, fg);
    if (surface == NULL) return;

    GPU_Image* image = GPU_CopyImageFromSurface(surface);
    if (image == NULL) return;
    SDL_FreeSurface(surface);

    GPU_Blit(image, NULL, renderer, targetPoint.x, targetPoint.y);

    GPU_FreeImage(image);
}

inline void render(GPU_Target* renderer, World* world) {

    GPU_ClearColor(renderer, makeColor(0x000000));

    for (i32 i = 0; i < world->entities.count; i++)
        Entity_render(&world->entities[i], world->camera, *world, renderer);

    Entity_render(&world->camera, world->camera, *world, renderer);
}

inline void renderPresent(GPU_Target* renderer, DebugInfo* debugInfo, f32* dt) {

    u64 frameTimeLast = debugInfo->frameTimeLast;

    u64 index = debugInfo->countedFrames % FRAME_TIMES;

    u64 frameEnd = SDL_GetPerformanceCounter();

    *dt = (f32)(frameEnd - debugInfo->frameTimeLast) /
          SDL_GetPerformanceFrequency();

    debugInfo->countedFrames += 1;
    debugInfo->frameTimes[index] = frameEnd - debugInfo->frameTimeLast;

    debugInfo->frameTimeLast = frameEnd;

    u64 count;
    if (debugInfo->countedFrames < FRAME_TIMES)
        count = debugInfo->countedFrames;
    else
        count = FRAME_TIMES;

    debugInfo->fps = 0;

    for (u32 i = 0; i < count; i++)
        debugInfo->fps += debugInfo->frameTimes[i];

    debugInfo->fps /= count;

    debugInfo->fps = SDL_GetPerformanceFrequency() / debugInfo->fps;

    char fpsBuffer[32];

    sprintf(fpsBuffer, "%.2ffps", debugInfo->fps);

    renderText(renderer, fpsBuffer, debugInfo->font->font, makeColor(0xFFFFFF),
               makeV2(40, 10));

    GPU_Flip(renderer);

    *dt = (f32)(SDL_GetPerformanceCounter() - frameTimeLast) /
          SDL_GetPerformanceFrequency();
}

#endif
