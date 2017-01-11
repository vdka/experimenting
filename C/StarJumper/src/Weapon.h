
#include "gb.h"

enum WeaponKind {
    WeaponKind_None,

    WeaponKind_Pistol,
};

enum WeaponState {
    WeaponState_Ready,
    WeaponState_Cooldown,
    WeaponState_Reloading,
    WeaponState_Empty,
};

struct Weapon {
    WeaponKind  kind;
    WeaponState state;

    // remaining ammo in the current clip
    f32 clip;
    // remaining ammo that is not loaded
    f32 reserve;

    // time remaining in current reload
    f32 reload;
    // time remaining until next ready
    f32 cooldown;
};
