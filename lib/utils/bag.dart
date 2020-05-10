/*******************************************************************************
 * Copyright 2014 See AUTHORS file.
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

/**
 * Fast collection similar to List that grows on demand as elements are accessed. It does not preserve order of elements.
 * Inspired by Artemis Bag.
 */
class Bag<E> {
  List<E> _data;
  int _size = 0;

  /**
	 * Empty Bag with the specified initial capacity.
	 * @param capacity the initial capacity of Bag.
	 */
  Bag([int capacity = 64]) {
    _data = List<E>(capacity);
  }

  /**
	 * Removes the element at the specified position in this Bag. Order of elements is not preserved.
	 * @param index
	 * @return element that was removed from the Bag.
	 */
  E removeAt(int index) {
    E e = _data[index]; // make copy of element to remove so it can be returned
    _data[index] = _data[--_size]; // overwrite item to remove with last element
    _data[_size] = null; // null last element, so gc can do its work
    return e;
  }

  /**
	 * Removes and return the last object in the bag.
	 * @return the last object in the bag, null if empty.
	 */
  E removeLast() {
    if (_size > 0) {
      E e = _data[--_size];
      _data[_size] = null;
      return e;
    }

    return null;
  }

  /**
	 * Removes the first occurrence of the specified element from this Bag, if it is present. If the Bag does not contain the
	 * element, it is unchanged. It does not preserve order of elements.
	 * @param e
	 * @return true if the element was removed.
	 */
  bool remove(E e) {
    for (int i = 0; i < _size; i++) {
      E e2 = _data[i];

      if (e == e2) {
        _data[i] = _data[--_size]; // overwrite item to remove with last element
        _data[_size] = null; // null last element, so gc can do its work
        return true;
      }
    }

    return false;
  }

  /**
	 * Check if bag contains this element. The operator == is used to check for equality.
	 */
  bool contains(E e) {
    for (int i = 0; _size > i; i++) {
      if (e == _data[i]) {
        return true;
      }
    }
    return false;
  }

  /**
	 * @return the element at the specified position in Bag.
	 */
  E operator [](int index) {
    return _data[index];
  }

  /**
	 * @return the number of elements in this bag.
	 */
  int get length {
    return _size;
  }

  /**
	 * @return the number of elements the bag can hold without growing.
	 */
  int get capacity {
    return _data.length;
  }

  /**
	 * @param index
	 * @return whether or not the index is within the bounds of the collection
	 */
  bool isIndexWithinBounds(int index) {
    return index < capacity;
  }

  /**
	 * @return true if this list contains no elements
	 */
  bool get isEmpty {
    return _size == 0;
  }

  /**
	 * Adds the specified element to the end of this bag. if needed also increases the capacity of the bag.
	 */
  void add(E e) {
    // is size greater than capacity increase capacity
    if (_size == _data.length) {
      grow();
    }

    _data[_size++] = e;
  }

  /**
	 * Set element at specified index in the bag.
	 */
  void operator []=(int index, E e) {
    if (index >= _data.length) {
      grow(index * 2);
    }
    _size = max(_size, index + 1);
    _data[index] = e;
  }

  /**
	 * Removes all of the elements from this bag. The bag will be empty after this call returns.
	 */
  void clear() {
    // null all elements so gc can clean up
    for (int i = 0; i < _size; i++) {
      _data[i] = null;
    }

    _size = 0;
  }

  /* private*/ void grow([int newCapacity]) {
    if (newCapacity == null) {
      int newCapacity = (_data.length * 3) ~/ 2 + 1;
      grow(newCapacity);
    } else {
      List<E> oldData = _data;
      _data = List(newCapacity);
      for (int i = 0; i < oldData.length; i++) {
        _data[i] = oldData[i];
      }
    }
  }
}
