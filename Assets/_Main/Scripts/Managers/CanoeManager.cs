using System.Collections.Generic;
using Fiber.Managers;
using Fiber.Utilities;
using GamePlay.Canoes;
using ScriptableObjects;
using TriInspector;
using UnityEngine;

namespace Managers
{
	public class CanoeManager : Singleton<CanoeManager>
	{
		[SerializeField] private CanoeHolder[] holders;

		[Title("Editor")]
		private Queue<Canoe> canoeQueue = new Queue<Canoe>();

		public void Setup(LevelDataSO.CanoeEditor[] canoesEditor)
		{
			for (var i = 0; i < canoesEditor.Length; i++)
			{
				var canoeEditor = canoesEditor[i];
				var canoe = Instantiate(GameManager.Instance.PrefabsSO.CanoePrefabs[canoeEditor.CanoeType], transform);
				canoe.Setup(canoeEditor.CanoeColor, canoeEditor.PeopleColors);
			}
		}
	}
}