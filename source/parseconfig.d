import args;

/** The options to the created program. */
static struct ConfigArguments {
	@Arg("Directory to monitor.", 'f') string[] directory = ["./test/testfile"];
	@Arg("Digest algorithm used. [sha1, sha256, crc32, mmhash]", 'd') string digest = "sha256";
	@Arg("Reload timeout.", 't') uint timeout = 10;
	@Arg("Bind addresses list.", 'a') string[] addresses = ["127.0.0.1"];
	@Arg("Server port", 'p') ushort port = 8080;
}

ConfigArguments arguments;

ref ConfigArguments configWriteable() {
	return arguments;
}

ref const(ConfigArguments) config() {
	return arguments;
}

