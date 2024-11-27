/*
 * Author: 3AS, Edited DartRuffian
 * Handles dismounting from an AT-RT, i.e. resetting the camera, controls, etc.
 *
 * Arguments:
 * atrt: Object - The AT-RT to dismount
 *
 * Return Value:
 * None
 *
 * Example:
 * atrt call FST_fnc_dismountATRT;
 */


params ["_atrt"];
private ["_rider", "_direction", "_position", "_collision"];

_rider = _atrt getVariable ["FST_ATRT_rider", nil];
if (isNil "_rider") exitWith {};

// Prevent the player getting stuck on top
_direction = direction _rider;
_position = getPosASL _atrt;
_position =
[
    _position#0 - 0.35 + sin (_direction - 90),
    _position#1 - 0.3 + cos (_direction - 90),
    _position#2 + 1
];

detach _rider;
[_rider, "ChopperLight_C_LOut_H"] remoteExec ["switchMove", 0];
_rider setDir _direction - 90;
_rider setPosASL _position;

_rider setVariable ["FST_ATRT_isRiding", false];

// Switch camera back to rider
if (cameraOn != (vehicle _rider)) then
{
    // Reset camera view to player
    (vehicle _rider) switchCamera cameraView;
};

_atrt remoteControl objNull;
_rider remoteControl objNull;

if (isClass (configFile >> "CfgPatches" >> "ace_advanced_throwing")) then
{
    [_rider, "blockThrow", "ridingATRT", false] call ace_common_fnc_statusEffect_set;
};

//Remove Collision Shield for Rider added by fn_mountATRT.sqf
//_collision = _atrt getVariable ["FST_ATRT_collisionObj", objNull]; // Remove collision
//deleteVehicle _collision;

_atrt setVariable ["FST_ATRT_rider", nil, true]; // Reset rider
inGameUISetEventHandler ["Action", ""];

[
    {
        params ["_rider"];
        [_rider, ""] remoteExec ["switchMove", 0]; // Seated animation
    },
    [_rider],
    0.5
] call CBA_fnc_waitAndExecute;