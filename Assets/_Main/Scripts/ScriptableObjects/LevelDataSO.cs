using System;
using System.Linq;
using System.Collections.Generic;
using AYellowpaper.SerializedCollections;
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
		public int MaxHolderLength = 24;
		public ColorType PersonInTheHolder = ColorType._0None;
		[OnValueChanged(nameof(SetupEditor)), ListDrawerSettings(ShowElementLabels = true)]
		public CanoeEditor[] SpawningCanoes;

		[SerializeField, ReadOnly] private List<PeopleCount> peopleCounts = new List<PeopleCount>();

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

			var peopleColors = randomPeople.Select(x => x.Color).ToList();
			var peopleColorWeights = randomPeople.Select(x => x.Weight).ToList();

			for (int i = 0; i < randomCanoeCount; i++)
			{
				SpawningCanoes[i] = new CanoeEditor
				{
					CanoeType = canoeTypes.WeightedRandom(canoeTypeWeights), CanoeColor = canoeColors.WeightedRandom(canoeColorWeights), PeopleColors = new List<ColorTypeEditor>()
				};
			}

			var peopleCount = CalculateRandomPeopleColors();

			for (int i = 0; i < randomCanoeCount; i++)
			{
				for (int j = 0; j < (int)SpawningCanoes[i].CanoeType; j++)
				{
					var selectedColor = peopleColors.WeightedRandom(peopleColorWeights);
					SpawningCanoes[i].PeopleColors.Add(new ColorTypeEditor(selectedColor));

					peopleCount[selectedColor]--;
					if (peopleCount[selectedColor].Equals(0))
					{
						var index = peopleColors.IndexOf(selectedColor);
						peopleColors.RemoveAt(index);
						peopleColorWeights.RemoveAt(index);
					}
				}
			}
		}

		private Dictionary<ColorType, int> CalculateRandomPeopleColors()
		{
			var randomPeopleColors = new Dictionary<ColorType, int>();
			foreach (var spawningCanoe in SpawningCanoes)
			{
				if (!randomPeopleColors.TryAdd(spawningCanoe.CanoeColor, (int)spawningCanoe.CanoeType))
					randomPeopleColors[spawningCanoe.CanoeColor] += (int)spawningCanoe.CanoeType;
			}

			return randomPeopleColors;
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

		private void CalculatePeopleCount()
		{
			peopleCounts.Clear();

			for (var i = 0; i < SpawningCanoes.Length; i++)
			{
				var canoe = SpawningCanoes[i];
				var selectedEntry = peopleCounts.FirstOrDefault(x => x.ColorType == canoe.CanoeColor);
				if (selectedEntry is not null)
				{
					selectedEntry.NeededCount += (int)canoe.CanoeType;
				}
				else
				{
					peopleCounts.Add(new PeopleCount { ColorType = canoe.CanoeColor, NeededCount = (int)canoe.CanoeType });
				}
			}

			for (var i = 0; i < SpawningCanoes.Length; i++)
			{
				var canoe = SpawningCanoes[i];

				for (int j = 0; j < canoe.PeopleColors.Count; j++)
				{
					var selectedEntry = peopleCounts.FirstOrDefault(x => x.ColorType == canoe.PeopleColors[j].PeopleColor);
					if (selectedEntry is not null)
					{
						selectedEntry.CurrentCount++;
					}
				}
			}

			for (int i = 0; i < peopleCounts.Count; i++)
			{
				peopleCounts[i].IsOk = peopleCounts[i].NeededCount.Equals(peopleCounts[i].CurrentCount) ? "✔︎" : "✖︎";
			}
		}

		private void OnValidate()
		{
			SetupEditor();

			CalculatePeopleCount();

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
					spawningCanoe.PeopleColors = new List<ColorTypeEditor>((int)spawningCanoe.CanoeType);
					for (int i = 0; i < (int)spawningCanoe.CanoeType; i++)
						spawningCanoe.PeopleColors.Add(new ColorTypeEditor(ColorType._0None));
				}
				else if (spawningCanoe.PeopleColors.Count < (int)spawningCanoe.CanoeType)
				{
					for (int i = spawningCanoe.PeopleColors.Count; i < (int)spawningCanoe.CanoeType; i++)
						spawningCanoe.PeopleColors.Add(new ColorTypeEditor(ColorType._0None));
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
			[Group("Canoe"), GUIColor("$GetColor")] public ColorType CanoeColor;
			[ListDrawerSettings(HideAddButton = true, HideRemoveButton = true)]
			[Group("Canoe")] public List<ColorTypeEditor> PeopleColors;

			private Color GetColor
			{
				get
				{
					var color = CanoeColor switch
					{
						ColorType._0None => Color.white,
						ColorType._1Blue => Color.blue,
						ColorType._2Green => Color.green,
						ColorType._3Orange => new Color(1f, 0.5f, 0),
						ColorType._4Pink => Color.magenta,
						ColorType._5Purple => new Color(.7f, .25f, 1f),
						ColorType._6Red => Color.red,
						ColorType._7Yellow => Color.yellow,
						_ => throw new ArgumentOutOfRangeException()
					};

					return color;
				}
			}
		}

		[Serializable]
		public class ColorTypeEditor
		{
			[GUIColor("$GetColor")] public ColorType PeopleColor;

			public ColorTypeEditor(ColorType peopleColor)
			{
				PeopleColor = peopleColor;
			}

			private Color GetColor
			{
				get
				{
					var color = PeopleColor switch
					{
						ColorType._0None => Color.white,
						ColorType._1Blue => Color.blue,
						ColorType._2Green => Color.green,
						ColorType._3Orange => new Color(1f, 0.5f, 0),
						ColorType._4Pink => Color.magenta,
						ColorType._5Purple => new Color(.7f, .25f, 1f),
						ColorType._6Red => Color.red,
						ColorType._7Yellow => Color.yellow,
						_ => throw new ArgumentOutOfRangeException()
					};

					return color;
				}
			}
		}

		[DeclareHorizontalGroup("People")]
		[Serializable]
		private class PeopleCount
		{
			[Group("People"), GUIColor("$GetPeopleColor")] public ColorType ColorType;
			[Group("People")] public int NeededCount;
			[Group("People")] public int CurrentCount;

			[Group("People"), HideLabel, GUIColor("$GetColor")] public string IsOk;

			private Color GetColor
			{
				get
				{
					var color = IsOk switch
					{
						"✖︎" => Color.red,
						"✔︎" => Color.green,
						_ => throw new ArgumentOutOfRangeException()
					};

					return color;
				}
			}

			private Color GetPeopleColor
			{
				get
				{
					var color = ColorType switch
					{
						ColorType._0None => Color.white,
						ColorType._1Blue => Color.blue,
						ColorType._2Green => Color.green,
						ColorType._3Orange => new Color(1f, 0.5f, 0),
						ColorType._4Pink => Color.magenta,
						ColorType._5Purple => new Color(.7f, .25f, 1f),
						ColorType._6Red => Color.red,
						ColorType._7Yellow => Color.yellow,
						_ => throw new ArgumentOutOfRangeException()
					};

					return color;
				}
			}
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