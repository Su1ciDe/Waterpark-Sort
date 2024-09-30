using System.Collections.Generic;
using Fiber.Managers;
using TriInspector;
using UnityEngine;
using Utilities;

namespace GamePlay.Canoes
{
	public class Canoe : MonoBehaviour
	{
		[field: Title("Properties")]
		[field: SerializeField, ReadOnly] public CanoeType CanoeType { get; private set; }
		[field: SerializeField, ReadOnly] public Vector2 Size { get; private set; }

		public ColorType ColorType { get; private set; }

		[Title("References")]
		[SerializeField] private CanoeSlot[] canoeSlots;
		[SerializeField] private Renderer[] renderers;

		public void Setup(ColorType colorType, List<ColorType> peopleColors)
		{
			ColorType = colorType;

			ChangeMaterial(GameManager.Instance.ColorsSO.CanoeMaterials[ColorType]);
		}

		private void ChangeMaterial(Material material)
		{
			for (var i = 0; i < renderers.Length; i++)
			{
				var tempMats = renderers[i].materials;
				tempMats[0] = material;
				renderers[i].materials = tempMats;
			}
		}
	}
}