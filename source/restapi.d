import vibe.d;

@path("/api/")
interface APIroot {
	string get();
}

class API : APIroot {
	override string get() { return "hello world"; }
}
