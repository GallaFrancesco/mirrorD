import vibe.vibe;
import std.stdio;
import vibe.core.core;
import restapi;
import fileinfo;
import parseconfig;
import args;

static string desc = "mirrord is a web server.\nIt can be used to monitor and mirror one or more directories in a decentralized way.";

// initialize the map of infomanagers
// create each manager, assign it to fm, set its reload timer
FileInfoManager[string] initializeManagers() {

	FileInfoManager fi;
	FileInfoManager[string] fm;

	// list of directories is taken by command line / config file
	const string[] dirs = config().directory;

	// timeout is taken by command line / config file too
	uint tout = config().timeout;

	foreach (string dir; dirs)  {
		fi = new FileInfoManager(dir);
		fm[fi.root.path] = fi;
		// set timer to update folders
		setTimer(tout.minutes, &fm[fi.root.path].reload, true);
	}
	return fm;
}

// load the server options from command line / config
HTTPServerSettings setHTTPserver () {
	auto settings = new HTTPServerSettings;
	settings.port = config().port;
	settings.bindAddresses = configWriteable().addresses;
	return settings;
}

void main(string[] args)
{
	// parse the config / command line args
	bool help = parseArgsWithConfigFile(configWriteable(), args);
	if (help) {
		printArgsHelp(config(), desc);
		return;
	}

	// a map holding all the roots
	// keyed on the root paths
	FileInfoManager[string] rootInfoMap = initializeManagers();

	// register the REST APIs
	auto router = new URLRouter;
	router.registerRestInterface(new FileAPI(rootInfoMap));

	// settings for the http server
	auto settings = setHTTPserver();
	listenHTTP(settings, router);

	// run the webserver
	logInfo("[serv] Initialization complete, handling requests.");
	runApplication();
}
