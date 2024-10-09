using AYellowpaper.SerializedCollections;
using GamePlay;
using GamePlay.Canoes;
using GamePlay.People;
using UnityEngine;

namespace ScriptableObjects
{
	[CreateAssetMenu(fileName = "Prefabs", menuName = "Waterpark Sort/Prefabs", order = 1)]
	public class PrefabsSO : ScriptableObject
	{
		public SerializedDictionary<CanoeType, Canoe> CanoePrefabs = new SerializedDictionary<CanoeType, Canoe>();
		public Person PersonPrefab;
	}
}