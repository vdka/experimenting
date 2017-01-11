
#ifndef player_H
#define player_H

#include "Entity.h"
// #include "World.h"
#include "inputManager.h"
#include "math.h"
#include "Array.h"

struct World;

Entity* Player_spawn(V2 position, World* world);

void Player_update(Entity* player, World world, f32 dt);

void Player_handleInput(Entity* player, Entity camera, const PlayerInput input, const f32 dt);

#endif
