import std.digest.sha;
import std.stdio;

// read the file, hash it, return the hash
// reading is performed with the f.byChunk() method in std.file
// TODO this operation can be expensive, optimize it (for large files)
// TODO find a way to detect ARM architecture
string fileHash (string fileName) {
	File f = File(fileName);
	// hashing both name and file, to avoid having the same hash on empty files
	string nameRes = toHexString(sha1Of(fileName));
	string res = toHexString(sha1Of(f.byChunk(4096*1024)));
	return nameRes ~ res;
}

// compare the two hashes element by element
bool hashesEqual (string hash1, string hash2) {
	return hash1 == hash2;
}
