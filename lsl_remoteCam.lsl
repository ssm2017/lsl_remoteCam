// original script by Jeff Kelley tarabiscoted par ssm2017 Binder :)

// =========
//  Strings
// =========
string _SCRIPT_STOPPED = "Script stopped";
string _WRONG_DIRECTOR = "The director is not here.";
string _CAMERA_RUNNING = "Camera running";
// =====
// Vars
// =====
integer GesturesChannel = -1123;
integer TIME_SELECTED = 4;
integer EASE_SELECTED = 0;
// ===========================================
//  NOTHING SHOULD BE CHANGED UNDER THIS LINE
// ===========================================
key director = NULL_KEY;
integer listener;
integer camIsOn = 0;

// ===========
//  Functions
// ===========
integer getDirector()
{
    director = (key)llGetObjectDesc();
    return (llGetAgentSize(director) != ZERO_VECTOR);
}

// ================
// Handling camera
// ================
key      CameraKey;     // Camera UUID (if exists)
vector   CameraPos;     // Camera current position
rotation CameraRot;     // Camera current rotation

moveCamTo (vector pos, vector focus)
{
    llSetCameraParams
    ([
        CAMERA_ACTIVE, 1,
        CAMERA_POSITION_LOCKED, TRUE,
        CAMERA_FOCUS_LOCKED, TRUE,
        CAMERA_POSITION, pos,
        CAMERA_FOCUS, focus
    ]);
}

setCameraAt(vector pos,rotation rot)
{
    vector avcam = pos + < 1,0,0 > * rot;
    vector focus = pos + < 2,0,0 > * rot;
    moveCamTo  (avcam, focus);
    CameraPos = pos;
    CameraRot = rot;
}

float getRatio(float x)
{
	if (EASE_SELECTED == 1) // easeInOutSinus
	{
		return 0.5 * (1 - llSin ((x+0.5)*PI));
	}
	else if (EASE_SELECTED == 2) // easeInOutQuadratic
	{
		if (x < 0.5)    return 2 * x*x;
    	else 			return 1 - 2 * (1-x)*(1-x);
	}
	else if (EASE_SELECTED == 3) // easeInOutQuartic
	{
		if (x < 0.5)    return 8 * x*x*x*x;
    	else            return 1 - 8 * (1-x)*(1-x)*(1-x)*(1-x);
	}
	else // easeInOutCubic
	{
		if (x < 0.5)    return 4 * x*x*x;
    	else            return 1 - 4 * (1-x)*(1-x)*(1-x);
	}
}

// Interpolates between two rotation values in a linear fashion
// http://wiki.secondlife.com/wiki/Interpolation/Linear/Rotation
rotation rLin(rotation x, rotation y, float t)
{
    float ang = llAngleBetween(x, y);
    if(ang > PI) ang -= TWO_PI;
    return x * llAxisAngle2Rot(llRot2Axis(y/x)*x, ang*t);
}

//
// Public methods 
//

Camera_Init (key uid, vector pos,rotation rot)
{
    CameraKey = uid;
    CameraPos = pos;
    CameraRot = rot;
}

Camera_Control(integer on)
{
    camIsOn = on;
    if (on) setCameraAt(CameraPos,CameraRot);
    else llClearCameraParams();
}

Camera_Dolly(vector pos,rotation rot,float dur)
{
    llSetColor(<1.0, 1.0, 0.0>, ALL_SIDES);
    float fps = 25;
    integer frames = llFloor(dur*fps);
    vector pos0   = CameraPos;
    rotation rot0 = CameraRot;
    integer i;
    for (i=0; i<=frames; i++)
    {
        float ratio = (float)i/frames;
        ratio = getRatio(ratio);
        vector   p = pos0 + (pos-pos0)*ratio;
        rotation r = rLin (rot0,rot,ratio);
        setCameraAt (p,r);
        llSleep (1.0/fps);
    }
    llSetColor(<0.0, 1.0, 0.0>, ALL_SIDES);
}

// =============
//  Main script
// =============

default
{
    state_entry()
    {
        // init the script
        llSetColor(<1.0, 1.0, 1.0>, ALL_SIDES);
        TIME_SELECTED = 4;
        EASE_SELECTED = 0;

        // get director from object's description
        if (getDirector())
        {
            llRequestPermissions(llGetOwner(), 
            PERMISSION_TRACK_CAMERA | PERMISSION_CONTROL_CAMERA);
        }
        else
        {
            llOwnerSay(_WRONG_DIRECTOR + "\n" + _SCRIPT_STOPPED);
        }
    }

    run_time_permissions(integer perms)
    {
        if (perms & PERMISSION_TRACK_CAMERA| PERMISSION_CONTROL_CAMERA)
        {
            Camera_Init(NULL_KEY, ZERO_VECTOR, ZERO_ROTATION );
            state wait;
        }
    }

    attach(key id)
    {
         llResetScript();
    }
}

// ==================
//  Wait for command
// ==================

state wait
{
    state_entry()
    {
        llSetColor(<1.0, 0.0, 0.0>, ALL_SIDES);
        listener =  llListen (GesturesChannel, "", director, "");
        llOwnerSay(_CAMERA_RUNNING);
    }

    listen (integer channel, string name, key id, string message)
    {
        if (id != director) return;
        if (channel == GesturesChannel)
        {
            list parsed = llParseString2List( message, [ " " ], [] );
            string command = llStringTrim(llToLower(llList2String( parsed, 0 )), STRING_TRIM);
            string value = llStringTrim(llList2String( parsed, 1 ), STRING_TRIM);

            if (command == "play")
            {
                Camera_Control(1);
                llSetColor(<0.0, 1.0, 0.0>, ALL_SIDES);
            }
            else if (command == "stop")
            {
                Camera_Control(0);
                llSetColor(<1.0, 0.0, 0.0>, ALL_SIDES);
            }
            else if (command == "record")
            {
                vector   pos = llGetCameraPos();
                rotation rot = llGetCameraRot();
                llOwnerSay("/"+(string)GesturesChannel+" values "+(string)pos+"|"+(string)rot);
            }
            else if (command == "values")
            {
                if (camIsOn)
                {
                    list parsed_value = llParseString2List( value, [ "|" ], [] );
                    vector pos = llList2Vector( parsed_value, 0 );
                    rotation rot = llList2Rot( parsed_value, 1 );
                    integer values_qty = llGetListLength(parsed_value);
                    Camera_Dolly (pos,rot, TIME_SELECTED);
                }
            }
            else if (command == "time")
            {
                TIME_SELECTED = (integer)value;
            }
            else if (command == "ease")
            {
                EASE_SELECTED = (integer)value;
            }
        }
    }

    attach(key id)
    {
         llResetScript();
    }
}