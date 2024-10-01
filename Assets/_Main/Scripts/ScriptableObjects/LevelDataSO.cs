using System;
using System.Linq;
using System.Collections.Generic;
using Fiber.Utilities.Extensions;
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

		[Group("Randomizer")] [SerializeField] private int randomCanoeCount;
		[Group("Randomizer")] [SerializeField] private List<RandomCanoeType> randomCanoeTypes;
		[Group("Randomizer")] [SerializeField] private List<RandomCanoeColor> randomCanoeColors;
		[Group("Randomizer")] [SerializeField] private List<RandomPeople> randomPeople;

		[Group("Randomizer"), Button]
		private void Randomize()
		{
			SpawningCanoes = new CanoeEditor[randomCanoeCount];

			var canoeTypes = randomCanoeTypes.Select(x => x.CanoeType).ToList();
			var canoeTypeWeights = randomCanoeTypes.Select(x => x.Weight).ToList();

			var canoeColors = randomCanoeColors.Select(x => x.Color).ToList();
			var canoeColorWeights = randomCanoeColors.Select(x => x.Weight).ToList();

			for (int i = 0; i < randomCanoeCount; i++)
			{
				SpawningCanoes[i] = new CanoeEditor
				{
					CanoeType = canoeTypes.WeightedRandom(canoeTypeWeights), CanoeColor = canoeColors.WeightedRandom(canoeColorWeights), PeopleColors = new List<ColorType>()
				};
				for (int j = 0; j < (int)SpawningCanoes[i].CanoeType; j++)
				{
					SpawningCanoes[i].PeopleColors.Add(canoeColors.WeightedRandom(canoeColorWeights));
				}
			}
		}

		private void CalculateCanoeTypesPercentages()
		{
			var totalWeight = 0;
			foreach (var canoeType in randomCanoeTypes)
				totalWeight += canoeType.Weight;

			foreach (var canoeType in randomCanoeTypes)
				canoeType.Percent = ((float)canoeType.Weight / totalWeight * 100).ToString("F2") + "%";
		}
		private void CalculateCanoeColorPercentages()
		{
			var totalWeight = 0;
			foreach (var canoeType in randomCanoeColors)
				totalWeight += canoeType.Weight;

			foreach (var canoeType in randomCanoeColors)
				canoeType.Percent = ((float)canoeType.Weight / totalWeight * 100).ToString("F2") + "%";
		}
		private void CalculateRandomPeoplePercentages()
		{
			var totalWeight = 0;
			foreach (var canoeType in randomPeople)
				totalWeight += canoeType.Weight;

			foreach (var canoeType in randomPeople)
				canoeType.Percent = ((float)canoeType.Weight / totalWeight * 100).ToString("F2") + "%";
		}

		#endregion

		private void OnValidate()
		{
			SetupEditor();
			CalculateCanoeTypesPercentages();
			CalculateCanoeColorPercentages();
			CalculateRandomPeoplePercentages();
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
		[Serializable]
		public class CanoeEditor
		{
			[Group("Canoe")] public CanoeType CanoeType;
			[Group("Canoe")] public ColorType CanoeColor;
			[ListDrawerSettings(HideAddButton = true, HideRemoveButton = true)]
			[Group("Canoe")] public List<ColorType> PeopleColors;
		}

		[DeclareHorizontalGroup("RandomCanoeType")]
		[Serializable]
		private class RandomCanoeType
		{
			[Group("RandomCanoeType")] public CanoeType CanoeType;
			[Group("RandomCanoeType")] public int Weight;
			[Group("RandomCanoeType"), HideLabel, DisplayAsString] public string Percent;
		}

		[DeclareHorizontalGroup("RandomCanoeColor")]
		[Serializable]
		private class RandomCanoeColor
		{
			[Group("RandomCanoeColor")] public ColorType Color;
			[Group("RandomCanoeColor")] public int Weight;
			[Group("RandomCanoeColor"), HideLabel, DisplayAsString] public string Percent;
		}

		[DeclareHorizontalGroup("RandomPeople")]
		[Serializable]
		private class RandomPeople
		{
			[Group("RandomPeople")] public ColorType Color = ColorType._0None;
			[Group("RandomPeople")] public int Weight;
			[Group("RandomPeople"), HideLabel, DisplayAsString] public string Percent;
		}
	}
}