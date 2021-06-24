using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.AI;
using UnityEngine.Events;

public class EnemyManager : MonoBehaviour
{
    private AnimatorHandler enemyAnimator;
    private EnemyStats enemyStats;
    private bool isDamaged;
    private bool onWalkPoint = false;

    public LayerMask whatIsGround, whatIsPlayer;

    Transform target;
    NavMeshAgent agent;

    //walk point
    public Vector3 walkPoint;
    public bool walkPointSet;
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
        enemyStats = GetComponent<EnemyStats>();
    }

    private void Update()
    {
        if (!enemyStats.isAlive)
            return;

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

        if (distanceToWalkPoint.magnitude < 1f && !onWalkPoint)
        {
            Invoke("ResetWalkPoint", 2.0f);
            onWalkPoint = true;
        }

        enemyAnimator.PlayTargetAnimation("Moving", true);
    }

    private void SearchWalkPoint()
    {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);

        walkPoint = new Vector3(transform.position.x + randomX, transform.position.y, transform.position.z + randomZ);

        
        if (Physics.Raycast(walkPoint, -transform.up, 2f, whatIsGround))
        {
            walkPointSet = true;
            Debug.DrawRay(walkPoint, -transform.up * 2f, Color.red, 0.5f, false);
        }
    }

    private void ChasePlayer()
    {
        FaceTarget();
        agent.SetDestination(target.position);
        enemyAnimator.PlayTargetAnimation("Moving",true);
    }

    private void AttackPlayer()
    {
        agent.SetDestination(transform.position);
        enemyAnimator.PlayTargetAnimation("Moving", false);
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

    private void ResetWalkPoint()
    {
        walkPointSet = false;
        onWalkPoint = false;
    }

    void FaceTarget()
    {
        Vector3 direction = (target.position - transform.position).normalized;
        Quaternion lookRotation = Quaternion.LookRotation(new Vector3(direction.x, 0, direction.z));
        transform.rotation = Quaternion.Slerp(transform.rotation, lookRotation, Time.deltaTime * 5f);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, sightRange);
    }
}
