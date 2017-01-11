
#include "player.h"
#include "Entity.h"
#include "math.h"

Asset* Entity::assets[EntityKind_Last] = {0};

EntityTraits Entity::traits[EntityKind_Last] = {0};

void Entity_update(Entity* entity, f32 dt) {

    if (entity->kind == EntityKind_Player) {

    } else {
        entity->position = V2_add(entity->position, V2_mul(entity->velocity, dt));
    }
}
