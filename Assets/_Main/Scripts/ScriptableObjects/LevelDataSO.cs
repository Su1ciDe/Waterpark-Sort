using System.Collections.Generic;
using GamePlay.Canoes;
using TriInspector;
using UnityEngine;
using Utilities;

namespace ScriptableObjects
{
	[DeclareFoldoutGroup("Randomizer")]
	[CreateAssetMenu(fileName = "Level_000", menuName = "Waterpark Sort/LevelData", order = 0)]
	public class LevelDataSO : ScriptableObject
	{
		public int MoveCount;
		public ColorType PersonInTheHolder = ColorType._0None;
		[OnValueChanged(nameof(SetupEditor))]
		public CanoeEditor[] SpawningCanoes;

		#region Randomizer

		[Group("Randomizer"), Button]
		private void Randomize()
		{
		}

		#endregion

		private void OnValidate()
		{
			SetupEditor();
		}

		private void SetupEditor()
		{
			foreach (var spawningCanoe in SpawningCanoes)
			{
				if (spawningCanoe.PeopleColors is null || spawningCanoe.PeopleColors.Count.Equals(0))
				{
					spawningCanoe.PeopleColors = new List<ColorType>((int)spawningCanoe.CanoeType);
					for (int i = 0; i < (int)spawningCanoe.CanoeType; i++)
						spawningCanoe.PeopleColors.Add(ColorType._0None);
				}
				else if (spawningCanoe.PeopleColors.Count < (int)spawningCanoe.CanoeType)
				{
					for (int i = spawningCanoe.PeopleColors.Count; i < (int)spawningCanoe.CanoeType; i++)
						spawningCanoe.PeopleColors.Add(ColorType._0None);
				}
				else if (spawningCanoe.PeopleColors.Count > (int)spawningCanoe.CanoeType)
				{
					while (!spawningCanoe.PeopleColors.Count.Equals((int)spawningCanoe.CanoeType))
						spawningCanoe.PeopleColors.RemoveAt(spawningCanoe.PeopleColors.Count - 1);
				}
			}
		}

		[DeclareHorizontalGroup("Canoe")]
		[System.Serializable]
		public class CanoeEditor
		{
			[Group("Canoe")] public CanoeType CanoeType;
			[Group("Canoe")] public ColorType CanoeColor;
			[ListDrawerSettings(HideAddButton = true, HideRemoveButton = true)]
			[Group("Canoe")] public List<ColorType> PeopleColors;
		}
	}
}