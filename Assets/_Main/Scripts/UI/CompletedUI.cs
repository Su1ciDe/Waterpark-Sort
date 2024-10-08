using DG.Tweening;
using Fiber.Utilities;
using UnityEngine;

namespace UI
{
	public class CompletedUI : MonoBehaviour
	{
		private const float SCALE = 1.5f;
		private const float SCALE_DURATION = .35F;

		private const float ROTATION = 30F;
		private const float ROTATION_DURATION = .5F;

		public void Spawn()
		{
			transform.DOScale(SCALE, SCALE_DURATION).OnComplete(() => { transform.DOScale(1, SCALE_DURATION); });

			var sign = Helper.RandomMinusOneOrOne();

			transform.DOPunchRotation(sign * ROTATION * transform.forward, ROTATION_DURATION);
		}
	}
}