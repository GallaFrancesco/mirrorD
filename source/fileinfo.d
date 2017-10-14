import std.stdio;
import std.file;
import std.array;

class FileInfo {
	string path;
	bool isRoot; // equals depth = 0 if true
	DirEntry info; // similar to 'stat' on a Posix system
	FileInfo[] children;
}

class FileInfoManager {

	// contains a FileInfo structure
	FileInfo root ;
	private string rootPath;

	// constructor, requires the root path 
	this (string rp) {
		this.rootPath = rp;
		this.initialize ();
	}

	// initialize root directory
	private void initialize () {

		// the absolute path must exist
		assert (exists(this.rootPath));

		// initialize root (children is initialized in load)
		this.root = new FileInfo();
		this.root.path = rootPath;
		this.root.isRoot = true;
		this.root.info = DirEntry (this.root.path);

		// root must be a directory
		assert (this.root.info.isDir);

		load (this.root);
		printTree();
	}

	// build the tree FileInfo structure
	private void load (FileInfo currentRoot) {
		// dirEntries scan for children info
		// returns an InputRange
		foreach (DirEntry d; dirEntries(currentRoot.path, SpanMode.shallow, false)) {
			// create a new file struct
			FileInfo current = new FileInfo();

			current.path = d.name;
			current.isRoot = false;
			current.info = d; 
			currentRoot.children ~= current;
		}

		foreach (FileInfo child; currentRoot.children) {
			if (child.info.isDir) {
				load(child);
			}
		}
		
	}

	private void print (FileInfo root) {
		writeln (root.path);
		foreach (FileInfo child; root.children) {
			print(child);
		}
	}

	public void printTree () {
		this.print(this.root);
	}
}
