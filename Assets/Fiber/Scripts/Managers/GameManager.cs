using Fiber.Utilities;
using ScriptableObjects;
using UnityEngine;

namespace Fiber.Managers
{
	[DefaultExecutionOrder(-1)]
	public class GameManager : SingletonInit<GameManager>
	{
		[SerializeField] private ColorsSO colorsSO;
		public ColorsSO ColorsSO => colorsSO;
		
		[SerializeField] private PrefabsSO prefabsSO;
		public PrefabsSO PrefabsSO => prefabsSO;

		protected override void Awake()
		{
			base.Awake();
			Application.targetFrameRate = 60;
			Debug.unityLogger.logEnabled = Debug.isDebugBuild;
		}
	}
}