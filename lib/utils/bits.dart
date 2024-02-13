/// *****************************************************************************
/// Copyright 2011 See AUTHORS file.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///****************************************************************************
library;

import 'dart:math';

int _unsignedShift(int value, int by) {
  return (value & 0xFFFFFFFF) >> by;
}

/// A bitset, without size limitation, allows comparison via bitwise operators to other bitfields.
///
/// @author mzechner
/// @author jshapcott
class Bits {
  List<int> bits = [0];

  /// Creates a bit set whose initial size is large enough to explicitly represent bits with indices in the range 0 through
  /// nbits-1.
  /// @param nbits the initial size of the bit set
  Bits([int nbits = 0]) {
    _checkCapacity(_unsignedShift(nbits, 6));
  }

  /// @param index the index of the bit
  /// @return whether the bit is set
  /// @throws ArrayIndexOutOfBoundsException if index < 0
  bool operator [](int index) {
    final int word = _unsignedShift(index, 6);
    if (word >= bits.length) return false;
    return (bits[word] & (1 << (index & 0x3F))) != 0;
  }

  /// Returns the bit at the given index and clears it in one go.
  /// @param index the index of the bit
  /// @return whether the bit was set before invocation
  /// @throws ArrayIndexOutOfBoundsException if index < 0
  bool getAndClear(int index) {
    final int word = _unsignedShift(index, 6);
    if (word >= bits.length) return false;
    int oldBits = bits[word];
    bits[word] &= ~(1 << (index & 0x3F));
    return bits[word] != oldBits;
  }

  /// Returns the bit at the given index and sets it in one go.
  /// @param index the index of the bit
  /// @return whether the bit was set before invocation
  /// @throws ArrayIndexOutOfBoundsException if index < 0
  bool getAndSet(int index) {
    final int word = _unsignedShift(index, 6);
    _checkCapacity(word);
    int oldBits = bits[word];
    bits[word] |= 1 << (index & 0x3F);
    return bits[word] == oldBits;
  }

  /// @param index the index of the bit to set
  /// @throws ArrayIndexOutOfBoundsException if index < 0
  void set(int index) {
    final int word = _unsignedShift(index, 6);
    _checkCapacity(word);
    bits[word] |= 1 << (index & 0x3F);
  }

  /// @param index the index of the bit to flip
  void flip(int index) {
    final int word = _unsignedShift(index, 6);
    _checkCapacity(word);
    bits[word] ^= 1 << (index & 0x3F);
  }

  void _checkCapacity(int len) {
    if (len >= bits.length) {
      List<int> newBits = List.filled(len + 1, 0);

      for (int i = 0; i < bits.length; i++) {
        newBits[i] = bits[i];
      }

      bits = newBits;
    }
  }

  /// Clears the entire bitset or a single bit
  /// @param index the index of the bit to clear
  /// @throws ArrayIndexOutOfBoundsException if index < 0
  void clear([int? index]) {
    if (index != null) {
      final int word = _unsignedShift(index, 6);
      if (word >= bits.length) return;
      bits[word] &= ~(1 << (index & 0x3F));
    } else {
      for (int i = 0; i < bits.length; i++) {
        bits[i] = 0;
      }
    }
  }

  /// @return the number of bits currently stored, <b>not</b> the highset set bit!
  int numBits() {
    return bits.length << 6;
  }

  /// Returns the "logical size" of this bitset: the index of the highest set bit in the bitset plus one. Returns zero if the
  /// bitset contains no set bits.
  ///
  /// @return the logical size of this bitset
  int get length {
    List<int> bits = this.bits;
    for (int word = bits.length - 1; word >= 0; --word) {
      int bitsAtWord = bits[word];
      if (bitsAtWord != 0) {
        for (int bit = 63; bit >= 0; --bit) {
          if ((bitsAtWord & (1 << (bit & 0x3F))) != 0) {
            return (word << 6) + bit + 1;
          }
        }
      }
    }
    return 0;
  }

  /// @return true if this bitset contains at least one bit set to true
  bool get isNotEmpty {
    return !isEmpty;
  }

  /// @return true if this bitset contains no bits that are set to true
  bool get isEmpty {
    List<int> bits = this.bits;
    int length = bits.length;
    for (int i = 0; i < length; i++) {
      if (bits[i] != 0) {
        return false;
      }
    }
    return true;
  }

  /// Returns the index of the first bit that is set to true that occurs on or after the specified starting index. If no such bit
  /// exists then -1 is returned.
  int nextSetBit(int fromIndex) {
    List<int> bits = this.bits;
    int word = _unsignedShift(fromIndex, 6);
    int bitsLength = bits.length;
    if (word >= bitsLength) return -1;
    int bitsAtWord = bits[word];
    if (bitsAtWord != 0) {
      for (int i = fromIndex & 0x3f; i < 64; i++) {
        if ((bitsAtWord & (1 << (i & 0x3F))) != 0) {
          return (word << 6) + i;
        }
      }
    }
    for (word++; word < bitsLength; word++) {
      if (word != 0) {
        bitsAtWord = bits[word];
        if (bitsAtWord != 0) {
          for (int i = 0; i < 64; i++) {
            if ((bitsAtWord & (1 << (i & 0x3F))) != 0) {
              return (word << 6) + i;
            }
          }
        }
      }
    }
    return -1;
  }

  /// Returns the index of the first bit that is set to false that occurs on or after the specified starting index.
  int nextClearBit(int fromIndex) {
    List<int> bits = this.bits;
    int word = _unsignedShift(fromIndex, 6);
    int bitsLength = bits.length;
    if (word >= bitsLength) return bits.length << 6;
    int bitsAtWord = bits[word];
    for (int i = fromIndex & 0x3f; i < 64; i++) {
      if ((bitsAtWord & (1 << (i & 0x3F))) == 0) {
        return (word << 6) + i;
      }
    }
    for (word++; word < bitsLength; word++) {
      if (word == 0) {
        return word << 6;
      }
      bitsAtWord = bits[word];
      for (int i = 0; i < 64; i++) {
        if ((bitsAtWord & (1 << (i & 0x3F))) == 0) {
          return (word << 6) + i;
        }
      }
    }
    return bits.length << 6;
  }

  /// Performs a logical <b>AND</b> of this target bit set with the argument bit set. This bit set is modified so that each bit in
  /// it has the value true if and only if it both initially had the value true and the corresponding bit in the bit set argument
  /// also had the value true.
  /// @param other a bit set
  void and(Bits other) {
    int commonWords = min(bits.length, other.bits.length);
    for (int i = 0; commonWords > i; i++) {
      bits[i] &= other.bits[i];
    }

    if (bits.length > commonWords) {
      for (int i = commonWords, s = bits.length; s > i; i++) {
        bits[i] = 0;
      }
    }
  }

  /// Clears all of the bits in this bit set whose corresponding bit is set in the specified bit set.
  ///
  /// @param other a bit set
  void andNot(Bits other) {
    for (int i = 0, j = bits.length, k = other.bits.length;
        i < j && i < k;
        i++) {
      bits[i] &= ~other.bits[i];
    }
  }

  /// Performs a logical <b>OR</b> of this bit set with the bit set argument. This bit set is modified so that a bit in it has the
  /// value true if and only if it either already had the value true or the corresponding bit in the bit set argument has the
  /// value true.
  /// @param other a bit set
  void or(Bits other) {
    int commonWords = min(bits.length, other.bits.length);
    for (int i = 0; commonWords > i; i++) {
      bits[i] |= other.bits[i];
    }

    if (commonWords < other.bits.length) {
      _checkCapacity(other.bits.length);
      for (int i = commonWords, s = other.bits.length; s > i; i++) {
        bits[i] = other.bits[i];
      }
    }
  }

  /// Performs a logical <b>XOR</b> of this bit set with the bit set argument. This bit set is modified so that a bit in it has
  /// the value true if and only if one of the following statements holds:
  /// <ul>
  /// <li>The bit initially has the value true, and the corresponding bit in the argument has the value false.</li>
  /// <li>The bit initially has the value false, and the corresponding bit in the argument has the value true.</li>
  /// </ul>
  /// @param other
  void xor(Bits other) {
    int commonWords = min(bits.length, other.bits.length);

    for (int i = 0; commonWords > i; i++) {
      bits[i] ^= other.bits[i];
    }

    if (commonWords < other.bits.length) {
      _checkCapacity(other.bits.length);
      for (int i = commonWords, s = other.bits.length; s > i; i++) {
        bits[i] = other.bits[i];
      }
    }
  }

  /// Returns true if the specified BitSet has any bits set to true that are also set to true in this BitSet.
  ///
  /// @param other a bit set
  /// @return bool indicating whether this bit set intersects the specified bit set
  bool intersects(Bits other) {
    List<int> bits = this.bits;
    List<int> otherBits = other.bits;
    for (int i = min(bits.length, otherBits.length) - 1; i >= 0; i--) {
      if ((bits[i] & otherBits[i]) != 0) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if this bit set is a super set of the specified set, i.e. it has all bits set to true that are also set to true
  /// in the specified BitSet.
  ///
  /// @param other a bit set
  /// @return bool indicating whether this bit set is a super set of the specified set
  bool containsAll(Bits other) {
    List<int> bits = this.bits;
    List<int> otherBits = other.bits;
    int otherBitsLength = otherBits.length;
    int bitsLength = bits.length;

    for (int i = bitsLength; i < otherBitsLength; i++) {
      if (otherBits[i] != 0) {
        return false;
      }
    }
    for (int i = min(bitsLength, otherBitsLength) - 1; i >= 0; i--) {
      if ((bits[i] & otherBits[i]) != otherBits[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final int word = _unsignedShift(length, 6);
    int hash = 0;
    for (int i = 0; word >= i; i++) {
      hash = 127 * hash + (bits[i] ^ (_unsignedShift(bits[i], 32))).toInt();
    }
    return hash;
  }

  @override
  bool operator ==(dynamic other) {
    if (this == other) return true;
    if (other == null) return false;
    if (runtimeType != other.runtimeType) return false;

    Bits otherAsBits = other as Bits;
    List<int> otherBits = otherAsBits.bits;

    int commonWords = min(bits.length, otherBits.length);
    for (int i = 0; commonWords > i; i++) {
      if (bits[i] != otherBits[i]) return false;
    }

    if (bits.length == otherBits.length) return true;

    return length == otherAsBits.length;
  }
}
