
#include "player.h"
#include "Entity.h"
#include "World.h"
#include "gb.h"
#include "inputManager.h"
#include "math.h"
#include "Renderer.h"

void Player_update(Entity* player, World world, f32 dt) {
    V2 endPos        = V2_add(player->position, V2_mul(player->velocity, dt));
    V2 padding       = {.3, .3};
    V2 colPos        = World_detectCollisions(player, endPos, padding, world);

    player->position = colPos;
}

Entity* Player_spawn(V2 position, World* world) {

    Entity entity   = Entity_make();
    entity.kind     = EntityKind_Player;
    entity.position = position;
    entity.health   = 100;
    entity.player   = {0};
    entity.size     = {1, 1};

    entity.player.stamina = 100;
    entity.player.facing  = -(1 / 4) * TAU;

    Array_append(&world->entities, entity);

    return &world->entities[world->entities.count - 1];
}

V2 forward  = {0, 1};
V2 backward = {0, -1};
V2 left     = {1, 0};
V2 right    = {-1, 0};

void Player_handleInput(Entity* entity, Entity camera, const PlayerInput input, const f32 dt) {

    if (V2_mag(entity->velocity) < 0.2) entity->velocity = V2_zero;

    V2 delta = V2_zero;

    if (isDown(input.moveUp)) delta.y += 10 * dt;
    if (isDown(input.moveDown)) delta.y -= 10 * dt;
    if (isDown(input.moveRight)) delta.x += 10 * dt;
    if (isDown(input.moveLeft)) delta.x -= 10 * dt;

    if (V2_isZero(delta)) entity->velocity = V2_mul(entity->velocity, 1 - dt * 10);

    entity->velocity = V2_add(entity->velocity, delta);

    // NOTE(vdka): MS BF https://battlelog.battlefield.com/bf4/forum/threadview/2955064779058213894/
    // TODO(vdka): improve the stamina regen system with gradule slow down as we run out of stamina
    if (isDown(input.sprint) && !isDown(input.aim) && !V2_isZero(delta) &&
        entity->player.stamina > 0 && !entity->player.isExhausted) {
        entity->speedCap = 5.8; // Usain bolt top speed 12.4 m/s
        entity->player.stamina -= 10 * dt;
        if (entity->player.stamina < 0) entity->player.isExhausted = true;
    } else if (isDown(input.aim)) {
        entity->speedCap = .8;
    } else {
        entity->speedCap = 3.4;
        entity->player.stamina += 10 * dt;
        entity->player.stamina = clamp(entity->player.stamina, 0, 100);

        if (entity->player.stamina > 50) entity->player.isExhausted = false;
    }

    entity->velocity = V2_clampMagnitude(entity->velocity, entity->speedCap);

    if (V2_isZero(delta)) {
        entity->player.spriteOffset = 4;
    } else {
        entity->player.spriteOffset += dt * V2_mag(entity->velocity);
        if (entity->player.spriteOffset >= 4) entity->player.spriteOffset = 0;
    }

    if (isDown(input.aim)) {
        entity->player.spriteOffset = 5;

        Rect mouse = {input.mouseX, input.mouseY, 0, 0};

        mouse = rendererToWorld(camera.rect, mouse);

        entity->player.aimingTarget = mouse.position;
        entity->player.facing =
            -SDL_atan2(mouse.y - entity->position.y, mouse.x - entity->position.x);
    } else {
        entity->player.aimingTarget = V2_undefined;

        if (!V2_isZero(entity->velocity))
            entity->player.facing = SDL_atan2(-entity->velocity.y, entity->velocity.x);
    }
}
