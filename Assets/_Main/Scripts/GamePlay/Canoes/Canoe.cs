using System.Collections.Generic;
using DG.Tweening;
using Fiber.Managers;
using TriInspector;
using UnityEngine;
using UnityEngine.Events;
using Utilities;

namespace GamePlay.Canoes
{
	public class Canoe : MonoBehaviour
	{
		[field: Title("Properties")]
		[field: SerializeField, ReadOnly] public CanoeType CanoeType { get; private set; }
		[field: SerializeField, ReadOnly] public Vector2 Size { get; private set; }

		[field: SerializeField, ReadOnly] public ColorType ColorType { get; private set; }
		public bool IsCompleted { get; set; }

		[Title("References")]
		[SerializeField] private CanoeSlot[] canoeSlots;
		[SerializeField] private Renderer[] renderers;
		[SerializeField] private Transform model;

		[Title("Parameters")]
		[SerializeField] private float speed = 10;

		public event UnityAction<Canoe> OnLeave;
		public static event UnityAction<Canoe> OnLeaveAny;

		public void Setup(ColorType colorType, List<ColorType> peopleColors)
		{
			ColorType = colorType;

			ChangeMaterial(GameManager.Instance.ColorsSO.CanoeMaterials[ColorType]);

			for (var i = 0; i < canoeSlots.Length; i++)
			{
				var person = Instantiate(GameManager.Instance.PrefabsSO.PersonPrefab, canoeSlots[i].transform);
				person.Setup(peopleColors[i], canoeSlots[i]);
				canoeSlots[i].Setup(this);
				canoeSlots[i].SetPerson(person, true);

				canoeSlots[i].OnPersonSet += OnPersonSet;
			}
		}

		private void OnPersonSet(CanoeSlot slot)
		{
			CheckIfCompleted();
			if (IsCompleted)
			{
				SetInteractablePeople(false);
			}

			//TODO: wait animation to finish
		}

		public void Leave()
		{
			// 
			OnLeave?.Invoke(this);
			OnLeaveAny?.Invoke(this);
		}

		private void CheckIfCompleted()
		{
			for (int i = 0; i < canoeSlots.Length; i++)
			{
				if (canoeSlots[i].CurrentPerson.ColorType != ColorType)
					return;
			}

			IsCompleted = true;
		}

		public void SetInteractablePeople(bool interactable)
		{
			for (int i = 0; i < canoeSlots.Length; i++)
			{
				if (canoeSlots[i].CurrentPerson)
					canoeSlots[i].CurrentPerson.SetInteractable(interactable);
			}
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

		public Tween Move(Vector3 position)
		{
			return transform.DOMove(position, speed).SetEase(Ease.OutSine).SetSpeedBased(true).SetEase(Ease.Linear).OnComplete(OnStoppedMoving);
		}

		private void OnStoppedMoving()
		{
			model.DOLocalRotate(new Vector3(20f, 0, 0), 0.1f).SetEase(Ease.InOutSine).SetRelative().SetLoops(2, LoopType.Yoyo);
		}
	}
}