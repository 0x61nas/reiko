public class ConstantPoolStressTest {

	// Primitive type constants
	public static final byte MIN_BYTE = Byte.MIN_VALUE;
	public static final byte MAX_BYTE = Byte.MAX_VALUE;
	public static final short MIN_SHORT = Short.MIN_VALUE;
	public static final short MAX_SHORT = Short.MAX_VALUE;
	public static final int MIN_INT = Integer.MIN_VALUE;
	public static final int MAX_INT = Integer.MAX_VALUE;
	public static final long MIN_LONG = Long.MIN_VALUE;
	public static final long MAX_LONG = Long.MAX_VALUE;
	public static final float MIN_FLOAT = Float.MIN_VALUE;
	public static final float MAX_FLOAT = Float.MAX_VALUE;
	public static final float POS_INF_FLOAT = Float.POSITIVE_INFINITY;
	public static final float NEG_INF_FLOAT = Float.NEGATIVE_INFINITY;
	public static final float NAN_FLOAT = Float.NaN;
	public static final double MIN_DOUBLE = Double.MIN_VALUE;
	public static final double MAX_DOUBLE = Double.MAX_VALUE;
	public static final double POS_INF_DOUBLE = Double.POSITIVE_INFINITY;
	public static final double NEG_INF_DOUBLE = Double.NEGATIVE_INFINITY;
	public static final double NAN_DOUBLE = Double.NaN;
	public static final char MIN_CHAR = Character.MIN_VALUE;
	public static final char MAX_CHAR = Character.MAX_VALUE;
	public static final boolean TRUE = true;
	public static final boolean FALSE = false;

	// String constants - small and large
	public static final String EMPTY_STRING = "";
	public static final String SHORT_STRING = "A";
	public static final String MEDIUM_STRING = "This is a medium length string constant";
	public static final String LONG_STRING = "This is a very long string constant designed to " +
			"test the limits of the constant pool. It contains many characters and should " +
			"be large enough to stress test the string constant handling in the JVM. " +
			"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam auctor, " +
			"nisl eget ultricies tincidunt, nisl nisl aliquam nisl, eget ultricies " +
			"tincidunt nisl nisl aliquam nisl.";
	public static final String UNICODE_STRING = "Unicode: \u03A9\u2211\uD83D\uDE00\u20AC";

	// Class and type descriptors
	public static final Class<?> OBJECT_CLASS = Object.class;
	public static final Class<?> STRING_CLASS = String.class;
	public static final Class<?> INTEGER_CLASS = Integer.class;
	public static final Class<?> PRIMITIVE_INT_CLASS = int.class;
	public static final Class<?> PRIMITIVE_VOID_CLASS = void.class;
	public static final Class<?> ARRAY_CLASS = int[].class;
	public static final Class<?> MULTI_ARRAY_CLASS = int[][][].class;

	// Method type descriptors
	public static final String VOID_METHOD_DESC = "()V";
	public static final String INT_METHOD_DESC = "()I";
	public static final String STRING_METHOD_DESC = "()Ljava/lang/String;";
	public static final String COMPLEX_METHOD_DESC = "(ILjava/lang/String;[D)[Ljava/lang/Object;";

	// Field descriptors
	public static final String INT_FIELD_DESC = "I";
	public static final String OBJECT_FIELD_DESC = "Ljava/lang/Object;";
	public static final String ARRAY_FIELD_DESC = "[J";

	// Method handles and invokedynamic constants (Java 7+)
	// These would typically be generated with ASM or similar, but we'll include
	// some examples

	// Large array constants
	public static final int[] SMALL_INT_ARRAY = { 1, 2, 3 };
	public static final int[] MEDIUM_INT_ARRAY = {
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
			11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
			21, 22, 23, 24, 25, 26, 27, 28, 29, 30
	};
	public static final int[] LARGE_INT_ARRAY = new int[1000];
	static {
		for (int i = 0; i < LARGE_INT_ARRAY.length; i++) {
			LARGE_INT_ARRAY[i] = i;
		}
	}

	// Enum constants
	public enum TestEnum {
		SMALL, MEDIUM, LARGE, EXTRA_LARGE,
		VALUE1, VALUE2, VALUE3, VALUE4, VALUE5,
		A, B, C, D, E, F, G, H, I, J, K, L, M,
		N, O, P, Q, R, S, T, U, V, W, X, Y, Z
	}

	// Annotation with various values
	@Deprecated
	@SuppressWarnings({ "unchecked", "rawtypes", "serial" })
	public void annotatedMethod() {
	}

	// Method with many constants
	public String methodWithManyConstants(int x) {
		switch (x) {
			case 0:
				return "zero";
			case 1:
				return "one";
			case 2:
				return "two";
			case 3:
				return "three";
			case 4:
				return "four";
			case 5:
				return "five";
			case 6:
				return "six";
			case 7:
				return "seven";
			case 8:
				return "eight";
			case 9:
				return "nine";
			case 10:
				return "ten";
			default:
				return "many";
		}
	}
	// Many string concatenations (Java 8+ string concatenation in constant pool)
	public String manyStringConcats() {
		return "part1" + "part2" + "part3" + "part4" + "part5" +
				"part6" + "part7" + "part8" + "part9" + "part10";
	}

	// Main method to test loading the class
	public static void main(String[] args) {
		System.out.println("ConstantPoolStressTest loaded successfully!");
		System.out.println("LONG_STRING length: " + LONG_STRING.length());
		System.out.println("LARGE_INT_ARRAY length: " + LARGE_INT_ARRAY.length);
		System.out.println("Enum values count: " + TestEnum.values().length);
	}
}
