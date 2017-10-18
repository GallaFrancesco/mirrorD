import std.digest.sha;
import std.digest.crc;
import std.digest.murmurhash;
import std.algorithm : canFind;
import std.stdio;
import core.cpuid;
import parseconfig;
import std.parallelism;

// to select the hashing algorithm
string[] digestAlgorithms = [ "sha1", "sha256", "crc32", "mmhash"];

// passed to the worker thread as a parameter
struct HashParameters {
	string filename;
	string digest;
}

// synchronized means that only one thread
// has access to this class at a time


// read the file, hash it, return the hash
// reading is performed with the f.byChunk() method in std.file
// TODO this operation can be expensive, optimize it / make it parallel (for large files)
// note that large files and sha256 means a LOT of time spent computing
// TODO find a way to detect ARM architecture

string produceHash(Hash)(string filename){
	File f = File(filename);
	// Hashing both name and file, to avoid having the same Hash on empty files
	string hname = toHexString(digest!Hash(filename));
	// the file is read in chunks
	string h = toHexString(digest!Hash(f.byChunk(4096*1024)));
	// the result is a concatenated string
	return hname ~ h;
}

// PERFORMED IN ANOTHER THREAD (wrt fileHash)
// determine the correct digest algorithm
// call produceHash
// send the obtained hash to the parend process
string _fHash (HashParameters hp) {
	assert (digestAlgorithms.canFind(hp.digest));
	string hash;
	if (hp.digest == "sha1"){
	 	hash = produceHash!SHA1(hp.filename);
	} else if ( hp.digest == "crc32") {
		hash = produceHash!CRC32(hp.filename);
	} else if ( hp.digest == "mmhash") {
		if ( isX86_64()) {
			hash = produceHash!(MurmurHash3!(128, 64))(hp.filename);
		} else {
			hash = produceHash!(MurmurHash3!(128, 32))(hp.filename);
		}
	} else {
		hash = produceHash!SHA256(hp.filename);
	}
	// send the computed hash to the parent
	return hash;
}

// takes a file and a digest identifier,
// puts them in a struct which can be passed to a worker
// a worker is a thread, the function communicates with it
void fileHash (string[string] hashes, string dig) {

	//Task[string] tasks;
	int cnt = 0;
	foreach (string filename; parallel(hashes.keys)){
		HashParameters hp = HashParameters(filename, dig);
		hashes[filename] = _fHash(hp);	
		//tasks[filename] = task!_fHash(hp);
		//tasks[filename].executeInNewThread();
	}

	//foreach (string filename; hashes.keys) {
		//hashes[filename] = tasks[filename].yieldForce;
		//writeln(filename, " ", hashes[filename]);
	//}
	// receive the computed hash
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
