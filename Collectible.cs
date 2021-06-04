using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Collectible : MonoBehaviour
{
    // Start is called before the first frame update
    
    private void OnTriggerEnter(Collider collider)
    {
        Debug.Log("pick up");
        Destroy(this.gameObject);
       
    }
}
