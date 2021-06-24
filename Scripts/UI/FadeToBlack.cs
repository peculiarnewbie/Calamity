using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeToBlack : MonoBehaviour
{
    CanvasGroup canvasGroup;

    private void Start()
    {
        GameManager.instance.OnResetStart += FadeMe;
        canvasGroup = GetComponent<CanvasGroup>();
        canvasGroup.alpha = 1;
        FadeOn();
    }

    public void FadeMe()
    {
        StartCoroutine(DoFade());
    }

    public void FadeOn()
    {
        StartCoroutine(DoFadeOn());
    }

    IEnumerator DoFade()
    {
        while (canvasGroup.alpha < 1)
        {
            canvasGroup.alpha += Time.deltaTime;
            yield return null;
        }
        canvasGroup.interactable = false;
        FadeOn();
        yield return null;

    }

    IEnumerator DoFadeOn()
    {
        yield return new WaitForSeconds(1f);
        while (canvasGroup.alpha > 0)
        {
            canvasGroup.alpha -= Time.deltaTime / 2;
            yield return null;
        }
        canvasGroup.interactable = false;
        yield return null;

    }
}
