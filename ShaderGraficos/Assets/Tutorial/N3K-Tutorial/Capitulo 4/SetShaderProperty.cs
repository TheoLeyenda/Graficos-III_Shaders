using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetShaderProperty : MonoBehaviour
{
    public Material mat;
    public string propertyName;
    public Transform player;

    // Update is called once per frame
    void Update()
    {
        if (player != null)
            mat.SetVector(propertyName, player.position);
        else
            Debug.LogError("Assign the player property");
    }
}
