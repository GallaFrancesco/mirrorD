import vibe.vibe;
import std.stdio;
import vibe.core.core;
import restapi;
import fileinfo;
import parseconfig;
import args;

static string desc = "mirrord is a web server.\nIt can be used to monitor and mirror one or more directories in a decentralized way.";


void main(string[] args)
{
	// parse the config / command line args
	bool help = parseArgsWithConfigFile(configWriteable(), args);
	if (help) {
		printArgsHelp(config(), desc);
		return;
	}

	// add root directories to the map
	auto fi = new FileInfoManager (config().directory);
	rootInfoMap[fi.root.path] = fi;
	// set timer to update folders
	setTimer(10.seconds, &rootInfoMap[fi.root.path].reload, true);

	// register the REST APIs (one for each directory
	auto router = new URLRouter;
	router.registerRestInterface(new FileAPI(fi));

	// settings for the http server
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["127.0.0.1"];
	listenHTTP(settings, router);


	// run the webserver
	logInfo("[serv] Initialization complete, handling requests.");
	runApplication();
}
