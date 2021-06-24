// GENERATED AUTOMATICALLY FROM 'Assets/Scripts/Character/PlayerControls.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @PlayerActions : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @PlayerActions()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""PlayerControls"",
    ""maps"": [
        {
            ""name"": ""Land"",
            ""id"": ""8acfb9f0-24b3-4fd1-9604-0a8821b686b2"",
            ""actions"": [
                {
                    ""name"": ""Move"",
                    ""type"": ""Value"",
                    ""id"": ""5eed3fec-186e-43b4-a117-1d5f3593c106"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Attack"",
                    ""type"": ""Button"",
                    ""id"": ""d1f6639a-47bb-4734-9a2e-11ccb3a93872"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Look"",
                    ""type"": ""Value"",
                    ""id"": ""2e8866ee-81b3-4292-87f1-d3389af468ef"",
                    ""expectedControlType"": ""Axis"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""EnableLook"",
                    ""type"": ""Button"",
                    ""id"": ""4e711ad5-1ec6-489b-b8f3-4efb5f61d3a6"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Jump"",
                    ""type"": ""Button"",
                    ""id"": ""37df42d1-ec9a-4a11-88a0-bcd3a73389f4"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Reset"",
                    ""type"": ""Button"",
                    ""id"": ""31af39ce-e12e-4c49-8dc5-0b9ad2c167c8"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Switch"",
                    ""type"": ""Button"",
                    ""id"": ""813b4d83-9a4b-41af-b012-c18a2e791a66"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Focus"",
                    ""type"": ""Button"",
                    ""id"": ""e9b117d4-d7f2-4b35-ab18-af34809b4697"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""WASD"",
                    ""id"": ""3b6555b5-4b4c-478c-9dd3-15a53e65894d"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""358363d1-ecf6-4d8e-ab00-e999c4a72ffc"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""89677f4b-009f-41ea-aee2-3044ae86d6e3"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""53729623-97a9-44e9-b28c-7196151db74d"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""777dc61d-07de-4da5-b9b5-82dcaa2c1e97"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""bfd5e9a7-1e1c-432d-9bdc-efd1f1f2909d"",
                    ""path"": ""<Gamepad>/leftStick"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""bf00244a-5b5d-4d40-86ca-76effc653b9b"",
                    ""path"": ""<Mouse>/leftButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Attack"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""d5032dcb-4f94-4b12-84bd-2e0215d99730"",
                    ""path"": ""<Gamepad>/buttonWest"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Attack"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""0f9797c8-cfc4-4093-b44f-700a4287354c"",
                    ""path"": ""<Gamepad>/rightStick/x"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""Arrow"",
                    ""id"": ""ff42e5c9-f478-4502-8a5d-26500c63415a"",
                    ""path"": ""1DAxis"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""negative"",
                    ""id"": ""8422fba4-07be-4327-b879-54cbfac78bef"",
                    ""path"": ""<Keyboard>/leftArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""positive"",
                    ""id"": ""66c08380-8a16-43cb-b0f7-c62faa043dfe"",
                    ""path"": ""<Keyboard>/rightArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""ce1728e8-1a87-40a0-bca0-3247b8d338df"",
                    ""path"": ""<Keyboard>/leftAlt"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""EnableLook"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""127ad6e8-d924-4a3a-a2b0-944586323e49"",
                    ""path"": ""<Keyboard>/space"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""f2bd1356-22f5-488e-a9cf-f9b99fbb5910"",
                    ""path"": ""<Gamepad>/buttonSouth"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""235a7470-85d6-4ce7-8b24-7b2a20860c5b"",
                    ""path"": ""<Keyboard>/r"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Reset"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""86ae59ac-6e5a-49e5-8108-86e35d9cec44"",
                    ""path"": ""<Keyboard>/f"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Switch"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""b6ab8fce-71c5-4e58-a56a-01834db8dfc3"",
                    ""path"": ""<Gamepad>/buttonNorth"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Switch"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""b34dcc25-aded-4ec3-af20-2dceb6a71aa2"",
                    ""path"": ""<Keyboard>/e"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Focus"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""a28ba05e-9555-4a68-a881-c58b65daa468"",
                    ""path"": ""<Gamepad>/leftShoulder"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Focus"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // Land
        m_Land = asset.FindActionMap("Land", throwIfNotFound: true);
        m_Land_Move = m_Land.FindAction("Move", throwIfNotFound: true);
        m_Land_Attack = m_Land.FindAction("Attack", throwIfNotFound: true);
        m_Land_Look = m_Land.FindAction("Look", throwIfNotFound: true);
        m_Land_EnableLook = m_Land.FindAction("EnableLook", throwIfNotFound: true);
        m_Land_Jump = m_Land.FindAction("Jump", throwIfNotFound: true);
        m_Land_Reset = m_Land.FindAction("Reset", throwIfNotFound: true);
        m_Land_Switch = m_Land.FindAction("Switch", throwIfNotFound: true);
        m_Land_Focus = m_Land.FindAction("Focus", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // Land
    private readonly InputActionMap m_Land;
    private ILandActions m_LandActionsCallbackInterface;
    private readonly InputAction m_Land_Move;
    private readonly InputAction m_Land_Attack;
    private readonly InputAction m_Land_Look;
    private readonly InputAction m_Land_EnableLook;
    private readonly InputAction m_Land_Jump;
    private readonly InputAction m_Land_Reset;
    private readonly InputAction m_Land_Switch;
    private readonly InputAction m_Land_Focus;
    public struct LandActions
    {
        private @PlayerActions m_Wrapper;
        public LandActions(@PlayerActions wrapper) { m_Wrapper = wrapper; }
        public InputAction @Move => m_Wrapper.m_Land_Move;
        public InputAction @Attack => m_Wrapper.m_Land_Attack;
        public InputAction @Look => m_Wrapper.m_Land_Look;
        public InputAction @EnableLook => m_Wrapper.m_Land_EnableLook;
        public InputAction @Jump => m_Wrapper.m_Land_Jump;
        public InputAction @Reset => m_Wrapper.m_Land_Reset;
        public InputAction @Switch => m_Wrapper.m_Land_Switch;
        public InputAction @Focus => m_Wrapper.m_Land_Focus;
        public InputActionMap Get() { return m_Wrapper.m_Land; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(LandActions set) { return set.Get(); }
        public void SetCallbacks(ILandActions instance)
        {
            if (m_Wrapper.m_LandActionsCallbackInterface != null)
            {
                @Move.started -= m_Wrapper.m_LandActionsCallbackInterface.OnMove;
                @Move.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnMove;
                @Move.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnMove;
                @Attack.started -= m_Wrapper.m_LandActionsCallbackInterface.OnAttack;
                @Attack.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnAttack;
                @Attack.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnAttack;
                @Look.started -= m_Wrapper.m_LandActionsCallbackInterface.OnLook;
                @Look.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnLook;
                @Look.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnLook;
                @EnableLook.started -= m_Wrapper.m_LandActionsCallbackInterface.OnEnableLook;
                @EnableLook.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnEnableLook;
                @EnableLook.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnEnableLook;
                @Jump.started -= m_Wrapper.m_LandActionsCallbackInterface.OnJump;
                @Jump.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnJump;
                @Jump.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnJump;
                @Reset.started -= m_Wrapper.m_LandActionsCallbackInterface.OnReset;
                @Reset.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnReset;
                @Reset.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnReset;
                @Switch.started -= m_Wrapper.m_LandActionsCallbackInterface.OnSwitch;
                @Switch.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnSwitch;
                @Switch.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnSwitch;
                @Focus.started -= m_Wrapper.m_LandActionsCallbackInterface.OnFocus;
                @Focus.performed -= m_Wrapper.m_LandActionsCallbackInterface.OnFocus;
                @Focus.canceled -= m_Wrapper.m_LandActionsCallbackInterface.OnFocus;
            }
            m_Wrapper.m_LandActionsCallbackInterface = instance;
            if (instance != null)
            {
                @Move.started += instance.OnMove;
                @Move.performed += instance.OnMove;
                @Move.canceled += instance.OnMove;
                @Attack.started += instance.OnAttack;
                @Attack.performed += instance.OnAttack;
                @Attack.canceled += instance.OnAttack;
                @Look.started += instance.OnLook;
                @Look.performed += instance.OnLook;
                @Look.canceled += instance.OnLook;
                @EnableLook.started += instance.OnEnableLook;
                @EnableLook.performed += instance.OnEnableLook;
                @EnableLook.canceled += instance.OnEnableLook;
                @Jump.started += instance.OnJump;
                @Jump.performed += instance.OnJump;
                @Jump.canceled += instance.OnJump;
                @Reset.started += instance.OnReset;
                @Reset.performed += instance.OnReset;
                @Reset.canceled += instance.OnReset;
                @Switch.started += instance.OnSwitch;
                @Switch.performed += instance.OnSwitch;
                @Switch.canceled += instance.OnSwitch;
                @Focus.started += instance.OnFocus;
                @Focus.performed += instance.OnFocus;
                @Focus.canceled += instance.OnFocus;
            }
        }
    }
    public LandActions @Land => new LandActions(this);
    public interface ILandActions
    {
        void OnMove(InputAction.CallbackContext context);
        void OnAttack(InputAction.CallbackContext context);
        void OnLook(InputAction.CallbackContext context);
        void OnEnableLook(InputAction.CallbackContext context);
        void OnJump(InputAction.CallbackContext context);
        void OnReset(InputAction.CallbackContext context);
        void OnSwitch(InputAction.CallbackContext context);
        void OnFocus(InputAction.CallbackContext context);
    }
}
