import vibe.vibe;
import vibe.core.core;
import restapi;
import fileinfo;
import parseconfig;
import args;

static string desc = "mirrord is a web server.\nIt can be used to monitor and mirror one or more directories in a decentralized way.";

void main(string[] args)
{
	bool help = parseArgsWithConfigFile(configWriteable(), args);
	if (help) {
		printArgsHelp(config(), desc);
		return;
	}
	// register the REST api
	auto router = new URLRouter;
	router.registerRestInterface(new API());
	// settings for the http server
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);

	auto fi = new FileInfoManager (config().directory);	
	setTimer(10.seconds, &fi.reload, true);

	// run the webserver
	logInfo("Please open http://127.0.0.1:8080/api/ in your browser.");
	runApplication();
}
