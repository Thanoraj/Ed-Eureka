package us.zoom.sdksample.initsdk;

public interface AuthConstants {

	// TODO Change it to your web domain
	public final static String WEB_DOMAIN = "zoom.us";

	/**
	 * We recommend that, you can generate jwttoken on your own server instead of hardcore in the code.
	 * We hardcore it here, just to run the demo.
	 *
	 * You can generate a jwttoken on the https://jwt.io/
	 * with this payload:
	 * {
	 *
	 *     "appKey": "string", // app key
	 *     "iat": long, // access token issue timestamp
	 *     "exp": long, // access token expire time
	 *     "tokenExp": long // token expire time
	 * }
	 */
	public final static String SDK_JWTTOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6IktiR3hWRjRoU01hOFk4QlloV2c5WWciLCJleHAiOjE2Mjc5OTA4MDcsImlhdCI6MTYyNzM4NjAwN30.i1jlxmUWzaRtQBLiwnvs1Xvpuay9iPRm3qrNTOr4fwc";
	public final static String SDK_KEY = "e3BIXXaRIxJkfYrlJEmH4wTe3V4fOPZtGlJu";
	public final static String SDK_SECRET = "aTgUvbevgaCQzvE3SF3Kxoz4QeqW77CNI2FQ";

}
