using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraTarget : MonoBehaviour
{
    public Transform playerTransform;
    private Transform targetTransform;
    private Vector3 targetPosition;
    private Vector3 tempPosition;
    public float snapTurnDegree = 30.0f;
    public float smoothSpeed = 0.1f;
    public float flexLevel = 3f;

    [SerializeField] private List<Transform> cameraTargets;
    private Transform activeCameraTarget;
    bool isSwitching = false;
    IEnumerator coroutine;

    // Start is called before the first frame update
    void Start()
    {
        XRCharacterController.current.OnFocus += FocusOnEnemy;
        XRCharacterController.current.OnSnapTurn += SnapTurn;
        RigPosition.instance.OnCameraStatic += MoveToStaticTarget;
        GameManager.instance.OnReset += ResetCameraTarget;
        targetTransform = playerTransform;
    }

    void AddCameraTargets(GameObject[] cameraTargetObjects)
    {
        if(cameraTargetObjects != null)
        {
            foreach (GameObject camera in cameraTargetObjects)
            {
                Transform cameraTransform = camera.transform;
                if(cameraTargets.Capacity == 0)
                {
                    Debug.Log("yo wtf" + camera);
                    cameraTargets.Add(cameraTransform);
                    continue;
                }
                for(int i = 0; i <= cameraTargets.Capacity-1; i++)
                {
                    Debug.Log("wut"+ i);
                    if (cameraTargets[i] == null)
                    {
                        Debug.Log("missing" + i);
                        cameraTargets[i] = cameraTransform;
                        break;
                    }
                    else if (!cameraTargets.Contains(cameraTransform))
                    {
                        cameraTargets.Add(cameraTransform);
                        break;
                    }
                }
            }
            activeCameraTarget = cameraTargets[0];
        }
    }

    void ResetCameraTarget()
    {
        cameraTargets.Clear();
        GameObject[] cameraTargetObjects = GameObject.FindGameObjectsWithTag("Camera Targets");
        AddCameraTargets(cameraTargetObjects);
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if(!isSwitching)
            targetPosition = targetTransform.position;
        Vector3 desiredPosition = targetPosition;
        float range = (desiredPosition - transform.position).magnitude;
        Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed * Mathf.Pow(range, 1/flexLevel));
        transform.position = smoothedPosition;
    }

    public void SnapTurn(bool toLeft)
    {
        if (toLeft)
            transform.Rotate(0.0f, -snapTurnDegree, 0.0f);
        else
            transform.Rotate(0.0f, snapTurnDegree, 0.0f);
    }

    public void MoveToStaticTarget(bool toTarget)
    {
        isSwitching = true;
        tempPosition = targetPosition;
        if (toTarget)
            targetTransform = activeCameraTarget;
        else
            targetTransform = playerTransform;
        coroutine = MoveCamera();
        StartCoroutine(coroutine);
    }

    private IEnumerator MoveCamera()
    {
        float transitionProgress = 0f;
        while (transitionProgress < 1)
        {
            //Debug.Log(transitionProgress);
            transitionProgress += 0.02f;
            targetPosition = Vector3.Lerp(tempPosition, targetTransform.position, transitionProgress);
            yield return new WaitForSeconds(0.02f);
        }
        isSwitching = false;
        yield return null;
    }

    public void FocusOnEnemy(GameObject focus, bool isEnemy)
    {
        if (!isEnemy)
            return;

        Vector3 lookPos = focus.transform.position - transform.position;
        lookPos.y = 0;
        Quaternion rotation = Quaternion.LookRotation(lookPos, new Vector3(0, 1, 0));
        transform.rotation = rotation;
        //transform.rotation = Quaternion.Slerp(transform.rotation, rotation, Time.deltaTime * focusDamping);
        //transform.LookAt(focus.transform, Vector3.up);
    }

   
}
