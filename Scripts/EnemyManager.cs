using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.AI;
using UnityEngine.Events;

public class EnemyManager : MonoBehaviour
{
    UnityEvent enemyDeathEvent;
    private int enemyHealth;
    private Animator enemyAnimator;
    private IEnumerator enemyDeathCoroutine;
    private bool isDamaged;

    public float lookRadius = 10f;

    Transform target;
    NavMeshAgent agent;

    private void Start()
    {
        target = PlayerManager.instance.player.transform;
        agent = GetComponent<NavMeshAgent>();
    }

    private void Update()
    {
        float distance = Vector3.Distance(target.position, transform.position);

        if(distance <= lookRadius)
        {
            agent.SetDestination(target.position);

            if(distance <= agent.stoppingDistance)
            {
                
                FaceTarget();
            }
        }
    }

    void FaceTarget()
    {
        Debug.Log("what");
        Vector3 direction = (target.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 5f);
    }

    private void EnemyDamaged()
    {
        if (!isDamaged)
        {
            enemyHealth--;
            if (enemyHealth <= 0)
            {
                EnemyDeath();
            }
            else
            {
                enemyAnimator.SetBool("Damaged", true);
            }
        }
        
    }

    private void EnemyDeath()
    {
        StartCoroutine(enemyDeathCoroutine);
        enemyDeathEvent.Invoke();
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, lookRadius);
    }



}
