using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterStats : MonoBehaviour
{
    public int maxHealth = 10;
    //public int currentHealth { get; private set; }
    public int currentHealth;

    public Stat damage;
    public Stat armor;

    public bool isAlive = true;

    public AnimatorHandler animatorHandler;

    private void Awake()
    {
        currentHealth = maxHealth;
        animatorHandler = GetComponent<AnimatorHandler>();
    }

    public void DoDamage(int damage)
    {
        damage -= armor.GetValue();
        damage = Mathf.Clamp(damage, 0, int.MaxValue);

        currentHealth -= damage;

        animatorHandler.PlayAnimationTrigger("Damage");

        if (currentHealth <= 0)
        {
            Die();
        }
    }

    public virtual void TakeDamage(int damage)
    {
        DoDamage(damage);
    }

    public virtual void Die()
    {
        Debug.Log(transform.name + "died.");
        isAlive = false;
        animatorHandler.PlayTargetAnimation("Death", true);
    }
}
