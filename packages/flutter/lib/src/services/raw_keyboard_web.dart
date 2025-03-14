// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show hashValues;

import 'package:flutter/foundation.dart';

import 'keyboard_key.dart';
import 'keyboard_maps.dart';
import 'raw_keyboard.dart';

/// Platform-specific key event data for Web.
///
/// See also:
///
///  * [RawKeyboard], which uses this interface to expose key data.
@immutable
class RawKeyEventDataWeb extends RawKeyEventData {
  /// Creates a key event data structure specific for Web.
  ///
  /// The [code] and [metaState] arguments must not be null.
  const RawKeyEventDataWeb({
    required this.code,
    required this.key,
    this.location = 0,
    this.metaState = modifierNone,
  })  : assert(code != null),
        assert(metaState != null);

  /// The `KeyboardEvent.code` corresponding to this event.
  ///
  /// The [code] represents a physical key on the keyboard, a value that isn't
  /// altered by keyboard layout or the state of the modifier keys.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code>
  /// for more information.
  final String code;

  /// The `KeyboardEvent.key` corresponding to this event.
  ///
  /// The [key] represents the key pressed by the user, taking into
  /// consideration the state of modifier keys such as Shift as well as the
  /// keyboard locale and layout.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key>
  /// for more information.
  final String key;

  /// The `KeyboardEvent.location` corresponding to this event.
  ///
  /// The [location] represents the location of the key on the keyboard or other
  /// input device, such as left or right modifier keys, or Numpad keys.
  ///
  /// See <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/location>
  /// for more information.
  final int location;

  /// The modifiers that were present when the key event occurred.
  ///
  /// See `lib/src/engine/keyboard.dart` in the web engine for the numerical
  /// values of the `metaState`. These constants are also replicated as static
  /// constants in this class.
  ///
  /// See also:
  ///
  ///  * [modifiersPressed], which returns a Map of currently pressed modifiers
  ///    and their keyboard side.
  ///  * [isModifierPressed], to see if a specific modifier is pressed.
  ///  * [isControlPressed], to see if a CTRL key is pressed.
  ///  * [isShiftPressed], to see if a SHIFT key is pressed.
  ///  * [isAltPressed], to see if an ALT key is pressed.
  ///  * [isMetaPressed], to see if a META key is pressed.
  final int metaState;

  @override
  String get keyLabel => key == 'Unidentified' ? '' : key;

  @override
  PhysicalKeyboardKey get physicalKey {
    return kWebToPhysicalKey[code] ?? PhysicalKeyboardKey(LogicalKeyboardKey.webPlane + code.hashCode);
  }

  @override
  LogicalKeyboardKey get logicalKey {
    // Look to see if the keyCode is a printable number pad key, so that a
    // difference between regular keys (e.g. ".") and the number pad version
    // (e.g. the "." on the number pad) can be determined.
    final LogicalKeyboardKey? numPadKey = kWebNumPadMap[code];
    if (numPadKey != null) {
      return numPadKey;
    }

    // Look to see if the [code] is one we know about and have a mapping for.
    final LogicalKeyboardKey? newKey = kWebToLogicalKey[code];
    if (newKey != null) {
      return newKey;
    }

    // This is a non-printable key that we don't know about, so we mint a new
    // code.
    return LogicalKeyboardKey(code.hashCode | LogicalKeyboardKey.webPlane);
  }

  @override
  bool isModifierPressed(
    ModifierKey key, {
    KeyboardSide side = KeyboardSide.any,
  }) {
    switch (key) {
      case ModifierKey.controlModifier:
        return metaState & modifierControl != 0;
      case ModifierKey.shiftModifier:
        return metaState & modifierShift != 0;
      case ModifierKey.altModifier:
        return metaState & modifierAlt != 0;
      case ModifierKey.metaModifier:
        return metaState & modifierMeta != 0;
      case ModifierKey.numLockModifier:
        return metaState & modifierNumLock != 0;
      case ModifierKey.capsLockModifier:
        return metaState & modifierCapsLock != 0;
      case ModifierKey.scrollLockModifier:
        return metaState & modifierScrollLock != 0;
      case ModifierKey.functionModifier:
      case ModifierKey.symbolModifier:
        // On Web, the browser doesn't report the state of the FN and SYM modifiers.
        return false;
    }
  }

  @override
  KeyboardSide getModifierSide(ModifierKey key) {
    // On Web, we don't distinguish the sides of modifier keys. Both left shift
    // and right shift, for example, are reported as the "Shift" modifier.
    //
    // See <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/getModifierState>
    // for more information.
    return KeyboardSide.any;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
        properties.add(DiagnosticsProperty<String>('code', code));
        properties.add(DiagnosticsProperty<String>('key', key));
        properties.add(DiagnosticsProperty<int>('location', location));
        properties.add(DiagnosticsProperty<int>('metaState', metaState));
  }

  @override
  bool operator==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is RawKeyEventDataWeb
        && other.code == code
        && other.key == key
        && other.location == location
        && other.metaState == metaState;
  }

  @override
  int get hashCode => hashValues(
    code,
    key,
    location,
    metaState,
  );

  // Modifier key masks.

  /// No modifier keys are pressed in the [metaState] field.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierNone = 0;

  /// This mask is used to check the [metaState] field to test whether one of
  /// the SHIFT modifier keys is pressed.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierShift = 0x01;

  /// This mask is used to check the [metaState] field to test whether one of
  /// the ALT modifier keys is pressed.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierAlt = 0x02;

  /// This mask is used to check the [metaState] field to test whether one of
  /// the CTRL modifier keys is pressed.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierControl = 0x04;

  /// This mask is used to check the [metaState] field to test whether one of
  /// the META modifier keys is pressed.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierMeta = 0x08;

  /// This mask is used to check the [metaState] field to test whether the NUM
  /// LOCK modifier key is on.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierNumLock = 0x10;

  /// This mask is used to check the [metaState] field to test whether the CAPS
  /// LOCK modifier key is on.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierCapsLock = 0x20;

  /// This mask is used to check the [metaState] field to test whether the
  /// SCROLL LOCK modifier key is on.
  ///
  /// Use this value if you need to decode the [metaState] field yourself, but
  /// it's much easier to use [isModifierPressed] if you just want to know if
  /// a modifier is pressed.
  static const int modifierScrollLock = 0x40;
}
