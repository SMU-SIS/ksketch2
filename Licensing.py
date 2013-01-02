import os

def main():

	path = os.getcwd();

	for root, dirs, files in os.walk(path):
		for f in files:
			if(f.endswith(".as")):
				prepend_license(os.path.join(root,f));

def prepend_license(filename):

	if filename.count(".metadata") > 0: return;

	f = open(filename,'r');
	alllines = f.readlines();
	f.close();

	if alllines[0].count("/**") > 0: return;

	f = open(filename, 'w');

	f.write('/**\n');
	f.write(' * Copyright 2010-2012 Singapore Management University\n');
	f.write(' * Developed under a grant from the Singapore-MIT GAMBIT Game Lab\n');
	f.write(' * This Source Code Form is subject to the terms of the\n');
	f.write(' * Mozilla Public License, v. 2.0. If a copy of the MPL was\n');
	f.write(' * not distributed with this file, You can obtain one at\n');
	f.write(' * http://mozilla.org/MPL/2.0/.\n');
	f.write(' */\n');
	for line in alllines:
		f.write(line);
	f.close();
main();