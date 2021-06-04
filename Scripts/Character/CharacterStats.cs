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

    public bool ableToMove = true;

    public AnimatorHandler animatorHandler;

    private void Awake()
    {
        currentHealth = maxHealth;
        animatorHandler = GetComponent<AnimatorHandler>();
    }

    public void TakeDamage(int damage)
    {
        damage -= armor.GetValue();
        damage = Mathf.Clamp(damage, 0, int.MaxValue);

        currentHealth -= damage;

        animatorHandler.PlayTargetAnimation("Damaged", true);

        if (currentHealth <= 0)
        {
            Die();
        }
    }

    public virtual void Die()
    {
        Debug.Log(transform.name + "died.");
        ableToMove = false;
        animatorHandler.PlayTargetAnimation("Death", true);
    }
}
