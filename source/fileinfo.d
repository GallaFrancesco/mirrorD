import std.stdio;
import std.utf;
import std.file;
import std.array;
import utils_hash;

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

	private string _rootPath;

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

		// root must be a directory
		assert (this.root.info.isDir);

		this._load (this.root);
		printTree();
	}

	private FileInfo _createNode (DirEntry d) {
		FileInfo f = new FileInfo();
		f.path = d.name;
		f.isRoot = false;
		f.info = d;
		if (!d.isDir) {
			f.hash = fileHash(f.path);
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
				auto newHash = fileHash(newInfo.name);
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
		}
		this._scanNew(current);

		foreach (FileInfo child; current.children.values) {
			_traverseCheck(child);
		}
	}

	// reload the tree rooted @ this.root
	// (use this to check for changes)
	public void reload () {
		this._traverseCheck (this.root);
	}

//-- Debugging purposes, from here downwards

	private void _print (FileInfo root) {
		writefln ("%s", root.path);
		foreach (FileInfo child; root.children) {
			_print(child);
		}
	}

	public void printTree () {
		this._print(this.root);
	}
}
