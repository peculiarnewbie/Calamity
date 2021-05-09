using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    static GameManager instance;
    private void Awake()
    {
        if (instance != null)
        {
            Destroy(gameObject);
        }
        else
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
    }

    public bool highscoreReset = false;

    public int activeCar;
    public string playerName;
    // Start is called before the first frame update

    public void LoadLevel(int sceneIndex)
    {
        SceneManager.LoadScene(sceneIndex, LoadSceneMode.Single);
    }

    public void SetName(string name)
    {
        playerName = name;
    }

    public void SetCar(int index)
    {
        activeCar = index;
    }


}
