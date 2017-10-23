import vibe.data.json;

Json encodeAsJson(string path) {
	Json j = Json.emptyObject();
	j["path"] = path;
	return j;
}
