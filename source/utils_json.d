import vibe.data.json;
import vibe.core.log;

// various functions to encode arguments as json
@safe
Json encodeAsJson(string path) {
	Json j = Json.emptyObject();
	j["path"] = path;
	logInfo("[JSON] serving: %s", j.toString );
	return j;
}

@safe
Json encodeAsJson(string[] list) {
	Json j = Json.emptyArray();
	for (int i=0; i<list.length; i++) {
		j[i] = list[i];
	}
	logInfo("[JSON] serving: %s", j.toString );
	return j;
}

@safe
Json encodeAsJson(string[string] alist) {
	Json j = serializeToJson(alist);
	logInfo("[JSON] serving: %s", j.toString );
	return j;
}
