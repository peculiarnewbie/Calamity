using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TrashController : MonoBehaviour
{
    private int trashLeft;
    private int totalTrash;
    [SerializeField] Image fillImage;

    [SerializeField] GameObject finishUI;

    // Start is called before the first frame update
    void Start()
    {
        trashLeft = this.transform.childCount;
        totalTrash = trashLeft;
        
    }

    // Update is called once per frame

    public void DecreaseTrash()
    {
        trashLeft--;
        float imageFill = (float) (totalTrash - trashLeft) / totalTrash;
        fillImage.fillAmount = imageFill;
        Debug.Log(fillImage.fillAmount);
        Debug.Log(totalTrash);
        Debug.Log(trashLeft);
        if (trashLeft<= 0)
        {
            FinishLevel();
        }
    }

    public void FinishLevel()
    {
        finishUI.SetActive(true);
    }

}
