using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CSVCaller : MonoBehaviour
{
    public CSVGen csvgen;
    public ResearchData data;
    public InputField nameInput;

    private float timer;

    private void Update()
    {
        timer += Time.deltaTime;
    }

    public void StartTimer()
    {
        timer = 0f;
    }

    public void CallCSVGen()
    {
        data.timeInVR = timer;
        csvgen.CreateCSV(data);
    }

    public void ChangeName()
    {
        data.name = nameInput.text;
    }

}
