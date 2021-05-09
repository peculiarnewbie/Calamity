using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TrashObject : MonoBehaviour
{
    public GameObject handleObject;
    [SerializeField] TrashController tController;
    [SerializeField] string trashString = "defaultTrash";
    [SerializeField] Text trashText;

    Renderer rend;

    private FadeToBlack fade;
    private bool isPickedUp = false;
    private bool dissolvingBool = false;
    private float dissolveSpeed = 2f;

    
    private XRIDefaultInputActions xriInput;
    private void OnEnable()
    {
        xriInput.Enable();
    }

    private void OnDisable()
    {
        xriInput.Disable();
    }

    private void Awake()
    {
        xriInput = new XRIDefaultInputActions();
    }

    // Start is called before the first frame update
    void Start()
    {
        rend = GetComponent<Renderer>();
        fade = GameObject.Find("TrashHUD").GetComponent<FadeToBlack>();
    }

    // Update is called once per frame
    void Update()
    {
        //if (isPickedUp)
        //{
        //    Debug.Log("gas");
        //    transform.position = handleObject.transform.position;
            
        //}
    }

    private void OnCollisionEnter(Collision collision)
    {
        
    }

    private void OnTriggerStay(Collider other)
    {
        
        if(other.tag == "handle" && xriInput.XRIRightHand.Activate.triggered)
        {
            Debug.Log("kena");
            handleObject = other.gameObject;
            isPickedUp = true;
            trashText.text = trashString;
            fade.FadeMe();
            transform.position = handleObject.transform.position;
            gameObject.GetComponent<Transform>().SetParent(handleObject.transform);
            if (!dissolvingBool)
            {
                StartCoroutine("Dissolve");
                dissolvingBool = true;
            }
            tController.DecreaseTrash();
        }
    }

    IEnumerator Dissolve()
    {
        
        yield return new WaitForSeconds(1.5f);
        float dissolveLevel = 1f;
        while (dissolveLevel > -1f)
        {
            //Debug.Log(dissolveLevel);
            dissolveLevel -= dissolveSpeed * Time.deltaTime;
            rend.material.SetFloat("_CutoffHeight", dissolveLevel);
            rend.materials[1].SetFloat("_CutoffHeight", dissolveLevel);
            yield return new WaitForSeconds(0.01f);
        }
        fade.FadeOn();
        this.gameObject.SetActive(false);
        yield return null;
    }
}
