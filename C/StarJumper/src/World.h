
#ifndef World_H
#define World_H

#include "Array.h"
#include "Entity.h"
#include "player.h"
#include "gb.h"
#include "math.h"
#include <SDL.h>

struct World {
    u8 connectedPlayers;
    u8 playerIndices[32];

    Entity        camera;
    Array<Entity> entities;
};

inline World World_make() {

    World world = {0};

    Array_init(&world.entities);

    return world;
}

inline void World_update(World* world, f32 dt) {

    u64 entityCount = world->entities.count;
    for (i32 i = 0; i < entityCount; i++) {
        Entity* entity = &world->entities[i];

        switch (entity->kind) {
        case EntityKind_Player: {
            Player_update(entity, *world, dt);
            break;
        }

        default: {
            Entity_update(entity, dt);
            break;
        }
        }
    }
}

inline b32 World_isTraversable(V2 point, World world) {

    for (i32 i = 0; i < world.entities.count; i++) {
        Entity entity = world.entities[i];
        if (!Entity::traits[entity.kind].collides) continue;

        if (Rect_contains(entity.rect, point)) return false;
    }
    return true;
}

inline V2 World_raycast(V2 rayStart, V2 rayEnd, V2 padding, World world) {

    f32 shortestMagnitude = V2_mag(V2_sub(rayEnd, rayStart));
    V2  shortest          = rayEnd;
    // TODO(vdka): Filter query to limit to entities that are on the same plane
    // as the ray end.
    for (i32 i = 0; i < world.entities.count; i++) {
        Entity entity = world.entities[i];
        if (entity.kind != EntityKind_Wall) continue;

        V2  potential = Rect_raycast(rayStart, rayEnd, padding, entity.rect);
        f32 magnitude = V2_mag(V2_sub(potential, rayStart));
        if (magnitude < shortestMagnitude) {
            shortest          = potential;
            shortestMagnitude = magnitude;
        }
    }

    return shortest;
}

inline V2 World_detectCollisions(Entity* entity, V2 endPos, V2 padding, World world) {
    if (!Entity::traits[entity->kind].collides) return endPos;

    f32 shortestMagnitude = V2_mag(V2_sub(endPos, entity->position));
    V2  shortest          = endPos;
    // TODO(vdka): Filter query to limit to entities that are on the same plane
    // as the ray end.
    for (i32 i = 0; i < world.entities.count; i++) {
        Entity* target = &world.entities[i];
        if (!Entity::traits[target->kind].collides) continue;
        if (target == entity) continue;

        V2  potential = Rect_raycast(entity->position, endPos, padding, target->rect);
        f32 magnitude = V2_mag(V2_sub(potential, entity->position));
        if (magnitude < shortestMagnitude) {
            shortest          = potential;
            shortestMagnitude = magnitude;
        }
    }

    return shortest;
}

inline Array<Polygon> World_getPolygons(World world) {

    Array<Polygon> polygons;
    Array_init(&polygons, world.entities.count - 2);

    return polygons;
}

#endif
