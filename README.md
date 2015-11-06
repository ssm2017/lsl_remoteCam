# lsl_remoteCam
Lsl script to remotely control camera.

Camera movement functions made by Jeff Kelley

## What is the concept ?
Several people located on a region can have their viewer's camera controlled by a "director".

## How to use ?
The script is resetted when wearing so to reset it, unwear and wear again.

### Director side
In the object's description, there is the director's uuid.

The director is wearing the object and then allows the camera control.

The director is pushing the button "esc" on its keyboard to reset its camera position.

The director is moving its viewer camera to a selected position and then use the command "record" to get the values to enter in a "gesture".

When the director has filled all the necessary positions, the show can begin.

### Spectator side
In the object's description, there is the director's uuid.

The spectator is wearing the object and then allows the camera control.

The spectator is pushing the button "esc" on its keyboard to reset its camera position.

The spectators waits for the director to begin the show.

## Object color status
  * White : The user has not allowed the camera control.
  * Red : The camera control is allowed but the camera is disabled.
  * Green : The camera is enabled.
  * Yellow : The camera is moving (and the comes back to green when the camera stops the movement).

## Commands available
The default listener channel for gestures is : -1123

### play
This action enables the camera.

ex : `/-1123 play`

### stop
This action disables the camera.

ex : `/-1123 play`

### record
This action is displaying in the owner's chat the camera value.

ex : `/-1123 record`

ex of output :

`/-1123 values <149.033564,126.035378,23.916243>|<0.010002,0.108740,-0.091046,0.989842>`

### values
This action sends the values to all the cameras in the chat range.

ex : `/-1123 values <149.033564,126.035378,23.916243>|<0.010002,0.108740,-0.091046,0.989842>`

### time
This actions changes the time for the camera to go from start point to end point.

ex : `/-1123 time 4`


### record
