/*
This is the c configuration file for the keymap

Copyright 2012 Jun Wako <wakojun@gmail.com>
Copyright 2015 Jack Humbert

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma once

/* Select hand configuration */
#define MASTER_LEFT

/* ========== RGB Lighting Settings ========== */
#define RGBLIGHT_SPLIT            // Enables separate LED control per half
#define RGBLIGHT_LIMIT_VAL 120    // Limit brightness (0-255)
#define RGBLIGHT_SLEEP            // Turn off RGB when host is suspended
#define RGBLIGHT_LAYERS           // Allow layer-based lighting (optional)
// #define RGBLIGHT_EFFECT_BREATHING // Optional animation
#define RGBLIGHT_DEFAULT_MODE RGBLIGHT_MODE_STATIC_LIGHT
#define RGBLIGHT_DISABLE_KEYCODES // Don’t use RGB toggle keys unless needed

/* ========== Split Keyboard Options ========== */
// #define SPLIT_HAND_PIN D2         // Pin used to determine handedness (if needed)
// #define EE_HANDS                  // Store handedness in EEPROM

/* ========== Optional OLED or Encoder ========== */
// #define OLED_ENABLE
// #define ENCODER_ENABLE
