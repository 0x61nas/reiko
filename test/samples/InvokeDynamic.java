public class InvokeDynamic {
	public static void main(String[] args) {
		final var s1 = "A";
		final var s2 = "bb";
		final var s3 = "gg";
		var all = s1 + s2 + s3;
		all = all + "test";
		System.out.println(all);
	}
}
