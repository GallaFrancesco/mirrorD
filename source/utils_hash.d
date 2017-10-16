import std.digest.sha;
import std.digest.crc;
import std.digest.murmurhash;
import std.stdio;
import core.cpuid;
import parseconfig;

// to select the hashing algorithm
private string[] digestAlgorithms = [ "sha1", "sha256", "crc32", "mmhash"];

// read the file, hash it, return the hash
// reading is performed with the f.byChunk() method in std.file
// TODO this operation can be expensive, optimize it (for large files)
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

string fileHash (string fileName) {
	string dig = config().digest;
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
