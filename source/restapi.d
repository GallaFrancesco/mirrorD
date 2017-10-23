import vibe.d;
import fileinfo;
import utils_json;

@path("/")
interface restApi {
	@path(":root")
	Json getRootDir(string _root);

	//@queryParam(":root/list");
	//Json getFolders(string _root);
}

class FileAPI: restApi {
	// generic get on root, displays an hello.
	private	FileInfoManager rootManager;

	// assign fileInfoManager to the API
	this(FileInfoManager rManager) {
		rootManager = rManager;
	}

	// this shows the directories inside the tree
	override Json getRootDir(string dir) {
		return encodeAsJson(rootManager.root.path); 
	}

	//override Json getFolders(string  
	// TODO finish this, on / it should display a list of roots
	// TODO it should be possible to authenticate
	// TODO it should provide the entire tree, json encoded, by nesting them

}
