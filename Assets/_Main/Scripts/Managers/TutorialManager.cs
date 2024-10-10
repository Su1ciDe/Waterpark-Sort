using System.Collections;
using Fiber.Managers;
using Fiber.UI;
using Fiber.Utilities;
using GamePlay.Player;
using UI;
using UnityEngine;

namespace Managers
{
	public class TutorialManager : MonoBehaviour
	{
		private TutorialUI tutorialUI => TutorialUI.Instance;

		private void OnEnable()
		{
			LevelManager.OnLevelStart += OnLevelStarted;
			LevelManager.OnLevelUnload += OnLevelUnloaded;
		}

		private void OnDisable()
		{
			LevelManager.OnLevelStart -= OnLevelStarted;
			LevelManager.OnLevelUnload -= OnLevelUnloaded;
		}

		private void OnDestroy()
		{
			Unsub();
		}

		private void OnLevelUnloaded()
		{
			Unsub();
		}

		private void OnLevelStarted()
		{
			if (LoadingPanelController.Instance && LoadingPanelController.Instance.IsActive)
			{
				StartCoroutine(WaitLoadingScreen());
			}
			else
			{
				LevelStart();
			}
		}

		private void Unsub()
		{
			StopAllCoroutines();

			if (TutorialUI.Instance)
			{
				tutorialUI.HideFocus();
				tutorialUI.HideHand();
				tutorialUI.HideText();
				tutorialUI.HideFakeButton();
			}
		}

		private IEnumerator WaitLoadingScreen()
		{
			yield return new WaitUntilAction(ref LoadingPanelController.Instance.OnLoadingFinished);

			LevelStart();
		}

		private void LevelStart()
		{
			if (LevelManager.Instance.LevelNo.Equals(1))
			{
				StartCoroutine(Level1Tutorial());
			}

			if (LevelManager.Instance.LevelNo.Equals(2))
			{
				StartCoroutine(Level2Tutorial());
			}
		}

		#region Level 1

		private IEnumerator Level1Tutorial()
		{
			Player.Instance.CanInput = false;
			tutorialUI.SetBlocker(true);

			yield return new WaitForSeconds(0.5f);
			Player.Instance.CanInput = false;

			var person = CanoeManager.Instance.Holders[0].Canoes[0].Slots[3].CurrentPerson;
			var personPos = person.transform.position;

			tutorialUI.ShowText("Tap a person to swap!");
			tutorialUI.ShowTap(personPos, Helper.MainCamera);
			tutorialUI.ShowFocus(personPos, Helper.MainCamera);
			tutorialUI.SetupFakeButton(() =>
			{
				person.OnTap();
				StartCoroutine(Level1Tutorial_2());
			}, personPos, Helper.MainCamera);
		}

		private IEnumerator Level1Tutorial_2()
		{
			tutorialUI.HideFocus();
			tutorialUI.HideHand();
			tutorialUI.HideText();
			tutorialUI.HideFakeButton();

			yield return new WaitForSeconds(1);

			var person = CanoeManager.Instance.Holders[1].Canoes[0].Slots[2].CurrentPerson;
			var personPos = person.transform.position;

			tutorialUI.ShowText("Match colors with the canoe!");
			tutorialUI.ShowTap(personPos, Helper.MainCamera);
			tutorialUI.ShowFocus(personPos, Helper.MainCamera);
			tutorialUI.SetupFakeButton(() =>
			{
				person.OnTap();
				StartCoroutine(Level1Tutorial_3());
			}, personPos, Helper.MainCamera);
		}

		private IEnumerator Level1Tutorial_3()
		{
			tutorialUI.HideFocus();
			tutorialUI.HideHand();
			tutorialUI.HideText();
			tutorialUI.HideFakeButton();

			yield return new WaitForSeconds(1);

			var moveCountUI = UIManager.Instance.GetComponentInChildren<MoveCountUI>();

			tutorialUI.ShowText("Finish before your moves run out!");
			tutorialUI.ShowFocus(moveCountUI.transform.position);

			yield return new WaitForSeconds(3);

			tutorialUI.HideFocus();
			tutorialUI.HideText();

			Player.Instance.CanInput = true;
			tutorialUI.SetBlocker(false);
		}

		#endregion

		#region Level 2

		private IEnumerator Level2Tutorial()
		{
			Player.Instance.CanInput = false;
			tutorialUI.SetBlocker(true);

			yield return new WaitForSeconds(0.5f);
			Player.Instance.CanInput = false;
		}

		#endregion
	}
}