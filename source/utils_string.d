//module utils_string;

// string utilities:
// this split the paths and loads the string on an associative array
string[string] stripPathLoad (string[] pathArray) {
	import std.array;

	string endpt;
	string[string] aa;
	foreach (string path; pathArray) {
		endpt = (split(path, '/'))[$-1];
		aa[endpt] = path;
	}
	return aa;
}

// an util to strip any character from the end of a string
// it checks if the char is present, otherwise doesn't act
string stripChar(char c)(string str) {
		if (str[$-1] == c) {
			str = str[0..$-1];
		}
		return str;
}

unittest {

	string str1 = "str1/";
	string str2 = "str2";

	assert(str1[0..$-1] == stripChar!'/'(str1));
	assert(str2 == stripChar!'/'(str2));

	string[] pathStr = ["/a/b/str1", "./c/str2"];
	string[string] aa = stripPathLoad(pathStr);

	assert(aa[stripChar!'/'(str1)] == pathStr[0]);
	assert(aa[stripChar!'/'(str2)] == pathStr[1]);
}

