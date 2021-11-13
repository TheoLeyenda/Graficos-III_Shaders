using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BubbleManager : MonoBehaviour
{
    public List<BubbleLava> Bubbles;

    public Vector2 MinAndMaxSpawnPositionX;
    public Vector2 MinAndMaxSpawnPositionY;
    public Vector2 MinAndMaxSpawnPositionZ;
    
    public float minDelaySpawnBubble;
    public float maxDelaySpawnBubble;
    public float delaySpawnBubble;

    public Color[] colors;

    public float delayColor;


    private void OnEnable()
    {
        BubbleLava.OnDisableObject += AddBubble;
    }

    private void OnDisable()
    {
        BubbleLava.OnDisableObject -= AddBubble;
    }

    private void Start()
    {
        delaySpawnBubble = Random.Range(minDelaySpawnBubble, maxDelaySpawnBubble);
    }

    void Update()
    {
        if (delaySpawnBubble > 0)
        {
            delaySpawnBubble = delaySpawnBubble - Time.deltaTime;
        }
        else if (delaySpawnBubble <= 0 && Bubbles.Count > 0)
        {
            delaySpawnBubble = Random.Range(minDelaySpawnBubble, maxDelaySpawnBubble);
            SpawnBubble();
        }
    }

    public void SpawnBubble()
    {
        BubbleLava bubbleLava = Bubbles[Random.Range(0, Bubbles.Count)];
        float X = Random.Range(MinAndMaxSpawnPositionX.x + transform.position.x, MinAndMaxSpawnPositionX.y + transform.position.y);
        float Y = Random.Range(MinAndMaxSpawnPositionY.x + transform.position.y, MinAndMaxSpawnPositionY.y + transform.position.y);
        float Z = Random.Range(MinAndMaxSpawnPositionZ.x + transform.position.z, MinAndMaxSpawnPositionZ.y + transform.position.y);

        bubbleLava.transform.position = new Vector3(X, Y, Z);

        bubbleLava.gameObject.SetActive(true);
        bubbleLava.materialLava.SetColor("_ColorTexture", colors[Random.Range(0, colors.Length)]);
        Bubbles.Remove(bubbleLava);
    }

    private void AddBubble(BubbleLava bubbleLava)
    {
        Bubbles.Add(bubbleLava);
    }


}
