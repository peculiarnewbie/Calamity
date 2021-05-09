using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrowEffect : MonoBehaviour
{
    public List<MeshRenderer> growMeshes;
    public float timeToGrow = 5f;
    public float refreshRate = 0.05f;
    [Range(0, 1)]
    public float minGrow = 0.2f;
    [Range(0, 1)]
    public float maxGrow = 0.97f;

    private List<Material> growMaterials = new List<Material>();
    private bool fullyGrown = false;

    private bool startGrow = true;

    void Start()
    {
        for (int i=0; i<growMeshes.Count; i++)
        {
            for(int j=0; j<growMeshes[i].materials.Length; j++)
            {
                if (growMeshes[i].materials[j].HasProperty("Grow_"))
                {
                    growMeshes[i].materials[j].SetFloat("Grow_", minGrow);
                    growMaterials.Add(growMeshes[i].materials[j]);
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (startGrow)
        {
            for (int i=0; i<growMaterials.Count; i++)
            {
                StartCoroutine(GrowObjects(growMaterials[i]));
            }
        }
    }

    IEnumerator GrowObjects(Material mat)
    {
        float growValue = mat.GetFloat("Grow_");

        while(growValue < maxGrow)
        {
            growValue += 1 / (timeToGrow / refreshRate);
            mat.SetFloat("Grow_", growValue);

            yield return new WaitForSeconds(refreshRate);
        }  
    }

    IEnumerator ShrinkObjects(Material mat)
    {
        float growValue = mat.GetFloat("Grow_");

        while (growValue > minGrow)
        {
            growValue -= 1 / (timeToGrow / refreshRate);
            mat.SetFloat("Grow_", growValue);

            yield return new WaitForSeconds(refreshRate);
        }
    }
}
