
#ifndef map_h
#define map_h

#include "common.h"
#include <functional>

#define MAP_GROW_FORMULA(x) (2 * (x) + 8)

template<typename Key, typename Value>
struct Map {

    Array<Key> keys;
    Array<Value> values;

    Value* operator[](Key key) {

        Value* result = lookup(key);

        return result;
    }
    Value* const& operator[](Key key) const {

        return lookup(key);
    }

    void free();
    void insert(Key key, Value value);
    Value* lookup(Key key);
    void remove(Key key, Value* result = NULL);
};

template<typename Key, typename Value>
void Map<Key, Value>::free() {
    keys.free();
    values.free();
}

template<typename Key, typename Value>
void Map<Key, Value>::insert(Key key, Value value) {
    remove(key);

    keys.append(key);
    values.append(value);
}

template<typename Key, typename Value>
Value* Map<Key, Value>::lookup(Key key) {

    // TODO(vdka): early exit w/ first
    Value* result = NULL;
    keys.forEachIndex([&] (isize index) {
        if (key == keys[index])
            result = &values[index];
    });

    return result;
}

template<typename Key, typename Value>
void Map<Key, Value>::remove(Key key, Value* result) {

    keys.forEachIndex([&] (isize index) {

        if (key == keys[index]) {
            if (result != NULL) {
                *result = values[index];
                keys.remove(index);
                values.remove(index);
            }
            return;
        }
    });

    result = NULL;
}

#endif /* map_h */
