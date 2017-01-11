
#ifndef Array_h
#define Array_h

#include <SDL.h>

#define ARRAY_GROW_FORMULA(x) (2 * (x) + 8)

typedef size_t    usize;
typedef ptrdiff_t isize;

template <typename T> struct Array {
    T*    data;
    isize count;
    isize capacity;
    T& operator[](isize index) {
        SDL_assert(0 <= index && index < count); // Index out of bounds
        return data[index];
    }
    T const& operator[](isize index) const {
        SDL_assert(0 <= index && index < count); // Index out of bounds
        return data[index];
    }
};

template <typename T> void Array_init(Array<T>* array, isize init_capacity = ARRAY_GROW_FORMULA(0));
template <typename T> Array<T> Array_make(T* data, isize count, isize capacity = 0);
template <typename T> void Array_free(Array<T>* array);
template <typename T> void Array_append(Array<T>* array, T const& t);
template <typename T> T Array_pop(Array<T>* array);
template <typename T> void Array_clear(Array<T>* array);
template <typename T> void Array_reserve(Array<T>* array, isize capacity);
template <typename T> void Array_resize(Array<T>* array, isize count);
template <typename T> void Array_set_capacity(Array<T>* array, isize capacity);

template <typename T> void Array_init(Array<T>* array, isize initCapacity) {
    array->data     = (T*) SDL_malloc(sizeof(T) * initCapacity);
    array->count    = 0;
    array->capacity = initCapacity;
}

template <typename T> Array<T> Array_make(T* data, isize count, isize capacity) {
    SDL_assert(capacity == 0 || capacity >= count);
    Array<T> a = {};
    a.data     = data;
    a.count    = count;
    a.capacity = capacity ?: count;
    return a;
}

template <typename T> void Array_free(Array<T>* array) {
    SDL_free(array->data);
    array->count    = 0;
    array->capacity = 0;
}

template <typename T> void Array__grow(Array<T>* array, isize min_capacity) {
    isize new_capacity = ARRAY_GROW_FORMULA(array->capacity);
    if (new_capacity < min_capacity) {
        new_capacity = min_capacity;
    }
    Array_set_capacity(array, new_capacity);
}

template <typename T> void Array_append(Array<T>* array, T const& t) {
    if (array->capacity < array->count + 1) {
        Array__grow(array, 0);
    }
    array->data[array->count] = t;
    array->count++;
}

template <typename T> T Array_pop(Array<T>* array) {
    SDL_assert(array->count > 0);
    array->count--;
    return array->data[array->count];
}

template <typename T> void Array_clear(Array<T>* array) { array->count = 0; }

template <typename T> void Array_reserve(Array<T>* array, isize capacity) {
    if (array->capacity < capacity) {
        Array_set_capacity(array, capacity);
    }
}

template <typename T> void Array_resize(Array<T>* array, isize count) {
    if (array->capacity < count) {
        Array__grow(array, count);
    }
    array->count = count;
}

template <typename T> void Array_set_capacity(Array<T>* array, isize capacity) {
    if (capacity == array->capacity) {
        return;
    }
    if (capacity < array->count) {
        Array_resize(array, capacity);
    }
    if (capacity > 0) {
        array->data = (T*) SDL_realloc(array->data, sizeof(T) * capacity);
    }
    array->capacity = capacity;
}

#endif
