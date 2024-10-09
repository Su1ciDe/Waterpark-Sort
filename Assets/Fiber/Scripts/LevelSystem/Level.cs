using System.Collections;
using Fiber.Managers;
using GamePlay;
using GamePlay.People;
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

			if (moveCount > 0) return;

			if (checkFailCoroutine is not null)
				StopCoroutine(checkFailCoroutine);

			checkFailCoroutine = StartCoroutine(CheckFail());
		}

		private Coroutine checkFailCoroutine = null;

		private IEnumerator CheckFail()
		{
			yield return new WaitForSeconds(1);
			if (moveCount <= 0)
				LevelManager.Instance.Lose();

			checkFailCoroutine = null;
		}

		public virtual void Load(LevelDataSO levelDataSO)
		{
			LevelData = levelDataSO;
			gameObject.SetActive(true);

			moveCount = LevelData.MoveCount;
			canoeManager.Setup(LevelData.SpawningCanoes, LevelData.MaxHolderLength);
			holder.Setup(levelDataSO.PersonInTheHolder);

			OnMoveCountChanged?.Invoke(moveCount);
		}

		public virtual void Play()
		{
		}
	}
}