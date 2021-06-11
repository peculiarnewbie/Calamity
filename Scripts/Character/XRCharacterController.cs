using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;
using UnityEngine.InputSystem;
using UnityEngine.Events;
using UnityEngine.AI;

public class XRCharacterController : MonoBehaviour
{
    
    public event Action<bool> OnSnapTurn; //true is left, false is right

    public event Action<GameObject, bool> OnFocus;

    public AnimatorHandler animatorHandler;

    [Space(10)]

    // Input values
    [SerializeField] private float playerSpeed = 5.0f;
    [SerializeField] private float gravity = -9.81f;
    [SerializeField] private float jumpHeight = 2.0f;
    [SerializeField] private float doubleJumpMultiplier = 0.7f;
    [SerializeField] private float fallMultiplier = 1.5f;
    [SerializeField] private GameObject testEnemy;

    [Space(10)]

    // Values
    private Vector3 currentDirection = Vector3.zero;
    private bool jumpTrigger = false;
    private bool isFocusing = false;
    private bool canDoubleJump = true;
    private Vector3 verticalVelocity;
    private Vector3 currentMovement;
    private bool resetTrigger = false;
    private bool switchTrigger = false;
    private int movementMode;
    private bool isSnapTurning = false; //true if the player snap turns
    private PlayerStats playerStats;

    // Ground & Air Detection
    public bool isInAir;
    private bool isGrounded;
    [SerializeField] float groundDetectionRayStartPoint = 0.5f;
    [SerializeField] float minimumDistanceToFall = 0.5f;
    [SerializeField] float groundDirectionRayDistance = 0.2f;
    LayerMask ignoreForGroundCheck;
    public float inAirTimer;


    // Input Actions
    private PlayerActions playerActions;

    // References
    public Transform head = null;
    public Transform mesh = null;
    public ActionBasedController controller = null;
    public GameManager gameManager;
    public ModeChange modeChange;
    public Transform raySource;

    public Interactable focus;

    [Space(10)]

    // Components

    //Events
    public UnityEvent snapTurnEventLeft;
    public UnityEvent snapTurnEventRight;
    //public EnemyEvent focusOnEnemyEvent;

    public static XRCharacterController current;

    private void Awake()
    {
        current = this;
        // Collect components
        playerActions = new PlayerActions();
        modeChange = GetComponent<ModeChange>();
        animatorHandler = GetComponent<AnimatorHandler>();
        animatorHandler.Initialize();
        playerStats = GetComponent<PlayerStats>();

        isGrounded = true;
        ignoreForGroundCheck = LayerMask.GetMask("Default");
    }

    private void OnEnable()
    {
        playerActions.Enable();
        playerActions.Land.Jump.started += ctx => jumpTrigger = true;
        playerActions.Land.Reset.started += ctx => resetTrigger = true;
        playerActions.Land.Switch.started += ctx => switchTrigger = true;
        playerActions.Land.Attack.started += ctx => animatorHandler.PlayAnimationTrigger("Attack");
        playerActions.Land.Focus.started += ctx => isFocusing = !isFocusing;
    }

    private void OnDisable()
    {
        playerActions.Disable();
    }


    void Update()
    {
        if (playerStats.ableToMove)
        {
            CheckForModeChange();

            CheckForMovement();

            OrientMesh();

            AnimateCharacter();

            CheckForInteractions();
        }
        else
        {
            currentDirection = Vector3.zero;
        }
    }

    private void FixedUpdate()
    {
        MoveCharacter();
    }

    private void CheckGrounded()
    {
        if (isInAir)
        {
            inAirTimer += Time.deltaTime;
        }
    }

    private void HandleFalling()
    {
        isGrounded = false;
        RaycastHit hit;
        Vector3 origin = transform.position;
        origin.y += groundDetectionRayStartPoint;

        if(Physics.Raycast(origin, transform.forward, out hit, 0.4f))
        {

        }


        Debug.DrawRay(origin, -Vector3.up * minimumDistanceToFall, Color.red, 0.1f, false);
        if(Physics.Raycast(origin, -Vector3.up, out hit, minimumDistanceToFall, ignoreForGroundCheck))
        {
            Vector3 tp = hit.point;
            isGrounded = true;

            canDoubleJump = true;
            animatorHandler.PlayTargetAnimation("Jump", false);
            //animator.SetBool("Jump", false);

            if (hit.distance < minimumDistanceToFall - 0.1f)
            {
                transform.Translate(Vector3.up*0.2f);
                Debug.Log("tenggelam bro");
                verticalVelocity.y = 0;
            }
            else if (verticalVelocity.y < 0)
            {
                Debug.Log("shouldn't bro");
                verticalVelocity.y = 0;
            }

            if (isInAir)
            {
                if(inAirTimer > 0.5f)
                {
                    Debug.Log("in air for" + inAirTimer);
                }
                else
                {
                    
                }

                inAirTimer = 0;
                isInAir = false;
            }
        }
        else
        {
            if (isGrounded)
                isGrounded = false;
            if (!isInAir)
            {
                Debug.Log("is falling");
                isInAir = true;
            }
            if (verticalVelocity.y < 0)
                verticalVelocity.y += gravity * fallMultiplier * Time.deltaTime;
            else
                verticalVelocity.y += gravity * Time.deltaTime;
        }
        transform.Translate(verticalVelocity * Time.deltaTime);
        //character.Move(verticalVelocity * Time.deltaTime);

    }

    private void HandleJump() { 
    }


    private void CheckForModeChange()
    {
        if (switchTrigger)
        {
            switchTrigger = false;
            movementMode = modeChange.ChangeMode();
        }
    }

    private void CheckForMovement()
    {
        float rotateInput = playerActions.Land.Look.ReadValue<float>();

        HandleSnapTurning(rotateInput);

        Vector2 movementInput = playerActions.Land.Move.ReadValue<Vector2>();
        Vector3 newDirection = new Vector3(movementInput.x, 0, movementInput.y);
        Vector3 headRotation = new Vector3(0, head.transform.eulerAngles.y, 0);

        currentDirection = Quaternion.Euler(headRotation) * newDirection;

        if (currentDirection.magnitude > 0.1f)
        {
            //animator.SetBool("Walking", true);
            animatorHandler.PlayTargetAnimation("Walking", true);
        }
        else
        {
            //animator.SetBool("Walking", false);
            animatorHandler.PlayTargetAnimation("Walking", false);
        }
        if (resetTrigger)
        {
            gameManager.LoadLevel(0);
        }

    }


    private void MoveCharacter()
    {
        //isGrounded = character.isGrounded;

        //Debug.Log(isGrounded);

        //GroundCheck
        //if (character.isGrounded && verticalVelocity.y < 0)
        //{
        //    verticalVelocity.y = -0.1f;
        //    canDoubleJump = true;
        //    //animator.SetBool("Jump", false);
        //    animatorHandler.PlayTargetAnimation("Jump", false);
        //}
        

        //Movement
        Vector3 movement = currentDirection * playerSpeed * Time.deltaTime;
        float range = (movement - currentMovement).magnitude;
        Vector3 smoothMovement;
        if (isGrounded)
        {
            if (movement == Vector3.zero)
                smoothMovement = Vector3.Lerp(currentMovement, movement, 0.95f * Mathf.Pow(range, 0.2f));
            else
                smoothMovement = Vector3.Lerp(currentMovement, movement, 0.95f * Mathf.Pow(range, 0.5f));
        }
        else
            smoothMovement = Vector3.Lerp(currentMovement, movement, 0.4f * Mathf.Pow(range, 0.8f));

        Debug.DrawRay(raySource.position, smoothMovement.normalized, Color.red, 0.1f, false);
        bool doTranslate = Physics.Raycast(raySource.position,smoothMovement, 1f, ignoreForGroundCheck);
        if (!doTranslate)
        {
            transform.Translate(-smoothMovement);
            Debug.Log("no obstruction sire");
        }
        //character.Move(smoothMovement);
        currentMovement = smoothMovement;
            

        //Jump
        if (jumpTrigger)
        {
            jumpTrigger = false;
            if (isGrounded)
            {
                verticalVelocity.y = Mathf.Sqrt(jumpHeight * -gravity);
                animatorHandler.PlayTargetAnimation("Jump", true);
            }
                
            else if (canDoubleJump)
            {
                verticalVelocity.y = Mathf.Sqrt(jumpHeight * doubleJumpMultiplier * -gravity);
                canDoubleJump = false;
            }
        }

        HandleFalling();

    }

    private void OrientMesh()
    {
        // Set the direction the charactre should look, only with input
        if (currentDirection != Vector3.zero)
            if (movementMode == 0)
                mesh.transform.forward = currentDirection;
            else if (movementMode == 1)
                mesh.transform.forward = head.transform.forward;
    }

    private void AnimateCharacter()
    {

    }

    private void CheckForInteractions()
    {
        Interactable newFocus = testEnemy.GetComponent<Interactable>();

        if(newFocus != null)
        {
            if(newFocus != focus)
            {
                focus.OnDefocused();
                focus = newFocus;
            }
            focus = newFocus;
        }

        if(isFocusing)
            OnFocus?.Invoke(focus.gameObject, true);
    }

    private void HandleSnapTurning(float rotateInput)
    {
        if (!isSnapTurning)
        {
            if (rotateInput < -0.9)
            {
                OnSnapTurn?.Invoke(true);
                isSnapTurning = true;
            }
            else if (rotateInput > 0.9)
            {
                OnSnapTurn?.Invoke(false);
                isSnapTurning = true;
            }
        }
        else if (rotateInput > -0.3 && rotateInput < 0.3)
        {
            isSnapTurning = false;
        }
    }

}

