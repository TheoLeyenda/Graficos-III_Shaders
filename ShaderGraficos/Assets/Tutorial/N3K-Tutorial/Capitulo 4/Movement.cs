using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public float speed;
    private Vector3 move;
    private float xMov;
    private float zMov;
    // Update is called once per frame
    void Update()
    {
        xMov = Input.GetAxis("Horizontal") * speed * Time.deltaTime;
        zMov = Input.GetAxis("Vertical") * speed * Time.deltaTime;

        transform.position += new Vector3(xMov, 0, zMov);
    }
}
