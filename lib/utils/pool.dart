/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/

import 'dart:math';

const int INT_MAX = 2147483647;
const int INT_MIN = -2147483646;

/** Objects implementing this interface will have {@link #reset()} called when passed to {@link Pool#free(Object)}. */
abstract class Poolable {
  /** Resets the object for reuse. Object references should be nulled and fields may be set to default values. */
  void reset();
}

/** A pool of objects that can be reused to avoid allocation.
 * @see Pools
 * @author Nathan Sweet */
abstract class Pool<T> {
  /** The maximum number of objects that will be pooled. */
  final int maxCapacity;
  /** The highest number of free objects. Can be reset any time. */
  int peak = 0;

  List<T> _freeObjects = [];

  /** @param initialCapacity The initial size of the array supporting the pool. No objects are created unless preFill is true.
	 * @param max The maximum number of free objects to store in this pool.
	 * @param preFill Whether to pre-fill the pool with objects. The number of pre-filled objects will be equal to the initial
	 *           capacity. 
   */
  Pool(
      [int initialCapacity = 16,
      this.maxCapacity = INT_MAX,
      bool preFill = false]) {
    if (initialCapacity > maxCapacity && preFill)
      throw Exception(
          "max must be larger than initialCapacity if preFill is set to true.");
    if (preFill) {
      for (int i = 0; i < initialCapacity; i++) _freeObjects.add(newObject());
      peak = _freeObjects.length;
    }
  }

  T newObject();

  /** Returns an object from this pool. The object may be new (from {@link #newObject()}) or reused (previously
	 * {@link #free(Object) freed}). */
  T obtain() {
    return _freeObjects.length == 0 ? newObject() : _freeObjects.removeLast();
  }

  /** Puts the specified object in the pool, making it eligible to be returned by {@link #obtain()}. If the pool already contains
	 * {@link #max} free objects, the specified object is reset but not added to the pool.
	 * <p>
	 * The pool does not check if an object is already freed, so the same object must not be freed multiple times. */
  void free(T object) {
    if (object == null) throw new Exception("object cannot be null.");
    if (_freeObjects.length < maxCapacity) {
      _freeObjects.add(object);
      peak = max(peak, _freeObjects.length);
    }
    reset(object);
  }

  /** Adds the specified number of new free objects to the pool. Usually called early on as a pre-allocation mechanism but can be
	 * used at any time.
	 *
	 * @param size the number of objects to be added */
  void fill(int size) {
    for (int i = 0; i < size; i++)
      if (_freeObjects.length < maxCapacity) _freeObjects.add(newObject());
    peak = max(peak, _freeObjects.length);
  }

  /** Called when an object is freed to clear the state of the object for possible later reuse. The default implementation calls
	 * {@link Poolable#reset()} if the object is {@link Poolable}. */
  void reset(T object) {
    if (object is Poolable) object.reset();
  }

  /** Puts the specified objects in the pool. Null objects within the array are silently ignored.
	 * <p>
	 * The pool does not check if an object is already freed, so the same object must not be freed multiple times.
	 * @see #free(Object) */
  void freeAll(List<T> objects) {
    if (objects == null) throw new Exception("objects cannot be null.");
    List<T> freeObjects = this._freeObjects;
    int maxCapacity = this.maxCapacity;
    for (int i = 0; i < objects.length; i++) {
      T object = objects[i];
      if (object == null) continue;
      if (freeObjects.length < maxCapacity) freeObjects.add(object);
      reset(object);
    }
    peak = max(peak, freeObjects.length);
  }

  /** Removes all free objects from this pool. */
  void clear() {
    _freeObjects.clear();
  }

  /** The number of objects available to be obtained. */
  int getFree() {
    return _freeObjects.length;
  }
}
