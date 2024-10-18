using System.Collections;
using Fiber.Managers;
using GamePlay;
using GamePlay.People;
using GamePlay.Player;
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

		private int moveCount;
		public int MoveCount => moveCount;

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

			if (moveCount.Equals(0))
			{
				Player.Instance.CanInput = false;
				if (checkFailCoroutine is not null)
					StopCoroutine(checkFailCoroutine);

				checkFailCoroutine = StartCoroutine(CheckFail());
			}
		}

		private Coroutine checkFailCoroutine = null;

		private IEnumerator CheckFail()
		{
			yield return new WaitForSeconds(1.5f);
			if (moveCount <= 0)
				LevelManager.Instance.Lose();

			checkFailCoroutine = null;
		}

		public virtual void Load(LevelDataSO levelDataSO)
		{
			LevelData = levelDataSO;
			gameObject.SetActive(true);

			canoeManager.Setup(LevelData.SpawningCanoes, LevelData.MaxHolderLength);
			holder.Setup(levelDataSO.PersonInTheHolder);
			moveCount = LevelData.MoveCount;

			OnMoveCountChanged?.Invoke(moveCount);
		}

		public virtual void Play()
		{
		}
	}
}