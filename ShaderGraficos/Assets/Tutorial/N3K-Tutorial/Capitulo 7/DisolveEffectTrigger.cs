using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisolveEffectTrigger : MonoBehaviour
{
    public Material disolveMaterial;
    public float speed, max;
    public string currentY_parameterName = "_DisolveY";
    private float currentY, startTime;

    private void Update()
    {
        if (currentY < max)
        {
            disolveMaterial.SetFloat(currentY_parameterName, currentY);
            currentY += Time.deltaTime * speed;
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            TriggerEffect();
        }
    }

    private void TriggerEffect()
    {
        startTime = Time.time;
        currentY = 0;
    }
}
