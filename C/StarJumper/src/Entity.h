
#ifndef Entity_H
#define Entity_H

#include "gb.h"
#include "math.h"
#include "Array.h"
#include "Assets.h"
#include "inputManager.h"
#include "Weapon.h"

enum EntityKind {
    EntityKind_Invalid,

    EntityKind_Player,
    EntityKind_Camera,

    EntityKind_Wall,
    EntityKind_Bullet,

    EntityKind_Last,
};

enum EntityState {
    EntityState_Alive,
    EntityState_Dead,
};

struct EntityTraits {
    b32 collides : 1;
};

struct Entity {
    EntityKind  kind;
    EntityState state;

    union {
        struct {
            V2 position;
            V2 size;
        };
        // NOTE: x & y are the center of the entity.
        Rect rect;
    };

    V2  velocity;
    f32 speedCap;
    f32 health;

    static Asset*       assets[];
    static EntityTraits traits[];

    union { // anonymous union
        struct {

            PlayerInput* input;

            b32 isExhausted : 1;
            V2  aimingTarget;
            f32 stamina;
            f32 spriteOffset;
            f32 facing;

            Weapon weapon;
        } player;
        struct {
            u32 color;
        } wall;
    };
};

inline Entity Entity_make() {

    Entity entity   = {EntityKind_Invalid};
    entity.size     = {1, 1}; // NOTE: Should default to undef?
    entity.position = V2_undefined;
    entity.velocity = V2_zero;
    entity.health   = 100;
    entity.speedCap = 1;

    return entity;
}

void Entity_update(Entity* entity, f32 dt);

#endif
