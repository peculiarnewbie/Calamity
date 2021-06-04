using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStats : CharacterStats
{
    public int hazardDamage = 2;

    

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Hazard"))
            TakeDamage(hazardDamage);
        Debug.Log(currentHealth);

    }
}
