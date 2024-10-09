using Fiber.Managers;
using Fiber.Utilities;
using GamePlay.People;
using Utilities;

namespace GamePlay
{
	public class Holder : Singleton<Holder>
	{
		public Person CurrentPerson { get; private set; }

		public void Setup(ColorType personColor)
		{
			var person = Instantiate(GameManager.Instance.PrefabsSO.PersonPrefab, transform);
			person.Setup(personColor, null);
			CurrentPerson = person;
		}

		public void SetPerson(Person person)
		{
			CurrentPerson = person;
			CurrentPerson.transform.SetParent(transform);
		}
	}
}