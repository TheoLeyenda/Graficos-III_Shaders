using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayCastColor : MonoBehaviour
{
    public float rangeRay = 100;
    public Color colorPixel;

    private void Update()
    {
        FindColorByRayCast();
    }

    void FindColorByRayCast()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, transform.forward , out hit, rangeRay))
        {
            Debug.Log("ENTRE");
            Debug.DrawRay(transform.position, transform.forward * hit.distance, Color.yellow);
            MeshRenderer meshRenderer = hit.collider.GetComponent<MeshRenderer>();
            Debug.Log(meshRenderer.material.name);
            Vector4 color = meshRenderer.material.GetColor("_OutColor");
            colorPixel = color;
        }
    }
    //void GetMapColor()
    //{
    //    for (int i = 0; i < hexManager.numOfHexes; i++)
    //    {
    //        RaycastHit hit;
    //        if (!Physics.Raycast(hexGenerator.seperateHexagons[i].transform.position, Vector3.down, out hit))
    //        {
    //            Debug.LogError("No raycast");
    //            continue;
    //        }

    //        Renderer rend = mapGen.display.textureRenderer;
    //        MeshCollider meshCol = hit.collider as MeshCollider;

    //        if (rend == null || rend.sharedMaterial == null || rend.sharedMaterial.mainTexture == null || meshCol == null)
    //        {
    //            Debug.LogError("No Renderer!");
    //            continue;
    //        }

    //        Texture2D tex = rend.material.mainTexture as Texture2D;
    //        Vector2 pixelUV = hit.textureCoord;
    //        pixelUV.x = tex.width;
    //        pixelUV.y = tex.height;

    //        int hitX = Mathf.FloorToInt(hit.point.x);
    //        int hitZ = Mathf.FloorToInt(hit.point.z);

    //        Color myColor = tex.GetPixel(hitX, hitZ);
    //        Renderer hexRend = hexGenerator.seperateHexagons[i].GetComponent<Renderer>();
    //        string terrainType = "";

    //        Debug.Log("Hex " + i.ToString() + " is at " + hexGenerator.seperateHexagons[i].transform.position.ToString() + " Color : " + myColor.ToString() + " hitPositions are X " + hitX.ToString() + " Z " + hitZ.ToString());

    //        if (myColor.b > myColor.g && myColor.b > myColor.r)
    //        {
    //            hexDictionary.SetHexTerrain(i, "water");
    //            terrainType = "water";
    //            terrainCells.Add("water");

    //            hexRend.material = blue;
    //        }
    //        else if (myColor.g > myColor.b && myColor.g > myColor.r)
    //        {
    //            hexDictionary.SetHexTerrain(i, "land");
    //            terrainType = "land";
    //            terrainCells.Add("land");

    //            hexRend.material = green;
    //        }
    //        else if (myColor.r > myColor.g && myColor.r > myColor.b)
    //        {
    //            hexDictionary.SetHexTerrain(i, "mountain");
    //            terrainType = "mountain";
    //            terrainCells.Add("mountain");

    //            hexRend.material = red;
    //        }
    //        else
    //        {
    //            Debug.LogWarning("Currently an invalid/unassigned color");
    //        }
    //    }
    //}
}
