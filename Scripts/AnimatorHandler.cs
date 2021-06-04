using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatorHandler : MonoBehaviour
{
    public Animator anim;
    int vertical;
    int horizontal;

    public void Initialize()
    {
        anim = GetComponentInChildren<Animator>();
    }

    public void PlayTargetAnimation(string animParameter, bool value)
    {
        anim.SetBool(animParameter, value);
    }

    public void PlayAnimationTrigger(string animParameter)
    {
        anim.SetTrigger(animParameter);
    }
}
