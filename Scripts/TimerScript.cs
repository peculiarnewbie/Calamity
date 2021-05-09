using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TimerScript : MonoBehaviour
{
    public bool timerActive = false;
    public float time = 0;
    public Text timerText;
    public Text timerText2;

    public bool isRacing = false;
    private GameManager gameManager;

    // Start is called before the first frame update
    void Start()
    {
        timerText.text = time.ToString("F2");
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
    }

    // Update is called once per frame
    void Update()
    {
        if (timerActive)
        {
            time += Time.deltaTime;
            timerText.text = TimeToString(time);
            timerText2.text = timerText.text;
            //timerText.text = time.ToString("F2");
        }
    }

    public string TimeToString(float time)
    {
        string output;
        float minutes = Mathf.Floor(time / 60);
        float seconds = (Mathf.Floor(time) % 60);
        float miliseconds = (time - Mathf.Floor(time)) * 100;
        output = minutes.ToString("00") + ":" + seconds.ToString("00") + ":" + miliseconds.ToString("00");
        return output;

    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log("crossing the line");
        if (!timerActive)
            ResetTimer();
        else
            timerActive = false;
    }

    public void ResetTimer()
    {
        time = 0;
        timerActive = true;
    }


}
