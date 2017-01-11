
#ifndef world_h
#define world_h

#include <SDL.h>
#include "common.h"
#include "entity.h"
#include "map.h"

struct Camera {

    union {
        struct { V2 position, size; };
        Rect rect;
    };
};

struct World {

    Camera camera;
    Array<LiveEntity> liveEntities;
    Array<StaticEntity> staticEntities;
    Map<u64, EntityMetadata> entityData;

    static World make();

    LiveEntity* spawnEntity();
};

inline World World::make() {
    World result = {0};

    result.camera.size = {32, 24};

    return result;
}

inline LiveEntity* World::spawnEntity() {

    LiveEntity entity = LiveEntity::make();

    EntityMetadata metadata = {0};
    metadata.flags.collides = true;
    entityData.insert(entity.id, metadata);

    liveEntities.append(entity);
    return liveEntities.last();
}

#endif /* world_h */
