#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>

#define FINGER_TIP_SWITCH 0x0

// Taken from https://stackoverflow.com/questions/69840885/hid-compliant-touch-screen-packet-data-structure
typedef struct
{
    uint8_t  reportId;                                 // Report ID = 0x01 (1)
                                                       // Collection: CA:TouchScreen CL:Finger
    uint8_t  DIG_TouchScreenFingerTipSwitch : 1;       // Usage 0x000D0042: Tip Switch, Value = 0 to 1
    uint8_t  : 7;                                      // Pad
    uint8_t  DIG_TouchScreenFingerContactIdentifier;   // Usage 0x000D0051: Contact Identifier, Value = 0 to 1
    uint16_t GD_TouchScreenFingerX[2];                 // Usage 0x00010030: X, Value = 0 to 4095, Physical = Value x 241 / 819 in 10⁻² inch units
    uint16_t GD_TouchScreenFingerY[2];                 // Usage 0x00010031: Y, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerWidth;               // Usage 0x000D0048: Width, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerHeight;              // Usage 0x000D0049: Height, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerAzimuth;             // Usage 0x000D003F: Azimuth, Value = 0 to 62831, Physical = Value in 10⁻⁴ rad units
    uint8_t  DIG_TouchScreenFingerTipSwitch_1 : 1;     // Usage 0x000D0042: Tip Switch, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint8_t  : 7;                                      // Pad
    uint8_t  DIG_TouchScreenFingerContactIdentifier_1; // Usage 0x000D0051: Contact Identifier, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint16_t GD_TouchScreenFingerX_1[2];               // Usage 0x00010030: X, Value = 0 to 4095, Physical = Value x 241 / 819 in 10⁻² inch units
    uint16_t GD_TouchScreenFingerY_1[2];               // Usage 0x00010031: Y, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerWidth_1;             // Usage 0x000D0048: Width, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerHeight_1;            // Usage 0x000D0049: Height, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerAzimuth_1;           // Usage 0x000D003F: Azimuth, Value = 0 to 62831, Physical = Value in 10⁻⁴ rad units
    uint8_t  DIG_TouchScreenFingerTipSwitch_2 : 1;     // Usage 0x000D0042: Tip Switch, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint8_t  : 7;                                      // Pad
    uint8_t  DIG_TouchScreenFingerContactIdentifier_2; // Usage 0x000D0051: Contact Identifier, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint16_t GD_TouchScreenFingerX_2[2];               // Usage 0x00010030: X, Value = 0 to 4095, Physical = Value x 241 / 819 in 10⁻² inch units
    uint16_t GD_TouchScreenFingerY_2[2];               // Usage 0x00010031: Y, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerWidth_2;             // Usage 0x000D0048: Width, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerHeight_2;            // Usage 0x000D0049: Height, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerAzimuth_2;           // Usage 0x000D003F: Azimuth, Value = 0 to 62831, Physical = Value in 10⁻⁴ rad units
    uint8_t  DIG_TouchScreenFingerTipSwitch_3 : 1;     // Usage 0x000D0042: Tip Switch, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint8_t  : 7;                                      // Pad
    uint8_t  DIG_TouchScreenFingerContactIdentifier_3; // Usage 0x000D0051: Contact Identifier, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint16_t GD_TouchScreenFingerX_3[2];               // Usage 0x00010030: X, Value = 0 to 4095, Physical = Value x 241 / 819 in 10⁻² inch units
    uint16_t GD_TouchScreenFingerY_3[2];               // Usage 0x00010031: Y, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerWidth_3;             // Usage 0x000D0048: Width, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerHeight_3;            // Usage 0x000D0049: Height, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerAzimuth_3;           // Usage 0x000D003F: Azimuth, Value = 0 to 62831, Physical = Value in 10⁻⁴ rad units
    uint8_t  DIG_TouchScreenFingerTipSwitch_4 : 1;     // Usage 0x000D0042: Tip Switch, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint8_t  : 7;                                      // Pad
    uint8_t  DIG_TouchScreenFingerContactIdentifier_4; // Usage 0x000D0051: Contact Identifier, Value = 0 to 1, Physical = Value x 62831 in 10⁻⁴ rad units
    uint16_t GD_TouchScreenFingerX_4[2];               // Usage 0x00010030: X, Value = 0 to 4095, Physical = Value x 241 / 819 in 10⁻² inch units
    uint16_t GD_TouchScreenFingerY_4[2];               // Usage 0x00010031: Y, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerWidth_4;             // Usage 0x000D0048: Width, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerHeight_4;            // Usage 0x000D0049: Height, Value = 0 to 4095, Physical = Value x 302 / 1365 in 10⁻² inch units
    uint16_t DIG_TouchScreenFingerAzimuth_4;           // Usage 0x000D003F: Azimuth, Value = 0 to 62831, Physical = Value in 10⁻⁴ rad units
                                                       // Collection: CA:TouchScreen
    uint16_t DIG_TouchScreenRelativeScanTime;          // Usage 0x000D0056: Relative Scan Time, Value = 0 to 65535, Physical = Value in 10⁻⁴ s units
    uint8_t  DIG_TouchScreenContactCount;              // Usage 0x000D0054: Contact Count, Value = 0 to 127, Physical = Value x 65535 / 127 in 10⁻⁴ s units
} touch_report_t;

#ifdef __cplusplus
}
#endif
