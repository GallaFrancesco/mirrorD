import std.stdio;
import std.format;
import std.getopt;
import core.thread;

import fswatch;


class Monitor {

	// time period (ms) between one loop and another (Thread.sleep)
	private uint period = 100;

	// values for the monitoring loop
	enum eventType { CREATE_SELF, DELETE_SELF, CREATED, DELETED, MODIFIED, RENAMED }
	//TODO tree/hash table? of monitored directories, stored in memory at runtime

	// constructor
	// expects a list of absolute paths to be added at initialization.
	this (string[] pathList) {
		//TODO Folder class for properties and automated subfolder scanning
		//TODO call 'monitorDir' for each path, recursively on subfolders
	}

	void monitorDir(string toWatch)
	{
		auto watcher = FileWatch(toWatch);
		writefln("Watching %s", toWatch);
		while(true) {
			auto events = watcher.getEvents();
			foreach(event; events) {
				final switch(event.type) with (FileChangeEventType)
				{
					// directory created
					case createSelf:
						writefln("Observable path created");
						break;
					// directory removed
					case removeSelf:
						writefln("Observable path deleted");
						break;
					// file created inside directory
					case create:
						writefln("'%s' created", event.path);
						break;
					// file removed inside directory
					case remove:
						writefln("'%s' removed", event.path);
						break;
					// file renamed inside directory
					case rename:
						writefln("'%s' renamed to '%s'", event.path, event.newPath);
						break;
					// file modified inside directory
					case modify:
						writefln("'%s' contents modified", event.path);
						break;
				}
			}
			Thread.sleep(period.msecs);
		}
	}

	~this() {}
}

