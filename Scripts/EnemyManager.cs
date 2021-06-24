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
    private AnimatorHandler enemyAnimator;
    private IEnumerator enemyDeathCoroutine;
    private bool isDamaged;

    public LayerMask whatIsGround, whatIsPlayer;

    Transform target;
    NavMeshAgent agent;

    //walk point
    public Vector3 walkPoint;
    bool walkPointSet;
    public float walkPointRange;

    //Attacking
    public float timeBetweenAttacks;
    bool alreadyAttacked;

    //Ranges
    public float sightRange = 10f;
    public float attackRange = 5f;
    public bool targetInSightRange, targetInAttackRange;

    private void Start()
    {
        target = PlayerManager.instance.player.transform;
        agent = GetComponent<NavMeshAgent>();
        enemyAnimator = GetComponent<AnimatorHandler>();
        enemyAnimator.Initialize();
    }

    private void Update()
    {
        float distance = Vector3.Distance(target.position, transform.position);

        if(distance <= sightRange)
        {
            agent.SetDestination(target.position);

            if(distance <= agent.stoppingDistance)
            {
                
                FaceTarget();
            }
        }

        //Check for sight and attack range
        targetInSightRange = Physics.CheckSphere(transform.position, sightRange, whatIsPlayer);
        targetInAttackRange = Physics.CheckSphere(transform.position, attackRange, whatIsPlayer);

        if (targetInSightRange)
        {
            if (targetInAttackRange) 
                AttackPlayer();
            else 
                ChasePlayer();
        }
        else 
            Patroling();
    }

    private void Patroling()
    {
        if (!walkPointSet) 
            SearchWalkPoint();
        else 
            agent.SetDestination(walkPoint);

        Vector3 distanceToWalkPoint = transform.position - walkPoint;

        if (distanceToWalkPoint.magnitude < 1f)
            walkPointSet = false;

    }

    private void SearchWalkPoint()
    {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);

        walkPoint = new Vector3(transform.position.x + randomX, transform.position.y, transform.position.z + randomZ);

        if (Physics.Raycast(walkPoint, -transform.up, 2f, whatIsGround))
            walkPointSet = true;
    }

    private void ChasePlayer()
    {
        agent.SetDestination(target.position);
    }

    private void AttackPlayer()
    {
        agent.SetDestination(transform.position);
        FaceTarget();

        if (!alreadyAttacked)
        {
            enemyAnimator.PlayAnimationTrigger("Attack");
            Debug.Log("attacking");

            alreadyAttacked = true;
            Invoke(nameof(ResetAttack), timeBetweenAttacks);
        }

    }

    private void ResetAttack()
    {
        alreadyAttacked = false;
    }

    void FaceTarget()
    {
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
                enemyAnimator.PlayAnimationTrigger("Damaged");
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
        Gizmos.DrawWireSphere(transform.position, sightRange);
    }



}
