import args;

/** The options to the created program. */
static struct ConfigArguments {
	@Arg("The directory to monitor.", 'f') string directory = "./test/testfile";
	@Arg("The digest algorithm used. Defaults to sha256.\nPossible values are: sha1, sha256, crc32, mmhash", 'd') string digest = "sha256";
}

ConfigArguments arguments;

ref ConfigArguments configWriteable() {
	return arguments;
}

ref const(ConfigArguments) config() {
	return arguments;
}

