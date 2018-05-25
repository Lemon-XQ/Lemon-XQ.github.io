---
title: Unity对象池技术（原理+实战）
date: 2017-08-13 13:30:19
tags:
	- Unity
	- 对象池
	- 翻译
categories:
	- Unity
---
## 写在前面
　　很早就听说过对象池技术……然而一直到这几天才真正去了解= =。还得感谢Jasper Flick的博客，这里推荐他的[Unity C# Tutorials系列](http://catlikecoding.com/unity/tutorials/)，目前我只看了前几篇，收获还是挺大的~本篇博客也是基于这个系列中的一篇——[Object Pools](http://catlikecoding.com/unity/tutorials/object-pools/)，加上个人的一些理解，对Unity的对象池技术进行简单介绍。
<!--more-->
## 对象池简介
　　顾名思义，对象池是存放对象的**缓冲区**。用户可以从缓冲区中**放入/取出**对象。一类对象池存放一类特定的对象。那么对象池有什么用呢？在游戏中，经常会有**产生/销毁**大量**同类**游戏对象的需求，比如游戏中源源不断的敌人、频繁刷新的宝箱、乃至一些游戏特效（风、雨等）。如果没有一种比较好的机制来管理这些对象的产生和销毁，而是一昧的Instantiate和Destroy，将使你的**游戏性能**大大下降，甚至出现卡死、崩溃……
## 对象池实现
　　简而言之，就是当需要使用一个对象的时候，直接从该类对象的对象池中取出（**SetActive(true)**），如果对象池中无可用对象，再进行Instantitate。而当不再需要该对象时，不直接进行Destroy,而是**SetActive(false)**并将其回收到对象池中。下面直接贴下代码：
### PooledObject.cs

{% codeblock lang:csharp %}
using UnityEngine;
/// <summary>
/// 所有需要使用对象池机制的对象的基类
/// </summary>
public class PooledObject : MonoBehaviour
{
    // 归属的池
    public ObjectPool Pool { get; set; }

    // 场景中某个具体的池（不可序列化）
    [System.NonSerialized]
    private ObjectPool poolInstanceForPrefab;

    /// <summary>
    /// 回收对象到对象池中
    /// </summary>
    public void ReturnToPool()
    {
        if (Pool)
        {
            Pool.AddObject(this);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    /// <summary>
    /// 返回对象池中可用对象的实例
    /// </summary>
    public T GetPooledInstance<T>() where T : PooledObject
    {
        if (!poolInstanceForPrefab)
        {
            poolInstanceForPrefab = ObjectPool.GetPool(this);
        }
        return (T)poolInstanceForPrefab.GetObject();
    }
}
{% endcodeblock %}

### ObjectPool.cs

{% codeblock lang:csharp %}
using UnityEngine;
using System.Collections.Generic;

public class ObjectPool : MonoBehaviour
{
    // 池中对象prefab
    private PooledObject prefab;

    // 存储可用对象的缓冲区
    private List<PooledObject> availableObjects = new List<PooledObject>();

    /// <summary>
    /// 从池中取出对象，返回该对象
    /// </summary>
    public PooledObject GetObject()
    {
        PooledObject obj;
        int lastAvailableIndex = availableObjects.Count - 1;
        if (lastAvailableIndex >= 0)
        {
            obj = availableObjects[lastAvailableIndex];
            availableObjects.RemoveAt(lastAvailableIndex);
            obj.gameObject.SetActive(true);
        }
        else // 池中无可用obj
        {
            obj = Instantiate<PooledObject>(prefab);
            obj.transform.SetParent(transform, false);
            obj.Pool = this;
        }
        return obj;
    }

    /// <summary>
    /// 向池中放入obj
    /// </summary>
    public void AddObject(PooledObject obj)
    {
        obj.gameObject.SetActive(false);
        availableObjects.Add(obj);
    }

    /// <summary>
    /// 【静态方法】创建并返回对象所属的对象池
    /// </summary>
    public static ObjectPool GetPool(PooledObject prefab)
    {
        GameObject obj;
        ObjectPool pool;
        // 编辑器模式下检查是否有同名pool存在，防止重复创建pool
        if (Application.isEditor)
        {
            obj = GameObject.Find(prefab.name + " Pool");
            if (obj)
            {
                pool = obj.GetComponent<ObjectPool>();
                if (pool)
                {
                    return pool;
                }
            }
        }
        obj = new GameObject(prefab.name + " Pool");
        DontDestroyOnLoad(obj);
        pool = obj.AddComponent<ObjectPool>();
        pool.prefab = prefab;
        return pool;
    }
}
{% endcodeblock %}

## 实战：七彩喷泉
【注：以下译至前面提到的[Object Pools](http://catlikecoding.com/unity/tutorials/object-pools/)一文，有部分删减】
### 1.实现效果：
<embed type="video/mp4" allowscriptaccess="always" allowfullscreen="true" wmode="transparent" quality="high" height="300" width="480" src="https://fat.gfycat.com/QueasyPessimisticDugong.mp4"/>

### 2.生成大量物体
- 首先新建脚本Stuff.cs，代码如下：
{% codeblock lang:csharp %}
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Stuff : MonoBehaviour {

	Rigidbody body;

	void Awake () {
		body = GetComponent<Rigidbody>();
	}
}
{% endcodeblock %}
- 创建Cube和Sphere，挂上Stuff脚本。并将它们做成Prefab
- 接下来需要创建StuffSpawner（孵化器），并挂上StuffSpawner脚本，代码如下：
{% codeblock lang:csharp %}
using UnityEngine;

public class StuffSpawner : MonoBehaviour {

	public float timeBetweenSpawns;

	public Stuff[] stuffPrefabs;

	float timeSinceLastSpawn;

	void FixedUpdate () {
		timeSinceLastSpawn += Time.deltaTime;
		if (timeSinceLastSpawn >= timeBetweenSpawns) {
			timeSinceLastSpawn -= timeBetweenSpawns;
			SpawnStuff();
		}
	}

	void SpawnStuff () {
		Stuff prefab = stuffPrefabs[Random.Range(0, stuffPrefabs.Length)];
		Stuff spawn = Instantiate<Stuff>(prefab);
		spawn.transform.localPosition = transform.position;
	}
}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/spawning-lots-of-stuff/spawner.png)
- 现在我们有了孵化器，可以在一个点产生Cube和Sphere，但这还不够。我们可以给这些stuff一个初始速度及方向。
{% codeblock lang:csharp %}
	public float velocity;

	void SpawnStuff () {
		Stuff prefab = stuffPrefabs[Random.Range(0, stuffPrefabs.Length)];
		Stuff spawn = Instantiate<Stuff>(prefab);
		spawn.transform.localPosition = transform.position;
		spawn.Body.velocity = transform.up * velocity;
	}
{% endcodeblock %}
- 运行一下可以发现一个个物体上升又下降，周而复始。如果你倾斜一下孵化器，会让它看上去更像流动的物体。事实上，如果我们把多个孵化器分布在一个环上，将得到类似喷泉的效果。因此，新建一个空物体StuffSpawnerRing，挂上如下脚本：
{% codeblock lang:csharp %}
using UnityEngine;

public class StuffSpawnerRing : MonoBehaviour {

	public int numberOfSpawners;
	
	public float radius, tiltAngle;
	
	public StuffSpawner spawnerPrefab;

	void Awake () {
		for (int i = 0; i < numberOfSpawners; i++) {
			CreateSpawner(i);
		}
	}
}
	void CreateSpawner (int index) {
		Transform rotater = new GameObject("Rotater").transform;
		rotater.SetParent(transform, false);
		rotater.localRotation =
			Quaternion.Euler(0f, index * 360f / numberOfSpawners, 0f);

		StuffSpawner spawner = Instantiate<StuffSpawner>(spawnerPrefab);
		spawner.transform.SetParent(rotater, false);
		spawner.transform.localPosition = new Vector3(0f, 0f, radius);
		spawner.transform.localRotation = Quaternion.Euler(tiltAngle, 0f, 0f);
	}
{% endcodeblock %}
- 现在将场景中的Spawner做成prefab并删除，调整SpawnerRing的参数
![](http://catlikecoding.com/unity/tutorials/object-pools/spawning-lots-of-stuff/ring.png)
### 3.添加销毁区（KillZone）
- 我们现在得到了无止尽生成的下落的物体。为了防止程序卡顿，我们需要引入销毁区。所有进入销毁区的物体都要被销毁。
- 创建一个带有Box Collider的物体，设置为触发器，为Collider设置一个非常大的size（如1000），并将其放置在喷泉下方某个位置。最后给该物体添加一个Tag以便能被正确识别
![](http://catlikecoding.com/unity/tutorials/object-pools/spawning-lots-of-stuff/kill-zone.png)
- 重新编辑Stuff.cs，添加触发器事件处理
{% codeblock lang:csharp %}
	void OnTriggerEnter (Collider enteredCollider) {
		if (enteredCollider.CompareTag("Kill Zone")) {
			Destroy(gameObject);
		}
	}
{% endcodeblock %}

### 4.加入可变因素
- 目前我们的喷泉缺少随机性，我们可以用随机值代替固定值。因为我们要处理多个数据，所以让我们创建一个结构体来更好地实现随机化。
{% codeblock lang:csharp %}
using UnityEngine;

[System.Serializable]
public struct FloatRange {

	public float min, max;
	
	public float RandomInRange {
		get {
			return Random.Range(min, max);
		}
	}
}
{% endcodeblock %}
- **随机化生成时间**
{% codeblock lang:csharp %}
	public FloatRange timeBetweenSpawns;

	float currentSpawnDelay;

	void FixedUpdate () {
		timeSinceLastSpawn += Time.deltaTime;
		if (timeSinceLastSpawn >= currentSpawnDelay) {
			timeSinceLastSpawn -= currentSpawnDelay;
			currentSpawnDelay = timeBetweenSpawns.RandomInRange;
			SpawnStuff();
		}
	}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/adding-variation/spawn-time-range.png)
- **随机化物体scale和rotation**
{% codeblock lang:csharp %}
	public FloatRange timeBetweenSpawns, scale;

	void SpawnStuff () {
		Stuff prefab = stuffPrefabs[Random.Range(0, stuffPrefabs.Length)];
		Stuff spawn = Instantiate<Stuff>(prefab);
		
		spawn.transform.localPosition = transform.position;
		spawn.transform.localScale = Vector3.one * scale.RandomInRange;
		spawn.transform.localRotation = Random.rotation;
		
		spawn.Body.velocity = transform.up * velocity;
	}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/adding-variation/scale-range.png)
- **随机化物体速度大小**
{% codeblock lang:csharp %}
	public FloatRange timeBetweenSpawns, scale, randomVelocity;

	void SpawnStuff () {
		…
		
		spawn.Body.velocity = transform.up * velocity +
			Random.onUnitSphere * randomVelocity.RandomInRange;
	}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/adding-variation/random-velocity-range.png)
- **随机化物体角速度**
{% codeblock lang:csharp %}
	void SpawnStuff () {
		…

		spawn.Body.velocity = transform.up * velocity +
			Random.onUnitSphere * randomVelocity.RandomInRange;
		spawn.Body.angularVelocity =
			Random.onUnitSphere * angularVelocity.RandomInRange;
	}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/adding-variation/angular-velocity-range.png)
- **随机化材质（实现七彩）**
{% codeblock lang:csharp %}
	public Material[] stuffMaterials;

	void CreateSpawner (int index) {
		…

		spawner.stuffMaterial = stuffMaterials[index % stuffMaterials.Length];
	}
{% endcodeblock %}
![](http://catlikecoding.com/unity/tutorials/object-pools/adding-variation/ring-materials.png)

### 5.应用对象池进行管理
- 让Stuff继承PooledObject(PooledObject代码见前)，修改触发器事件，进入销毁区时不Destroy，而是调用ReturnToPool方法。
- 接下来，我们需要改变StuffSpawner来让它使用对象池来创建对象，而不是直接Instanstiate。如何做到呢？某种程度上我们需要拥有每个prefab的池，但我们不想要重复的池，也就是说所有孵化器都共享他们。当然，如果我们能直接从一个prefab得到一个池化的实例而不用考虑那些池本身将更加方便。
{% codeblock lang:csharp %}
	void SpawnStuff () {
		Stuff prefab = stuffPrefabs[Random.Range(0, stuffPrefabs.Length)];
		Stuff spawn = prefab.GetPooledInstance<Stuff>();

		…
	}
{% endcodeblock %}

## 其他
1. 并非**所有的**对象都适合使用对象池来管理。需要在“**对象生成的开销**”以及“**维护对象池的开销**”之间进行权衡。
2. 为避免在场景切换时重新生成pool，从而带来性能损耗，可在代码中加入**DontDestroyOnLoad(pool)**
3. 同样，在场景切换时，应该将原场景中的对象回收进相应对象池中。即在**OnLevelWasLoaded**方法中调用**ReturnToPool**方法