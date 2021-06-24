using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStats : CharacterStats
{
    public int hazardDamage = 2;
    private bool isTakingDamage = false;
    public bool canMove = true;

    public override void TakeDamage(int damage)
    {
        if (!isTakingDamage)
        {
            isTakingDamage = true;
            canMove = false;
            DoDamage(damage);
            StartCoroutine(WaitAfterDamage());
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Hazard"))
            TakeDamage(hazardDamage);
        Debug.Log(currentHealth);
    }

    IEnumerator WaitAfterDamage()
    {
        yield return new WaitForSeconds(1.0f);
        canMove = true;
        yield return new WaitForSeconds(1.0f);
        isTakingDamage = false;
        yield return null;
    }
}
