using GamePlay;
using Managers;
using ScriptableObjects;
using UnityEngine;

namespace Fiber.LevelSystem
{
	public class Level : MonoBehaviour
	{
		public LevelDataSO LevelData { get; private set; }
		public int TotalMoveCount { get; set; }

		[SerializeField] private Holder holder;
		[SerializeField] private CanoeManager canoeManager;

		public virtual void Load(LevelDataSO levelDataSO)
		{
			LevelData = levelDataSO;
			gameObject.SetActive(true);
			
			canoeManager.Setup(LevelData.SpawningCanoes);
		}

		public virtual void Play()
		{
		}
	}
}