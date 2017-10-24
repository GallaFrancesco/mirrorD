import vibe.d;
import fileinfo;
import utils_json;
import vibe.core.log;
import std.array;

string[string] stripPathLoad (string[] pathArray) {
	string endpt;
	string[string] aa;
	foreach (string path; pathArray) {
		endpt = (split(path, '/'))[$-1];
		aa[endpt] = path;
	}
	return aa;
}

// this RESTful api uses JSON
// to encode control messages
interface restApi {

	// get a list of roots
	// managed on this server
	@path("/")
	Json getRoots();

	@path(":root")
	Json getRootDir(string _root);

	//@queryParam(":root/list");
	//Json getFolders(string _root);
}

class FileAPI: restApi {
	private	FileInfoManager[string] rootManager;
	// used to link the endpoint name to the root path
	private string[string] rootList;

	// assign fileInfoManager to the API
	this(FileInfoManager[string] rManager) {
		rootManager = rManager;
		rootList = stripPathLoad(rootManager.keys);
		// debugging log
		logInfo("[REST] initialized API. Printing list of roots:");
		foreach (string r; rootList) {
			logInfo("[REST] %s", r);
		}

	}

	@safe
	override Json getRoots() {
		if (rootList !is null) {
			return encodeAsJson(rootList);
		} else {
			return encodeAsJson("[ERROR] no path found");
		}
	}

	// this shows the directories inside the tree
	@safe
	override Json getRootDir(string dir) {
		// test membership
		string path = rootList[dir];
		FileInfoManager *f;
		f = (path in rootManager);
		if (f !is null) {
			return encodeAsJson(f.root.path); 
		} else {
			return encodeAsJson("[ERROR] no path " ~ dir ~ " found");
		}
	}

	//override Json getFolders(string  
	// TODO it should be possible to authenticate
	// TODO it should provide the entire tree, json encoded, by nesting them

}
