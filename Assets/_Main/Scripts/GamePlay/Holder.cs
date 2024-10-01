using Fiber.Managers;
using Fiber.Utilities;
using Utilities;

namespace GamePlay
{
	public class Holder : Singleton<Holder>
	{
		public Person CurrentPerson { get; set; }

		public void Setup(ColorType personColor)
		{
			var person = Instantiate(GameManager.Instance.PrefabsSO.PersonPrefab, transform);
			person.Setup(personColor, null);
		}
	}
}