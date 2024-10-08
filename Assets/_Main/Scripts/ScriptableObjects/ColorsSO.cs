using AYellowpaper.SerializedCollections;
using UnityEngine;
using Utilities;

namespace ScriptableObjects
{
	[CreateAssetMenu(menuName = "Waterpark Sort/Colors", fileName = "Colors", order = 2)]
	public class ColorsSO : ScriptableObject
	{
		public SerializedDictionary<ColorType, Material> CanoeMaterials;
		public SerializedDictionary<ColorType, Material> CanoeSeatMaterials;
		public SerializedDictionary<ColorType, Material> PeopleMaterials;
	}
}