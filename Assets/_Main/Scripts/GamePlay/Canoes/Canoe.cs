using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using Fiber.Managers;
using Fiber.Utilities;
using Managers;
using PathCreation;
using TriInspector;
using UI;
using UnityEngine;
using UnityEngine.Events;
using Utilities;

namespace GamePlay.Canoes
{
	public class Canoe : MonoBehaviour
	{
		[field: Title("Properties")]
		[field: SerializeField, ReadOnly] public CanoeType CanoeType { get; private set; }
		[field: SerializeField] public Vector2 Size { get; private set; }
		[field: SerializeField] public int Length { get; private set; }
		[field: SerializeField, ReadOnly] public ColorType ColorType { get; private set; }

		public bool IsCompleted { get; private set; }

		[Title("References")]
		[SerializeField] private CanoeSlot[] canoeSlots;
		[SerializeField] private Renderer[] renderers;
		[SerializeField] private Transform model;

		[Title("Parameters")]
		[SerializeField] private float speed = 10;

		private CompletedUI completedUI;
		private const string COMPLETED_POOL_TAG = "Completed";

		public event UnityAction<Canoe> OnLeave;
		public static event UnityAction<Canoe> OnLeaveAny;

		public void Setup(ColorType colorType, List<ColorType> peopleColors)
		{
			ColorType = colorType;

			ChangeMaterial(GameManager.Instance.ColorsSO.CanoeMaterials[ColorType], GameManager.Instance.ColorsSO.CanoeSeatMaterials[ColorType]);

			for (var i = 0; i < canoeSlots.Length; i++)
			{
				var canoeSlot = canoeSlots[i];
				var person = Instantiate(GameManager.Instance.PrefabsSO.PersonPrefab, canoeSlot.transform);
				person.Setup(peopleColors[i], canoeSlot);
				canoeSlot.Setup(this);
				canoeSlot.SetPerson(person, true);

				canoeSlot.OnPersonSet += OnPersonSet;
			}
		}

		private void OnPersonSet(CanoeSlot slot)
		{
			if (IsCompleted) return;

			CheckIfCompleted();
			if (IsCompleted)
			{
				SetInteractablePeople(false);
				StartCoroutine(WaitCanoeLoading());
			}
		}

		private IEnumerator WaitCanoeLoading()
		{
			yield return new WaitUntil(() => !IsAnyPersonMoving());
			yield return null;

			if (IsInFirstLine())
			{
				Leave();
			}
		}

		public void Leave()
		{
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

			Complete();
		}

		private void Complete()
		{
			IsCompleted = true;

			completedUI = ObjectPooler.Instance.Spawn(COMPLETED_POOL_TAG, transform.position + 4 * Vector3.up).GetComponent<CompletedUI>();
			completedUI.Spawn();

			for (var i = 0; i < canoeSlots.Length; i++)
			{
				var person = canoeSlots[i].CurrentPerson;
				person.transform.DOLocalMove(1 * Vector3.up, 0.2f).SetDelay(i * .15f).SetEase(Ease.OutSine).OnComplete(() => person.transform.DOLocalMove(Vector3.zero, .2f).SetEase(Ease.InSine));
			}
		}

		public void SetInteractablePeople(bool interactable)
		{
			for (int i = 0; i < canoeSlots.Length; i++)
			{
				if (canoeSlots[i].CurrentPerson)
					canoeSlots[i].CurrentPerson.SetInteractable(interactable);
			}
		}

		private void ChangeMaterial(Material mainMaterial, Material seatMaterial)
		{
			for (var i = 0; i < renderers.Length; i++)
			{
				var tempMats = renderers[i].materials;
				tempMats[0] = seatMaterial;
				tempMats[1] = mainMaterial;
				renderers[i].materials = tempMats;
			}
		}

		public Tween Move(Vector3 position, bool playStoppingMovement = true)
		{
			SetInteractablePeople(false);
			return transform.DOMove(position, speed).SetEase(Ease.OutSine).SetSpeedBased(true).SetEase(Ease.Linear).OnComplete(() =>
			{
				if (playStoppingMovement)
					OnStoppedMoving();

				SetInteractablePeople(!IsCompleted);
			});
		}

		public void MoveCanoeToWaterfall(PathCreator pathCreator)
		{
			Move(pathCreator.transform.position, false).onComplete += () =>
			{
				StartCoroutine(Waterfall(pathCreator.path));
				if (completedUI)
					ObjectPooler.Instance.Release(completedUI.gameObject, COMPLETED_POOL_TAG);
			};
		}

		private IEnumerator Waterfall(VertexPath path)
		{
			var dist = 0f;
			var pos = transform.position;
			var prevPos = Vector3.zero;
			while (prevPos != pos)
			{
				if (path.GetClosestTimeOnPath(pos) >= 1f) break;

				transform.position = pos;
				transform.rotation = path.GetRotationAtDistance(dist, EndOfPathInstruction.Stop);
				dist += speed * Time.deltaTime;

				yield return null;

				prevPos = pos;
				pos = path.GetPointAtDistance(dist, EndOfPathInstruction.Stop);
			}

			transform.DOScale(0, 1f).OnComplete(() => Destroy(gameObject));

			CanoeManager.Instance.AdvanceLines();
		}

		private void OnStoppedMoving()
		{
			model.DOLocalRotate(new Vector3(10f, 0, 0), 0.15f).SetEase(Ease.InOutSine).SetRelative().SetLoops(2, LoopType.Yoyo);
		}

		public bool IsInFirstLine()
		{
			return CanoeManager.Instance.IsFirstCanoe(this);
		}

		public bool IsAnyPersonMoving()
		{
			for (int i = 0; i < canoeSlots.Length; i++)
			{
				if (canoeSlots[i].CurrentPerson && canoeSlots[i].CurrentPerson.IsMoving)
				{
					return true;
				}
			}

			return false;
		}
	}
}