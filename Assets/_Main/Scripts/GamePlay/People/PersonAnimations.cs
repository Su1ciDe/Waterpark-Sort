using Fiber.Animation;
using UnityEngine;

namespace GamePlay.People
{
	public class PersonAnimations : AnimationController
	{
		private void Start()
		{
			RandomSitSpeed();
		}

		public void Sit()
		{
			SetBool(AnimationType.Sit, true);
		}

		public void StandUp()
		{
			SetBool(AnimationType.Sit, false);
		}

		public void RandomSitSpeed()
		{
			SetFloat(AnimationType.SitSpeed, Random.Range(0.75f, 1.25f));
		}

		public void Jump()
		{
			SetBool(AnimationType.Jump, true);
		}

		public void StopJump()
		{
			SetBool(AnimationType.Jump, false);
		}
	}
}