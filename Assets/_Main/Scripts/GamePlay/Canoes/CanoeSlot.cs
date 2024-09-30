using UnityEngine;

namespace GamePlay.Canoes
{
	public class CanoeSlot : MonoBehaviour
	{
		public Person CurrentPerson { get; private set; }

#if UNITY_EDITOR
		private void OnDrawGizmos()
		{
			Gizmos.color = Color.yellow;
			Gizmos.DrawWireCube(transform.position + 1f * Vector3.up, new Vector3(1, 2, 1));
		}
#endif
	}
}