using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum Indicator { Start, Platformer, Combat, Time };

public class TriggerList : MonoBehaviour
{
    [SerializeField] private Indicator type;
    [SerializeField] private int level = 1;
    [SerializeField] private bool setInactive;

    public event Action OnTimeCollect;
    public event Action<Indicator> OnLevelTrigger;

    private void OnTriggerEnter(Collider collider)
    {
        if (type == Indicator.Time)
            OnTimeCollect?.Invoke();

        else
            GameManager.instance.LoadLevel((int)type);

        if (setInactive)
        {
            gameObject.SetActive(false);
        }
    }
}
