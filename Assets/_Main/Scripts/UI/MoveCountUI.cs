using DG.Tweening;
using Fiber.LevelSystem;
using TMPro;
using UnityEngine;

namespace UI
{
	public class MoveCountUI : MonoBehaviour
	{
		[SerializeField] private TMP_Text txtMoveCount;

		private void Awake()
		{
			Level.OnMoveCountChanged += OnMoveCountChanged;
		}

		private void OnDestroy()
		{
			Level.OnMoveCountChanged -= OnMoveCountChanged;
		}

		private void OnMoveCountChanged(int moveCount)
		{
			ChangeText(moveCount);
		}

		public void ChangeText(int moveCount)
		{
			txtMoveCount.SetText(moveCount.ToString());

			txtMoveCount.transform.DOComplete();
			txtMoveCount.transform.DOPunchScale(.9f * Vector3.one, .2f, 2, .5f);
		}
	}
}