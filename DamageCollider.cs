using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageCollider : MonoBehaviour
{
    Collider damageCollider;

    public bool damagePlayer = true;
    public bool damageEnemy = true;
    public int weaponDamage = 2;

    private void Awake()
    {
        damageCollider = GetComponent<Collider>();
        damageCollider.gameObject.SetActive(true);
        damageCollider.isTrigger = true;
        damageCollider.enabled = false;
    }

    public void EnableDamageCollider()
    {
        damageCollider.enabled = true;
    }

    public void DisableDamageCollider()
    {
        damageCollider.enabled = false;
    }

    private void OnTriggerEnter(Collider collision)
    {
        if(damagePlayer && collision.tag == "Player")
        {
            PlayerStats playerStats = collision.GetComponent<PlayerStats>();

            if(playerStats != null)
            {
                playerStats.TakeDamage(weaponDamage);
            }
        }
        if (damageEnemy && collision.tag == "Enemy")
        {
            EnemyStats enemyStats = collision.GetComponent<EnemyStats>();

            if (enemyStats != null)
            {
                enemyStats.TakeDamage(weaponDamage);
            }
        }
    }
}
