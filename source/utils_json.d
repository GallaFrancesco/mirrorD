import vibe.data.json;

Json encodeAsJson(string path) {
	Json j = Json.emptyObject();
	j["path"] = path;
	return j;
}

Json encodeAsJson(string[] list) {
	Json j = Json.emptyObject();
	for (int i=0; i<list.length; i++) {
		j[i] = list[i];
	}
	return j;
}
