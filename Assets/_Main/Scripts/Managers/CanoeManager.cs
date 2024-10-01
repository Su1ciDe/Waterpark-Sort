using System.Collections.Generic;
using DG.Tweening;
using Fiber.Managers;
using Fiber.Utilities;
using Fiber.Utilities.Extensions;
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
		}

		private void OnDisable()
		{
			LevelManager.OnLevelLoad -= OnLevelLoaded;
		}

		private void OnLevelLoaded()
		{
			Tween tween = null;
			for (int i = 0; i < CanoeHolder.MAX_CANOES * 2; i++)
			{
				if (!canoeQueue.TryDequeue(out var canoe)) break;

				var holder = holders[i % 2];
				if (holder.IsFull) continue;

				canoe.transform.position = new Vector3(holder.transform.position.x, canoe.transform.position.y, canoe.transform.position.z);
				canoe.gameObject.SetActive(true);

				var size = holder.GetLength();

				tween = canoe.Move(holder.transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f)).SetDelay(i * SPAWN_DELAY);
				holder.SetCanoe(canoe);
			}

			if (tween is not null)
			{
				tween.onComplete += () => LevelManager.Instance.StartLevel();
			}
		}

		public void Setup(LevelDataSO.CanoeEditor[] canoesEditor)
		{
			for (var i = 0; i < canoesEditor.Length; i++)
			{
				var canoeEditor = canoesEditor[i];
				var canoe = Instantiate(GameManager.Instance.PrefabsSO.CanoePrefabs[canoeEditor.CanoeType], transform);
				canoe.Setup(canoeEditor.CanoeColor, canoeEditor.PeopleColors);
				canoe.gameObject.SetActive(false);
				canoeQueue.Enqueue(canoe);
			}
		}

		public void AdvanceLines()
		{
			for (var i = 0; i < holders.Length; i++)
			{
				var holder = holders[i];
				var size = 0f;
				for (var j = 0; j < holder.Canoes.Count; j++)
				{
					var canoe = holder.Canoes[j];
					var pos = holder.transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f);
					if (pos.NotEquals(canoe.transform.position))
					{
						canoe.Move(pos);
					}

					size += canoe.Size.y;
				}
			}
		}

		public void SpawnCanoes()
		{
			for (int i = 0; i < holders.Length; i++)
			{
				var holder = holders[i];
				var j = 0;
				while (holder.IsFull)
				{
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
	}
}