using System.Collections.Generic;
using DG.Tweening;
using Fiber.Utilities.Extensions;
using PathCreation;
using TriInspector;
using UnityEngine;

namespace GamePlay.Canoes
{
	public class CanoeHolder : MonoBehaviour
	{
		public bool IsAdvancing { get; set; }
		public List<Canoe> Canoes { get; set; } = new List<Canoe>();
		public bool IsFull { get; set; }
		public int CurrentLength { get; set; }
		public int MaxLength { get; private set; }

		[Title("References")]
		[SerializeField] private PathCreator pathCreator;

		[Title("Parameters")]
		[SerializeField] private float spacing;

		// public const int MAX_CANOES = 3;

		public void Setup(int maxLength)
		{
			MaxLength = maxLength;
		}

		private void OnCanoeLeft(Canoe canoe)
		{
			canoe.OnLeave -= OnCanoeLeft;
			Canoes.Remove(canoe);

			canoe.MoveCanoeToWaterfall(pathCreator);
		}

		public void SetCanoe(Canoe canoe)
		{
			Canoes.Add(canoe);
			CurrentLength += canoe.Length;
			
			IsFull = CurrentLength >= MaxLength;
			
			canoe.OnLeave += OnCanoeLeft;
		}

		public float GetLength()
		{
			var length = 0f;
			for (var i = 0; i < Canoes.Count; i++)
				length += Canoes[i].Size.y + spacing;

			return length;
		}

		public void Advance()
		{
			if (IsAdvancing) return;
			IsAdvancing = true;

			Tween tween = null;
			var size = 0f;
			for (var j = 0; j < Canoes.Count; j++)
			{
				var canoe = Canoes[j];
				var pos = transform.position - new Vector3(0, 0, size + canoe.Size.y / 2f);
				if (pos.NotEquals(canoe.transform.position))
				{
					var tempTween = tween = canoe.Move(pos);
					var _j = j;
					tempTween.onComplete += () =>
					{
						if (_j.Equals(0) && canoe.IsCompleted)
						{
							canoe.Leave();
						}
					};
				}

				size += canoe.Size.y + spacing;
			}

			if (tween is not null)
			{
				tween.onComplete += () => { IsAdvancing = false; };
			}
			else
			{
				IsAdvancing = false;
			}
		}
	}
}