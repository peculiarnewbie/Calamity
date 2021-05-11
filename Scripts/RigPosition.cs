using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RigPosition : MonoBehaviour
{
    public Transform target;
    public Transform cameraPos;

    public float smoothSpeed = 0.2f;
    public float snapTurnDegree = 30.0f;
    float platformerSmooth = 0.05f;
    float battleSmooth = 0.3f;
    float focusDamping = 0.8f;
    bool cameraTurnActive = true;

    public Vector3 platformer_Offset;
    public Vector3 battle_Offset;
    Vector3 offset;
    Vector3 tempOffset;

    IEnumerator coroutine;

    private void Start()
    {
        XRCharacterController.current.OnFocus += FocusOnEnemy;
        XRCharacterController.current.OnSnapTurn += SnapTurn;

        SwitchCameraMode(0);
    }

    private void FixedUpdate()
    {
        Vector3 desiredPosition = target.position;
        float range = (desiredPosition - transform.position).magnitude;
        Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed*range);
        transform.position = smoothedPosition;
        transform.LookAt(cameraPos, Vector3.up);
        
        if (cameraTurnActive)
        {
            transform.position = smoothedPosition - transform.forward * 5f;
        }
    }

    public void SwitchCameraMode(int mode)
    {
        tempOffset = offset;
        switch (mode)
        {
            case 0:

                coroutine = SmoothSwitch(platformer_Offset);
                smoothSpeed = platformerSmooth;
                break;
            case 1:

                coroutine = SmoothSwitch(battle_Offset);
                smoothSpeed = battleSmooth;
                break;
            case 2:
                coroutine = SmoothSwitch(new Vector3(0, 0, 0));
                break;
            default:
                break;
        }
        StartCoroutine(coroutine);
    }

    private IEnumerator SmoothSwitch(Vector3 targetPosition)
    {
        float transitionProgress = 0f;
        while (transitionProgress < 1)
        {
            //Debug.Log(transitionProgress);
            transitionProgress += 0.02f;
            offset = Vector3.Lerp(tempOffset, targetPosition, transitionProgress);
            yield return new WaitForSeconds(0.02f);
        }
        yield return null;
    }

    public void SnapTurn(bool toLeft)
    {
        if(toLeft)
            transform.Rotate(0.0f, snapTurnDegree, 0.0f);
        else
            transform.Rotate(0.0f, -snapTurnDegree, 0.0f);
    }

    public void FocusOnEnemy(GameObject Enemy)
    {
        Vector3 lookPos = Enemy.transform.position - transform.position;
        lookPos.y = transform.position.y;
        Quaternion rotation = Quaternion.LookRotation(lookPos);
        transform.rotation = Quaternion.Slerp(transform.rotation, rotation, Time.deltaTime * focusDamping);
        transform.LookAt(Enemy.transform, Vector3.up);
    }
}
