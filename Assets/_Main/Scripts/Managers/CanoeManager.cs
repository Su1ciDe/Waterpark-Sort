using System.Collections;
using System.Collections.Generic;
using System.Linq;
using DG.Tweening;
using Fiber.Managers;
using Fiber.Utilities;
using GamePlay.Canoes;
using ScriptableObjects;
using UnityEngine;

namespace Managers
{
	public class CanoeManager : Singleton<CanoeManager>
	{
		[SerializeField] private CanoeHolder[] holders;

		private readonly Queue<Canoe> canoeQueue = new Queue<Canoe>();

		private const float SPAWN_DELAY = .35f;

		private void OnEnable()
		{
			LevelManager.OnLevelLoad += OnLevelLoaded;
			Canoe.OnLeaveAny += OnCanoeLeft;
		}

		private void OnDisable()
		{
			LevelManager.OnLevelLoad -= OnLevelLoaded;
			Canoe.OnLeaveAny -= OnCanoeLeft;
		}

		private void OnLevelLoaded()
		{
			Tween tween = null;
			int i = 0;
			while (holders.Any(x => !x.IsFull))
			{
				var holder = holders[i % 2];
				if (canoeQueue.TryPeek(out var canoePeek))
					if (holder.CurrentLength + canoePeek.Length >= holder.MaxLength)
					{
						i++;
						holder.IsFull = true;
						continue;
					}

				if (!canoeQueue.TryDequeue(out var canoe)) break;
				canoe.transform.position = new Vector3(holder.transform.position.x, canoe.transform.position.y, canoe.transform.position.z);
				canoe.gameObject.SetActive(true);

				var size = holder.GetLength();

				tween = canoe.Move(holder.transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f)).SetDelay(i * SPAWN_DELAY);
				holder.SetCanoe(canoe);

				i++;
			}
			// for (int i = 0; i < CanoeHolder.MAX_CANOES * 2; i++)
			// {
			// 	if (!canoeQueue.TryDequeue(out var canoe)) break;
			//
			// 	var holder = holders[i % 2];
			// 	if (holder.IsFull) continue;
			//
			// 	canoe.transform.position = new Vector3(holder.transform.position.x, canoe.transform.position.y, canoe.transform.position.z);
			// 	canoe.gameObject.SetActive(true);
			//
			// 	var size = holder.GetLength();
			//
			// 	tween = canoe.Move(holder.transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f)).SetDelay(i * SPAWN_DELAY);
			// 	holder.SetCanoe(canoe);
			// }

			if (tween is not null)
			{
				tween.onComplete += () => LevelManager.Instance.StartLevel();
			}
		}

		public void Setup(LevelDataSO.CanoeEditor[] canoesEditor, int holderMaxLength)
		{
			for (var i = 0; i < canoesEditor.Length; i++)
			{
				var canoeEditor = canoesEditor[i];
				var canoe = Instantiate(GameManager.Instance.PrefabsSO.CanoePrefabs[canoeEditor.CanoeType], transform);
				canoe.Setup(canoeEditor.CanoeColor, canoeEditor.PeopleColors);
				canoe.gameObject.SetActive(false);
				canoeQueue.Enqueue(canoe);
			}

			for (int i = 0; i < holders.Length; i++)
			{
				holders[i].Setup(holderMaxLength);
			}
		}

		public void AdvanceLines()
		{
			for (var i = 0; i < holders.Length; i++)
			{
				holders[i].Advance();
			}

			SpawnCanoes();
		}

		public void SpawnCanoes()
		{
			for (int i = 0; i < holders.Length; i++)
			{
				var holder = holders[i];
				var j = 0;
				while (!holder.IsFull)
				{
					if (canoeQueue.TryPeek(out var canoePeek))
						if (holder.CurrentLength + canoePeek.Length >= holder.MaxLength)
						{
							holder.IsFull = true;
							break;
						}

					if (!canoeQueue.TryDequeue(out var canoe)) return;

					canoe.transform.position = new Vector3(holder.transform.position.x, canoe.transform.position.y, canoe.transform.position.z);
					canoe.gameObject.SetActive(true);

					var size = holder.GetLength();

					canoe.Move(holder.transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f)).SetDelay(j * SPAWN_DELAY);
					holder.SetCanoe(canoe);

					j++;
				}
			}
		}

		private void OnCanoeLeft(Canoe canoe)
		{
			if (checkWinCoroutine is not null)
				StopCoroutine(checkWinCoroutine);

			checkWinCoroutine = StartCoroutine(CheckWin());
		}

		private Coroutine checkWinCoroutine;

		private IEnumerator CheckWin()
		{
			yield return new WaitForSeconds(0.5f);

			var isFinished = false;
			if (canoeQueue.Count.Equals(0))
			{
				for (int i = 0; i < holders.Length; i++)
				{
					if (holders[i].Canoes.Count.Equals(0))
					{
						isFinished = true;
					}
					else
					{
						isFinished = false;
						break;
					}
				}

				if (isFinished)
				{
					LevelManager.Instance.Win(LevelManager.Instance.CurrentLevel.TotalMoveCount);
				}
			}

			checkWinCoroutine = null;
		}

		public bool IsFirstCanoe(Canoe canoe)
		{
			for (int i = 0; i < holders.Length; i++)
			{
				if (holders[i].Canoes.Count <= 0) continue;
				if (holders[i].Canoes[0].Equals(canoe))
				{
					return true;
				}
			}

			return false;
		}
	}
}