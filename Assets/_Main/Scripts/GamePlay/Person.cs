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
		public bool CanInteract { get; set; }
		public CanoeSlot CurrentSlot { get; private set; }
		public ColorType ColorType { get; private set; }

		[Title("References")]
		[SerializeField] private Renderer[] renderers;

		[Title("Parameters")]
		[SerializeField] private float jumpDuration = .5f;
		[SerializeField] private float jumpHeight = 1;

		private const float HIGHLIGHT_DURATION = .2f;
		private const float HIGHLIGHT_SCALE = 1.2f;

		public static event UnityAction<Person> OnPersonTapped;

		private void OnEnable()
		{
			LevelManager.OnLevelStart += OnLevelStarted;
		}

		private void OnDisable()
		{
			LevelManager.OnLevelStart -= OnLevelStarted;
		}

		private void OnDestroy()
		{
			transform.DOKill();
		}

		private void OnLevelStarted()
		{
			if (CurrentSlot)
			{
				SetInteractable(true);
			}
		}

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

		public void Swap()
		{
			Player.Player.Instance.CanInput = false;

			var personInHolder = Holder.Instance.CurrentPerson;
			Holder.Instance.SetPerson(this);
			CurrentSlot.SetPerson(personInHolder);
			personInHolder.CurrentSlot = CurrentSlot;

			SetInteractable(false);
			personInHolder.SetInteractable(true);

			Jump().onComplete += () => { };
			personInHolder.Jump().onComplete += () =>
			{
				Player.Player.Instance.CanInput = true;
				OnJumpedToCanoe();

				if (personInHolder.CurrentSlot.Canoe.IsCompleted)
				{
					personInHolder.SetInteractable(false);
				}
			};

			CurrentSlot = null;
		}

		public Tween Jump()
		{
			IsMoving = true;
			return transform.DOLocalJump(Vector3.zero, jumpHeight, 1, jumpDuration).OnComplete(() => IsMoving = false);
		}

		public Tween JumpTo(Vector3 position)
		{
			IsMoving = true;
			return transform.DOJump(position, jumpHeight, 1, jumpDuration).OnComplete(() => IsMoving = false);
		}

		private void OnJumpedToCanoe()
		{
		}

		public void SetInteractable(bool isInteractable)
		{
			CanInteract = isInteractable;
		}

		#region Inputs

		public void OnTap()
		{
			transform.DOComplete();
			HideHighlight();

			LevelManager.Instance.CurrentLevel.TotalMoveCount++;

			Swap();
			OnPersonTapped?.Invoke(this);

			HapticManager.Instance.PlayHaptic(HapticPatterns.PresetType.RigidImpact);
		}

		public void OnPointerDown(PointerEventData eventData)
		{
			if (!Player.Player.Instance.CanInput) return;
			if (!CanInteract) return;
			if (IsMoving) return;

			SelectedPerson = this;

			Highlight();
		}

		public void OnPointerUp(PointerEventData eventData)
		{
			if (!Player.Player.Instance.CanInput) return;
			if (!SelectedPerson) return;
			if (!CanInteract) return;
			if (IsMoving) return;

			if (eventData.pointerEnter && !eventData.pointerEnter.Equals(SelectedPerson.gameObject))
			{
				HideHighlight();
			}
			else if (eventData.pointerEnter)
			{
				if (!CurrentSlot)
				{
					HideHighlight();
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