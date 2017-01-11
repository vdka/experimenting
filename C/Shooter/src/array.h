
#ifndef array_h
#define array_h

#include "common.h"
#include <functional>

#define ARRAY_GROW_FORMULA(x) (2 * (x) + 8)

// This type is fully referential
template<typename T>
struct Array {
    T* data;
    
    T& operator[](isize index) {
        assert(0 <= index && index < count()); // Index out of bounds
        return data[index];
    }
    T const& operator[](isize index) const {
        assert(0 <= index && index < count()); // Index out of bounds
        return data[index];
    }
    
    struct Header {
        isize count;
        isize capacity;
    };
    
    Header* info() {
        return (Header*)data - 1;
    }
    
    isize count() {
        if (data == NULL) return 0;
        return ((Header*)data - 1)->count;
    }
    
    isize capacity() {
        if (data == NULL) return 0;
        return ((Header*)data - 1)->capacity;
    }
    
    void* getBase();

    void free();
    void grow(isize minCapacity);
    void shrink(isize maxCapacity);
    void reserve(isize minCapacity);

    void append(T element);
    T remove(isize index);
    T removeLast();
    T removeFirst();

    T* last();
    T* first();

    T* first(std::function<b32 (T)> body);

    void forEach(std::function<void (T)> body);
    void forEachIndex(std::function<void (isize)> body);

    Array<T> filter(std::function<b32 (T)> transform);

    template<typename R>
    Array<R> map(std::function<R (T)> transform);

    template<typename R>
    R reduce(R initial, std::function<R (R, T)> combine);
};

template<typename T>
void* Array<T>::getBase() {
    if (data == NULL) return NULL;
    return (void*) ((Header*) data - 1);
}

template<typename T>
void Array<T>::free() {
    if (data == NULL) return;
    
    void* base = getBase();

    SDL_free(base);
}

template<typename T>
void Array<T>::reserve(isize minCapacity) {
    if (minCapacity < capacity()) return;

    assert(minCapacity >= 0);
    
    void* base = getBase();

    base = (void*) SDL_realloc(base, sizeof(T) * minCapacity + sizeof(Header));
    
    data = (T*) ((Header*) base + 1);
    
    info()->capacity = minCapacity;
}

template<typename T>
void Array<T>::grow(isize minCapacity) {
    if (minCapacity < capacity()) return;

    isize newCapacity = ARRAY_GROW_FORMULA(minCapacity);
    assert(newCapacity > capacity());
    assert(newCapacity >= 0);
    
    void* base = getBase();
    
    base = (void*) SDL_realloc(base, sizeof(T) * newCapacity + sizeof(Header));
    
    data = (T*) ((Header*) base + 1);
    
    info()->capacity = newCapacity;
}

template<typename T>
void Array<T>::shrink(isize maxCapacity) {
    if (maxCapacity <= capacity()) return;

    void* base = getBase();
    
    base = (void*) SDL_realloc(base, sizeof(T) * maxCapacity + sizeof(Header));
    
    data = (T*) ((Header*) base + 1);

    if (maxCapacity > count()) count() = maxCapacity;
}

template<typename T>
void Array<T>::append(T element) {
    if (capacity() == 0) grow(count());
    if (capacity() < count()) grow(count());

    data[count()] = element;
    
    info()->count += 1;
}

template<typename T>
T Array<T>::remove(isize index) {
    assert(index < count());
    info()->count -= 1;
    

    T result = data[index];

    if (index == count())
        return result;

    SDL_memmove(data + index, data + index + 1, (count() - index) * sizeof(T));

    return result;
}

template<typename T>
T Array<T>::removeFirst() {
    assert(count() > 0);
    count() -= 1;

    T result = data[0];

    if (count() == 0)
        return result;

    SDL_memmove(data, data + 1, count() * sizeof(T));

    return result;
}

template<typename T>
T Array<T>::removeLast() {
    assert(count() > 0);

    info()->count -= 1;
    return data[count()];
}

template<typename T>
T* Array<T>::first() {
    if (count() < 1) return NULL;

    return &data[0];
}

template<typename T>
T* Array<T>::last() {
    if (count() < 1) return NULL;

    return &data[count() - 1];
}

template<typename T>
T* Array<T>::first(std::function<b32 (T)> body) {
    for (isize i = 0; i < count(); i++)
        if (body(data[i])) return &data[i];
    return NULL;
}

template<typename T>
void Array<T>::forEach(std::function<void (T)> body) {
    for (isize i = 0; i < count(); i++)
        body(data[i]);
}

template<typename T>
void Array<T>::forEachIndex(std::function<void (isize)> body) {
    for (isize i = 0; i < count(); i++)
        body(i);
}

template<typename T>
Array<T> Array<T>::filter(std::function<b32 (T)> predicate) {
    Array<T> result = {0};
    result.reserve(count());

    forEach([=] (T val) {
        if (predicate(val)) result.append(val);
    });
}

template<typename T>
template<typename R>
Array<R> Array<T>::map(std::function<R (T)> transform) {
    Array<R> result = {0};
    result.reserve(count());

    forEach([] (T val) {
        result.append(val);
    });

    return result;
}

template<typename T>
template<typename R>
R Array<T>::reduce(R initial, std::function<R (R, T)> combine) {

    R result = initial;

    forEach([=] (T val) {
        result = combine(result, val);
    });

    return result;
}

#undef GETSTART

#endif /* array_h */
