using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RigPosition : MonoBehaviour
{
    public event Action<bool> OnCameraStatic;

    public Transform target;
    public Transform cameraPos;

    public float smoothSpeed = 0.2f;
    public float snapTurnDegree = 30.0f;
    float platformerSmooth = 0.05f;
    float battleSmooth = 0.3f;
    float focusDamping = 0.95f;
    bool cameraTurnActive = true;

    public Vector3 platformer_Offset;
    public Vector3 battle_Offset;
    public Vector3 static_Offset;
    Vector3 offset;
    Vector3 tempOffset;

    IEnumerator coroutine;

    public LayerMask ignoreLayers;

    public static RigPosition instance;

    public float lookSpeed = 0.1f;
    public float followSpeed = 0.1f;
    public float pivotSpeed = 0.03f;

    private Vector3 cameraTransformPosition;
    private float targetPosition;
    private float defaultPosition;
    private float lookAngle;
    private float pivotAngle;
    public float minimumPivot = -35;
    public float maximumPivot = 35;

    public float cameraSphereRadius = 0.2f;
    public float cameraCollisionOffset = 0.2f;
    public float minimumCollisionOffset = 0.2f;

    private void Awake()
    {
        instance = this;
        ignoreLayers = ~(1 << 8 | 1 << 9 | 1 << 10);
        defaultPosition = transform.localPosition.z;
    }

    private void Start()
    {
        offset = platformer_Offset;
        target = GameObject.FindGameObjectWithTag("Player").transform;
        SwitchCameraMode(0);
    }

    public void FollowTarget(float delta)
    {
        Vector3 targetPosition = Vector3.Lerp(transform.position, target.position, smoothSpeed * delta);
        transform.position = targetPosition;
    }

    public void HandleCameraCollisions(float delta)
    {
        targetPosition = defaultPosition;
        RaycastHit hit;

        if(Physics.SphereCast
            (transform.position, cameraSphereRadius, transform.forward, out hit, Mathf.Abs(targetPosition), ignoreLayers))
        {
            float dis = Vector3.Distance(transform.position, hit.point);
            targetPosition = -(dis - cameraCollisionOffset);
            Debug.Log("camera collided");
        }

        if(Mathf.Abs(targetPosition) < minimumCollisionOffset)
        {
            targetPosition = -minimumCollisionOffset;
        }

        cameraTransformPosition.z = Mathf.Lerp(transform.localPosition.z, targetPosition, delta / 0.2f) + 1;
        transform.localPosition = cameraTransformPosition;
    }

    private void FixedUpdate()
    {
        Vector3 desiredPosition = target.position;
        float range = (desiredPosition - transform.position).magnitude;
        Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed*range);
        transform.LookAt(cameraPos, Vector3.up);
        
        if (cameraTurnActive)
        {
            transform.localPosition = offset;
        }
        else
        {
            transform.localPosition = offset;
        }

        float delta = Time.fixedDeltaTime;

        //HandleCameraCollisions(delta);
    }

    public void SwitchCameraMode(int mode)
    {
        tempOffset = offset;
        switch (mode)
        {
            case 0:
                coroutine = SmoothSwitch(platformer_Offset);
                smoothSpeed = platformerSmooth;
                OnCameraStatic?.Invoke(false);
                break;
            case 1:
                coroutine = SmoothSwitch(battle_Offset);
                smoothSpeed = battleSmooth;
                break;
            case 2:
                coroutine = SmoothSwitch(static_Offset);
                OnCameraStatic?.Invoke(true);
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

    

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, cameraSphereRadius);
    }
}
