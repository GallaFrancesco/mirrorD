import std.stdio;
import std.utf;
import std.file;
import std.array;
import utils_hash;
import parseconfig;

class FileInfo {
	string path;
	string hash;
	bool isChanged = false;
	bool isRoot; // equals depth = 0 if true
	DirEntry info; // similar to 'stat' on a Posix system
	//DirectoryMonitor monitor;
	FileInfo[string] children;
}

class FileInfoManager {

	// contains a FileInfo structure
	FileInfo root;
	string[string] hashes;
	FileInfo[string] nodes;
	private string _rootPath;
	private bool _needComputeHash;

	// constructor, requires the root path 
	this (string rp) {
		// root path must exist
		assert (exists(rp));

		// save rootpath
		this._rootPath = rp;
		this._initialize ();
	}

	// initialize root directory
	private void _initialize () {

		// initialize root (children is initialized in _load)
		this.root = new FileInfo();
		this.root.path = _rootPath;
		this.root.isRoot = true;
		this.root.info = DirEntry (this.root.path);

		//// root must be a directory
		assert (this.root.info.isDir);

		// build the tree
		this._load (this.root);

		// takes all the hashes and computes them
		// useful to speed up the process at startup
		this._computeHashes ();
		// insert the hashes into the tree nodes
		this._loadHashes();
		this.printTree();
	}

	private void _computeHashes () {
		fileHash(this.hashes, config().digest);
	}

	// creates a reference to the node in the aa nodes
	// used to load the computed hashes at startup
	private void _refNode (string filename, ref FileInfo node) {
		nodes[filename] = node;
	}

	// after the hashes have been computed
	// load them inside the tree nodes
	private void _loadHashes () {
		foreach (string filename; this.hashes.keys) {
			nodes[filename].hash = hashes[filename];
		}
	}

	private FileInfo _createNode (DirEntry d) {
		FileInfo f = new FileInfo();
		f.path = d.name;
		f.isRoot = false;
		f.info = d;

		if (!d.isDir) {
			// append the filename to the hashes to be computed
			hashes[f.path] = "";
			_refNode(f.path, f);
		}
		return f;
	}

	// build the tree FileInfo structure
	private void _load (FileInfo currentRoot) {

		// assign a monitor to each directory (root and subdir)
		//currentRoot.monitor = new DirectoryMonitor(currentRoot.path);

		// dirEntries scan for children info
		// returns an InputRange
		foreach (DirEntry d; dirEntries(currentRoot.path, SpanMode.shallow, false)) {
			// create a new file struct
			FileInfo current = this._createNode(d);
			currentRoot.children[current.path] = current; 
		}

		foreach (FileInfo child; currentRoot.children.values) {
			if (child.info.isDir) {
				_load(child);
			}
		}
	}

	// check file changed (modified)
	private bool _changed ( FileInfo file) {
		// get the new info
		DirEntry newInfo = DirEntry (file.path); 
		if ( !( newInfo.timeLastModified.opEquals(file.info.timeLastModified ))) {
			// date changed, check hash
			if (!(newInfo.isDir)) {
				auto newHash = singleFileHash(newInfo.name, config().digest);
				if (!( hashesEqual(file.hash, newHash))) {
					// file change confirmed, substitute new info
					file.info = newInfo;
					file.hash = newHash;
					file.isChanged = true;
					return true;
				}
			}
		}
		return false;
	}


	// check for new files in the subdir
	// use dirEntries
	private void _scanNew (FileInfo dir) {
		foreach (DirEntry i; dirEntries(dir.path, SpanMode.shallow, false)) {
			// if the associative array of children
			// does not contain the key name
			if (!(i.name in dir.children)){
				// create new node
				FileInfo newFile = this._createNode(i);
				// add it to the children
				dir.children[i.name] = newFile;
				this._needComputeHash = true;
			}
		}
	}

	// traverse the tree recursively
	// scan for new nodes
	// on each node / leaf, check for changes
	// check is performed using date and hashing (only when dates don't match)
	private void _traverseCheck (FileInfo current) {
		if ( this._changed(current)) {
			// TODO manage change in files
			writefln("[changed] %s", current.path);
		}
		if (current.info.isDir)  {
			this._scanNew(current);
		}

		foreach (FileInfo child; current.children.values) {

			_traverseCheck(child);
		}
	}

	// reload the tree rooted @ this.root
	// (use this to check for changes)
	// if new files are found,
	public void reload () { 
		writefln("Started reloading: %s", this.root.path);
		this._traverseCheck (this.root);
		if (this._needComputeHash) {
			_computeHashes();
			_loadHashes();
		}
		printTree();
	}

//-- Debugging purposes, from here downwards

	private void _print (FileInfo root) {
		writefln ("[loaded] %s: %s", root.path, root.hash);
		foreach (FileInfo child; root.children) {
			_print(child);
		}
	}

	public void printTree () {
		this._print(this.root);
	}
}
