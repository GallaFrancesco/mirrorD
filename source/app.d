import vibe.vibe;
import restapi;
import monitor;
import fileinfo;

void main()
{
	// register the REST api
	auto router = new URLRouter;
	router.registerRestInterface(new API());
	// settings for the http server
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);
	//monitorDir("/home/francesco/test");
	auto fi = new FileInfoManager ("/home/francesco/test");	

	// run the webserver
	logInfo("Please open http://127.0.0.1:8080/api/ in your browser.");
	runApplication();
}
