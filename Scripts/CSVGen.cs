using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class CSVGen : MonoBehaviour
{
    public void CreateCSV(string name)
    {
        StartCoroutine(GenerateCSV(name));
    }

    IEnumerator GenerateCSV(string name)
    {

        string filepath = Application.persistentDataPath + "/" + name + "-" + "GameOne-" + DateTime.Now.ToString("dd-MMMM-HHmmss") + ".csv";

        if (File.Exists(filepath))
        {
            File.Delete(filepath);
        }

        var sr = File.CreateText(filepath);

        yield return new WaitForSeconds(0.5f);

        Application.OpenURL(filepath);
    }


    //public void CreateCSVGameOne(PlayerCalibration playerCalibration, GameOneSummary gameOneSummary)
    //{
    //    StartCoroutine(createGameOneCSV(playerCalibration, gameOneSummary));
    //}

    //IEnumerator createGameOneCSV(PlayerCalibration playerCalibration, GameOneSummary gameOneSummary)
    //{
    //    string filepath = Application.persistentDataPath + "/" + playerCalibration.name + "-" + "GameOne-" + DateTime.Now.ToString("dd-MMMM-HHmmss") + ".csv";

    //    if (File.Exists(filepath))
    //    {
    //        File.Delete(filepath);
    //    }

    //    var sr = File.CreateText(filepath);

    //    string dataCSV = "Player Name" + System.Environment.NewLine;
    //    dataCSV += playerCalibration.name + System.Environment.NewLine;
    //    dataCSV += "Player Calibration" + System.Environment.NewLine;
    //    dataCSV += "Top Left, Top Right, Bottom Left, Bottom Right" + System.Environment.NewLine;
    //    dataCSV += playerCalibration.topLeftBound + "," + playerCalibration.topRightBound + "," + playerCalibration.botLeftBound + "," + playerCalibration.botRightBound + System.Environment.NewLine;
    //    dataCSV += System.Environment.NewLine;

    //    foreach (GameOneSettings settings in gameOneSummary.settings)
    //    {
    //        dataCSV += "Ball Radius" + System.Environment.NewLine;
    //        dataCSV += settings.ballRadius + System.Environment.NewLine;
    //        dataCSV += System.Environment.NewLine;
    //        dataCSV += "No,Time, Hand Coordinate X, Hand Coordinate Y, Hand Coordinate Z, Difference X, Difference Y, Difference Z, Distance" + System.Environment.NewLine;
    //        int i = 0;
    //        foreach (GameOneStats gameOneStats in settings.statList.gameOneStats)
    //        {
    //            dataCSV += i + "," + gameOneStats.ballTime + "," + gameOneStats.handCoords.x + "," + gameOneStats.handCoords.y + "," + gameOneStats.handCoords.z + "," + gameOneStats.diff.x + "," + gameOneStats.diff.y + "," + gameOneStats.diff.z + "," + gameOneStats.distance + System.Environment.NewLine;
    //        }
    //        dataCSV += System.Environment.NewLine;
    //    }

    //    sr.WriteLine(dataCSV);

    //    FileInfo fInfo = new FileInfo(filepath);
    //    fInfo.IsReadOnly = true;

    //    sr.Close();

    //    yield return new WaitForSeconds(0.5f);

    //    Application.OpenURL(filepath);
    //}
}
