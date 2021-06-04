using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraTarget : MonoBehaviour
{
    public Transform playerTransform;
    public float snapTurnDegree = 30.0f;
    public float smoothSpeed = 0.1f;
    public float flexLevel = 3f;

    // Start is called before the first frame update
    void Start()
    {
        XRCharacterController.current.OnSnapTurn += SnapTurn;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Vector3 desiredPosition = playerTransform.position;
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
}
