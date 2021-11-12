using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshGenerator : MonoBehaviour
{
    // Start is called before the first frame update

    Mesh mesh;

    public int xSize = 20;
    public int zSize = 20;

    [Range(0.0f, 1.0f)]
    public float substractDistanceVertices;

    Vector3[] vertices;
    int[] triangles;

    public GameObject sphereDebug;

    private List<GameObject> instanciateObjects;

    void Start()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        CreateShape();
        instanciateObjects = new List<GameObject>();
        InstanciateDebugShere();
    }

    private void Update()
    {
        UpdateMesh();

        if (Input.GetKeyDown(KeyCode.Return))
        {
            InstanciateDebugShere();
        }
    }
    public void CreateShape()
    {
        vertices = new Vector3[(xSize + 1) * (zSize + 1)];
        int i = 0;
        float distanceX = 0;
        float distanceZ = 0;
        for (int z = 0; z <= zSize; z++)
        {
            for (int x = 0; x <= xSize; x++)
            {
                vertices[i] = new Vector3(transform.position.x + x + distanceX, transform.position.y, transform.position.z + z + distanceZ);
                i++;
                distanceX = distanceX - substractDistanceVertices;
            }
            distanceX = 0;
            distanceZ = distanceZ - substractDistanceVertices;  
        }

        int vert = 0;
        int tris = 0;
        triangles = new int[xSize * zSize * 6];

        for (int z = 0; z < zSize; z++)
        {
            for (int x = 0; x < xSize; x++)
            {
                triangles[tris + 0] = vert + 0;
                triangles[tris + 1] = vert + xSize + 1;
                triangles[tris + 2] = vert + 1;
                triangles[tris + 3] = vert + 1;
                triangles[tris + 4] = vert + xSize + 1;
                triangles[tris + 5] = vert + xSize + 2;

                vert++;
                tris += 6;
            }
            vert++;
        }
    }

    void UpdateMesh()
    {
        mesh.Clear();

        mesh.vertices = vertices;
        mesh.triangles = triangles;

        mesh.RecalculateNormals();
    }

    public void InstanciateDebugShere()
    {
        for (int i = 0; i < instanciateObjects.Count; i++)
        {
            Destroy(instanciateObjects[i]);
        }

        instanciateObjects.Clear();

        for (int i = 0; i < vertices.Length; i++)
        {
            instanciateObjects.Add(Instantiate(sphereDebug, vertices[i], Quaternion.identity));
        }
    }
}
