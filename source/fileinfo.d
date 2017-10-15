import std.stdio;
import std.file;
import std.array;

class FileInfo {
	string path;
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

		_load (this.root);
		printTree();
	}

	private FileInfo _createNode (DirEntry d) {
		FileInfo f = new FileInfo();
		f.path = d.name;
		f.isRoot = false;
		f.info = d; 
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
			// TODO hash
		}

		foreach (FileInfo child; currentRoot.children.values) {
			if (child.info.isDir) {
				_load(child);
			}
		}
	}
	
	// check date change
	private bool _dateChanged ( FileInfo file) {
		DirEntry newInfo = DirEntry (file.path); 
		if ( !( newInfo.timeLastModified.opEquals(file.info.timeLastModified ))) {
			return true;
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
				// TODO hash
			}
		}
	}

	// traverse the tree recursively
	// scan for new nodes
	// on each node / leaf, check for changes
	// check is performed using date and hashing (murmurhash)
	private void _traverseCheck (FileInfo current) {

		if ( this._dateChanged(current)) {
			// TODO hash
		}
		// TODO finish, _scanNew, recursive

	}

	// reload the tree rooted @ this.root
	// (use this to check for changes)
	public void reload () {
		this._traverseCheck (this.root);
	}

	// just for debugging, from here downwards

	private void _print (FileInfo root) {
		writeln (root.path);
		foreach (FileInfo child; root.children) {
			_print(child);
		}
	}

	public void printTree () {
		this._print(this.root);
	}
}
