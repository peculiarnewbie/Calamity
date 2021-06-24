using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModeChange : MonoBehaviour
{
    int platformerMode = 0;
    int battleMode = 1;
    int puzzleMode = 2;
    int howManyModes = 3;

    int mode = 0;

    public int ChangeMode()
    {
        mode += 1;
        mode %=  howManyModes;

        RigPosition.instance.SwitchCameraMode(mode);

        return mode;
    }

}
