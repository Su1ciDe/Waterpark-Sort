using Fiber.Managers;
using GamePlay;
using Managers;
using ScriptableObjects;
using UnityEngine;
using UnityEngine.Events;

namespace Fiber.LevelSystem
{
	public class Level : MonoBehaviour
	{
		public LevelDataSO LevelData { get; private set; }
		public int TotalMoveCount { get; set; }

		[SerializeField] private Holder holder;
		[SerializeField] private CanoeManager canoeManager;

		private int moveCount = 0;

		public static event UnityAction<int> OnMoveCountChanged;

		private void OnEnable()
		{
			Person.OnPersonTapped += OnPersonTapped;
		}

		private void OnDisable()
		{
			Person.OnPersonTapped -= OnPersonTapped;
		}

		private void OnPersonTapped(Person person)
		{
			moveCount--;
			OnMoveCountChanged?.Invoke(moveCount);

			if (moveCount <= 0)
			{
				LevelManager.Instance.Lose();
			}
		}

		public virtual void Load(LevelDataSO levelDataSO)
		{
			LevelData = levelDataSO;
			gameObject.SetActive(true);

			moveCount = LevelData.MoveCount;
			canoeManager.Setup(LevelData.SpawningCanoes);
			holder.Setup(levelDataSO.PersonInTheHolder);

			OnMoveCountChanged?.Invoke(moveCount);
		}

		public virtual void Play()
		{
		}
	}
}