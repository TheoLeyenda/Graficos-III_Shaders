using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class BubbleLava : MonoBehaviour
{
    public enum TypeDisolveBubble
    {
        HeightDisolve,
        ScaleDisolve,
    }
    public TypeDisolveBubble typeDisolveBubble;
    public Material materialLava;
    public string nameParameterDisolve;
    public float minValueDisolve;
    public float maxValueDisolve;
    public float valueDisolve;
    public float speedDisolve;
    public Vector2 MinAndMaxSpeedDisolve;
    public float speedMovementUp;
    public float speedScale;
    public float heightDisolve;
    public Vector2 MinAndMaxScaleDisolve;
    public float scaleDisolve;
    public static event Action<BubbleLava> OnDisableObject;

    private void OnDisable()
    {
        if(OnDisableObject != null)
            OnDisableObject(this);
        ResetData();
    }

    private void OnEnable()
    {
        valueDisolve = maxValueDisolve;
        ResetData();
    }
    private void Start()
    {
        valueDisolve = maxValueDisolve;
        materialLava.SetFloat(nameParameterDisolve, maxValueDisolve);
        ResetData();
    }
    void Update()
    {
        switch (typeDisolveBubble)
        {
            case TypeDisolveBubble.HeightDisolve:
                if (transform.position.y > heightDisolve)
                {
                    Disolve();
                }
                else
                {
                    transform.position = new Vector3(transform.position.x, transform.position.y + Time.deltaTime * speedMovementUp, transform.position.z);
                }
                break;
            case TypeDisolveBubble.ScaleDisolve:
                if (transform.localScale.x > scaleDisolve && transform.localScale.y > scaleDisolve && transform.localScale.z > scaleDisolve)
                {
                    Disolve();
                }
                else
                {
                    transform.localScale = new Vector3(transform.localScale.x + speedScale * Time.deltaTime
                        , transform.localScale.y + speedScale * Time.deltaTime
                        , transform.localScale.z + speedScale * Time.deltaTime);
                }
                break;
        }
    }

    public void Disolve()
    {
        valueDisolve = valueDisolve - Time.deltaTime * speedDisolve;
        materialLava.SetFloat(nameParameterDisolve, valueDisolve);

        if (valueDisolve < minValueDisolve)
        {
            valueDisolve = maxValueDisolve;
            gameObject.SetActive(false);
            ResetData();
        }
    }

    private void ResetData()
    {
        speedDisolve = UnityEngine.Random.Range(MinAndMaxSpeedDisolve.x, MinAndMaxSpeedDisolve.y);
        materialLava.SetFloat(nameParameterDisolve, maxValueDisolve);

        if (typeDisolveBubble == TypeDisolveBubble.ScaleDisolve)
        {
            transform.localScale = Vector3.zero;
            scaleDisolve = UnityEngine.Random.Range(MinAndMaxScaleDisolve.x, MinAndMaxScaleDisolve.y);
        }
    }
}
