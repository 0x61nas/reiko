import java.util.Objects;

public abstract class Person {
	private static final long serialVersionUID = 2L;
	protected String firstName;
	protected String lastName;
	protected short age;
	int favNum = -73;

	public abstract byte[] think();

	// Constructors
	public Person() {
	}

	public Person(String firstName, String lastName) {
		this.firstName = firstName;
		this.lastName = lastName;
	}

	public Person(String firstName, String lastName, short age) {
		this.firstName = firstName;
		this.lastName = lastName;
		this.age = age;
	}

	// Getters and Setters
	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(final String firstName) {
		this.firstName = firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(final String lastName) {
		this.lastName = lastName;
	}

	public short getAge() {
		return age;
	}

	public void setAge(short age) {
		this.age = age;
	}

	// Standard overloads
	@Override
	public boolean equals(Object o) {
		if (this == o)
			return true;
		if (o == null || getClass() != o.getClass())
			return false;
		Person person = (Person) o;
		return age == person.age &&
				Objects.equals(firstName, person.firstName) &&
				Objects.equals(lastName, person.lastName);
	}

	@Override
	public int hashCode() {
		return Objects.hash(firstName, lastName, age);
	}

	@Override
	public String toString() {
		return "Person{" +
				"firstName='" + firstName + '\'' +
				", lastName='" + lastName + '\'' +
				", age=" + age +
				'}';
	}

	public static abstract class Builder<T extends Person, B extends Builder<T, B>> {
		protected String firstName;
		protected String lastName;
		protected short age;

		public B firstName(String firstName) {
			this.firstName = firstName;
			return self();
		}

		public B lastName(String lastName) {
			this.lastName = lastName;
			return self();
		}

		public B age(short age) {
			this.age = age;
			return self();
		}

		protected abstract T build();

		protected abstract B self();
	}
}
