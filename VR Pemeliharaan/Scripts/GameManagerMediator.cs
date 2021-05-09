using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManagerMediator : MonoBehaviour
{
    private GameManager gameManager;
    // Start is called before the first frame update
    void Start()
    {
        gameManager = GameObject.Find("GameManager").GetComponent<GameManager>();
    }

    public void LoadLevel(int sceneIndex)
    {
        gameManager.LoadLevel(sceneIndex);
    }

    public void ResetScore()
    {
        gameManager.highscoreReset = true;
    }
}
