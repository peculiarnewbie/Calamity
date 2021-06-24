using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ResearchData", menuName = "ScriptableObjects/ResearchData", order = 1)]
public class ResearchData : ScriptableObject
{
    public int numberOfCollectibles;
    public float timeFinish;
    public float timeInVR;
}

