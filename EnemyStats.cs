using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyStats : CharacterStats
{
    

    public override void Die()
    {
        isAlive = false;
        animatorHandler.PlayAnimationTrigger("Death");
        StartCoroutine("Death");
    }

    IEnumerator Death()
    {
        yield return new WaitForSeconds(3f);
        this.gameObject.SetActive(false);
        yield return null;
    }

}
