using Fiber.Utilities;
using UnityEngine;

namespace GamePlay
{
	public class Holder : Singleton<Holder>
	{
		public Person CurrentPerson { get; set; }
	}
}