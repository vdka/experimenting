
#ifndef entity_h
#define entity_h

#include <SDL_gpu.h>
#include "common.h"
#include "math.h"
#include "asset.h"
#include "array.h"

enum EntityKind {
    EntityKind_Invalid,

    EntityKind_Player,
    EntityKind_Camera,

    EntityKind_Wall,
    EntityKind_Bullet,

    EntityKind_Last,
};

struct EntityMetadata {

    V2 size;
    EntityKind kind;
    Array<Asset*> assets;

    struct Flags {

        b32 collides : 1;
    } flags;
};

struct LiveEntity {

    u32 id      : 30; // take bits from here as needed

    b8 isMoving : 1;

    u8 health   : 6;
    b8 aiming   : 1;
    b8 shooting : 1;
    u8 facing   : 8;
    u8 weapon   : 8;

    V2 position;
    V2 velocity;

    static LiveEntity make();
};

inline LiveEntity LiveEntity::make() {
    LiveEntity result = {0};

    static u32 id;
    static u32 limit = pow(2, 30); // NOTE: keep in sync
    id += 1;
    id %= limit;

    result.id = id;
    return result;
}

struct StaticEntity {

    u64 id: 48;

    V2 position;

};

inline b32 isLive(EntityKind kind) {
    switch (kind) {
        case EntityKind_Player:
        case EntityKind_Bullet:
            return true;

        case EntityKind_Wall:
            return false;

        case EntityKind_Invalid:
        case EntityKind_Camera:
        case EntityKind_Last:
            return false;
    }
}

sassert(sizeof(LiveEntity) == 24);

#endif /* entity_h */
