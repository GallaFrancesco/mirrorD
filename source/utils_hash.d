import std.digest.sha;
import std.digest.crc;
import std.digest.murmurhash;
import std.stdio;
import core.cpuid;
import parseconfig;

// to select the hashing algorithm
string[] digestAlgorithms = [ "sha1", "sha256", "crc32", "mmhash"];

// read the file, hash it, return the hash
// reading is performed with the f.byChunk() method in std.file
// TODO this operation can be expensive, optimize it / make it parallel (for large files)
// note that large files and sha256 means a LOT of time spent computing
// TODO find a way to detect ARM architecture
string _fHash (Hash)(string fileName) {
	assert (isDigest!Hash);
	File f = File(fileName);

	// Hashing both name and file, to avoid having the same Hash on empty files
	string nameRes = toHexString(digest!Hash(fileName));
	// the file is read in chunks
	string res = toHexString(digest!Hash(f.byChunk(4096*1024)));

	// the result is a concatenated string
	return nameRes ~ res;
}

string fileHash (string fileName, string dig) {
	// read from config the dig algorithm, choose on it
	if (dig == "sha1"){
	 	return _fHash!SHA1(fileName);
	} else if ( dig == "crc32") {
		return _fHash!CRC32(fileName);
	} else if ( dig == "mmhash") {

		if ( isX86_64()) {
			return _fHash!(MurmurHash3!(128, 64))(fileName);
		} else {
			return _fHash!(MurmurHash3!(128, 32))(fileName);
		}

	} else {
		return _fHash!SHA256(fileName);
	}
}

// compare the two hashes element by element
bool hashesEqual (string hash1, string hash2) {
	return hash1 == hash2;
}

unittest {
	import std.file;
	import args : parseArgsWithConfigFile;

	string cwd = getcwd();
	string testfile = cwd ~ "/test/testfile";
	File f = File (testfile);
	writeln(testfile);

	string getHash (string dig) {
		return fileHash(testfile, dig);
	}
	// simply equates two strings
	assert (hashesEqual("aaaa","aaaa"));

	// dig is the command line buffer, setting it and testing fileHash functionality
	string dig = "sha1";
	assert (hashesEqual( getHash(dig), _fHash!SHA1(testfile)));

	dig = "sha256";
	assert (hashesEqual( getHash(dig), _fHash!SHA256(testfile)));

	dig = "crc32";
	assert (hashesEqual( getHash(dig), _fHash!CRC32(testfile)));

	dig = "mmhash";
	if (isX86_64()) {
		assert (hashesEqual( getHash(dig), _fHash!(MurmurHash3!(128,64))(testfile)));
	} else {
		assert (hashesEqual( getHash(dig), _fHash!(MurmurHash3!(128,32))(testfile)));
	}
}
