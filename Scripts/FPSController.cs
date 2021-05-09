using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSController : MonoBehaviour
{
    [SerializeField] Transform playerCamera = null;

    [SerializeField] private float mouseSensitivity = 0.5f;
    [SerializeField] private bool enableMouseAndKeyboard = true;
    float cameraPitch = 0.0f;

    private PlayerActions playerActions;



    // Enable/Disable Control actions
    private void OnEnable()
    {
        playerActions.Enable();
    }

    private void OnDisable()
    {
        playerActions.Disable();
    }

    private void Awake()
    {
        playerActions = new PlayerActions();
    }
    // Start is called before the first frame update

    // Update is called once per frame
    void Update()
    {
        float enableMouseLook = playerActions.Land.EnableLook.ReadValue < float>();
        bool mouseLookEnabled = false;
        if (enableMouseLook > 0.95f)
        {
            mouseLookEnabled = true;
        }
        
        if(enableMouseAndKeyboard && mouseLookEnabled)
            UpdateMouseLook();
    }

    void UpdateMouseLook()
    {
        Vector2 lookInput = playerActions.Land.Look.ReadValue<Vector2>();

        cameraPitch -= lookInput.y;
        cameraPitch = Mathf.Clamp(cameraPitch, -90.0f, 90.0f);
        //Debug.Log(cameraPitch);

        playerCamera.localEulerAngles = Vector3.right * cameraPitch;
        transform.Rotate(Vector3.up * lookInput.x * mouseSensitivity);
    }
}
