import std.digest.murmurhash;
import std.digest.sha;
import core.cpuid;
import std.algorithm.comparison;
import std.stdio;

// read the file, hash it, return the hash
// reading is performed with the read() method in std.file
// based on architecture, use the optimal MurmurHash3
// TODO this operation can be expensive, optimize it (for large files)
// TODO find a way to detect ARM architecture
ubyte[] fileHash (string fileName) {
	File file = File (fileName);
	MurmurHash3!(128, 64) hash64;
	MurmurHash3!(128, 32) hash32;
	//SHA256 hash32;
	bool amd64 = isX86_64();
	ubyte [] res;

	foreach (buffer; file.byChunk(512)) {
		if (amd64) {
			hash64.put(buffer);
		} else {
			hash32.put(buffer);
		}
	}
	if (amd64) {
		res = hash64.finish();
	} else {
		res = hash32.finish();
	}
	return res;
}

// use std.algorithm.comparison.equal
// compare the two hashes element by element
bool hashesEqual (ubyte[] hash1, ubyte[] hash2) {
	return equal(hash1, hash2); 
}
