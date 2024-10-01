using DG.Tweening;
using Fiber.Managers;
using GamePlay.Canoes;
using Lofelt.NiceVibrations;
using TriInspector;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using Utilities;

namespace GamePlay
{
	public class Person : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
	{
		public static Person SelectedPerson;

		public bool IsMoving { get; set; }
		public CanoeSlot CurrentSlot { get; private set; }
		public ColorType ColorType { get; private set; }

		[Title("References")]
		[SerializeField] private Renderer[] renderers;

		[Title("Parameters")]
		[SerializeField] private float jumpDuration = .5f;

		private const float HIGHLIGHT_DURATION = .25f;
		private const float HIGHLIGHT_SCALE = 1.25f;

		public static event UnityAction<Person> OnPersonTapped;

		public void Setup(ColorType colorType, CanoeSlot canoeSlot)
		{
			ColorType = colorType;

			CurrentSlot = canoeSlot;
			ChangeMaterial(GameManager.Instance.ColorsSO.PeopleMaterials[ColorType]);
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

		public Tween Jump()
		{
			return transform.DOLocalJump(Vector3.zero, 1, 1, jumpDuration);
		}

		#region Inputs

		public void OnTap()
		{
			transform.DOComplete();
			HideHighlight();

			LevelManager.Instance.CurrentLevel.TotalMoveCount++;

			OnPersonTapped?.Invoke(this);

			HapticManager.Instance.PlayHaptic(HapticPatterns.PresetType.RigidImpact);
		}

		public void OnPointerDown(PointerEventData eventData)
		{
			if (!Player.Player.Instance.CanInput) return;
			if (IsMoving) return;

			SelectedPerson = this;

			Highlight();
		}

		public void OnPointerUp(PointerEventData eventData)
		{
			if (!Player.Player.Instance.CanInput) return;
			if (!SelectedPerson) return;
			if (IsMoving) return;

			if (eventData.pointerEnter && !eventData.pointerEnter.Equals(SelectedPerson.gameObject))
			{
				HideHighlight();
			}
			else if (eventData.pointerEnter)
			{
				if (CurrentSlot)
				{
					SelectedPerson = null;
					return;
				}

				OnTap();
			}
			else
			{
				HideHighlight();
			}

			SelectedPerson = null;
		}

		#endregion

		#region Highlights

		public void Highlight()
		{
			transform.DOComplete();
			transform.DOScale(HIGHLIGHT_SCALE, HIGHLIGHT_DURATION).SetEase(Ease.OutBack);
		}

		public void HideHighlight()
		{
			transform.DOKill();
			transform.DOScale(1, HIGHLIGHT_DURATION).SetEase(Ease.InBack).OnKill(() => { transform.localScale = Vector3.one; });
		}

		#endregion
	}
}