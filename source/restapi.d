import vibe.d;
import fileinfo;
import utils_json;

// this RESTful api uses JSON
// to encode control messages
@path("/")
interface restApi {

	// get a list of roots
	// managed on this server
	Json getRoots();

	@path(":root")
	Json getRootDir(string _root);

	//@queryParam(":root/list");
	//Json getFolders(string _root);
}

class FileAPI: restApi {
	// generic get on root, displays an hello.
	private	FileInfoManager rootManager;
	private string[] rootList;

	// assign fileInfoManager to the API
	this(FileInfoManager rManager, string[] list) {
		rootManager = rManager;
		rootList = list;
	}

	override Json getRoots() {
		return encodeAsJson(rootList);
	}

	// this shows the directories inside the tree
	override Json getRootDir(string dir) {
		return encodeAsJson(rootManager.root.path); 
	}

	//override Json getFolders(string  
	// TODO it should be possible to authenticate
	// TODO it should provide the entire tree, json encoded, by nesting them

}
