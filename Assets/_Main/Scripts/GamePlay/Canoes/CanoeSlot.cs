using UnityEngine;
using UnityEngine.Events;

namespace GamePlay.Canoes
{
	public class CanoeSlot : MonoBehaviour
	{
		public Person CurrentPerson { get; private set; }
		public Canoe Canoe { get; private set; }

		public event UnityAction<CanoeSlot> OnPersonSet;

		public void Setup(Canoe canoe)
		{
			Canoe = canoe;
		}

		public void SetPerson(Person person, bool setPosition = false)
		{
			CurrentPerson = person;
			CurrentPerson.transform.SetParent(transform, !setPosition);
			// if (setPosition)
			// {
			// 	setPosition
			// }

			OnPersonSet?.Invoke(this);
		}

		public void SetPersonPosition()
		{
			CurrentPerson.transform.localPosition = Vector3.zero;
			CurrentPerson.transform.localRotation = Quaternion.identity;
		}

#if UNITY_EDITOR
		private void OnDrawGizmos()
		{
			Gizmos.color = Color.yellow;
			Gizmos.DrawWireCube(transform.position + 1f * Vector3.up, new Vector3(1, 2, 1));
		}
#endif
	}
}