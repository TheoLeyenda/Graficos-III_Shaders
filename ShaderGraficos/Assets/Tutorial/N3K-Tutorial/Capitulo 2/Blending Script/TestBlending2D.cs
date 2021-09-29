using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestBlending2D : MonoBehaviour
{
    public Material mat;
    public string nameIDproperty = "_LerpValue";

    void Update()
    {
        mat.SetFloat(nameIDproperty, Mathf.Sin(Time.time));
    }
}
