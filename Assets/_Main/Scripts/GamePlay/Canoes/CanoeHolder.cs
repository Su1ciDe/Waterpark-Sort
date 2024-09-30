using System.Collections.Generic;
using UnityEngine;

namespace GamePlay.Canoes
{
	public class CanoeHolder : MonoBehaviour
	{
		public List<Canoe> Canoes { get; set; } = new List<Canoe>();

		[SerializeField] private float spacing;
		
		private const int MAX_CANOES = 3;
	}
}