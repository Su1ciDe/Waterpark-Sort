using System.Collections.Generic;
using UnityEngine;

namespace GamePlay.Canoes
{
	public class CanoeHolder : MonoBehaviour
	{
		public List<Canoe> Canoes { get; set; } = new List<Canoe>();
		public bool IsFull => Canoes.Count >= MAX_CANOES;

		[SerializeField] private float spacing;

		public const int MAX_CANOES = 3;

		private void OnEnable()
		{
		}

		private void OnDisable()
		{
		}

		private void OnCanoeLeft(Canoe canoe)
		{
			canoe.OnLeave -= OnCanoeLeft;
			Canoes.Remove(canoe);
		}

		public void SetCanoe(Canoe canoe)
		{
			Canoes.Add(canoe);
			canoe.OnLeave += OnCanoeLeft;
		}

		public float GetLength()
		{
			var length = 0f;
			for (var i = 0; i < Canoes.Count; i++)
				length += Canoes[i].Size.y + spacing;

			return length;
		}
	}
}