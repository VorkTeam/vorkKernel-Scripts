#!/usr/bin/env python
# coding: utf-8
# vim:foldmethod=indent:ai:ts=4:sw=4
#	dbconfig.py - Helper functions to read/write the dropbox database
#	Copyleft Eliphas Levy Theodoro
#	http://www.opensource.org/licenses/simpl-2.0.html
#	Thanks to Dropbox - http://www.dropbox.com

import sys, os
import sqlite3, base64, pickle

CHANGELOG="""
ChangeLog
2011-01-04.0.0.1
	First release
2011-05-16.0.2
	Trying to make this work with python 2 AND 3
"""

python3 = sys.version_info >= (3,0)

class DBConfig:

	def __init__(self):
		if os.path.isfile(os.path.join(self.configpath,'config.db')):
			self.configversion = 1
			self.configfile = os.path.join(self.configpath,'config.db')
		elif os.path.isfile(os.path.join(self.configpath, 'dropbox.db')):
			self.configversion = 0
			self.configfile = os.path.join(self.configpath,'dropbox.db')
		else:
			raise Exception('Dropbox database not found, is dropbox installed?')
		if os.path.isfile(os.path.join(self.configpath, 'host.db')):
			self.hostfile = os.path.join(self.configpath,'host.db')
		else:
			self.hostfile = None
		# read schema version on init; if not 0 or 1, we should not try to guess
		if self.schemaversion not in (0,1):
			raise Exception('Dropbox schema version %s is not supported.' % self.schemaversion)

	_configpath = None
	def GetDbConfigFolder(self):
		if not self._configpath:
			if sys.platform == 'win32':
				assert 'APPDATA' in os.environ, Exception('APPDATA env variable not found')
				configpath = os.path.join(os.environ['APPDATA'],'Dropbox')
			elif sys.platform in ('linux2','darwin'):
				assert 'HOME' in os.environ, Exception('HOME env variable not found')
				configpath = os.path.join(os.environ['HOME'],'.dropbox')
			else: # FIXME other archs?
				raise Exception('platform %s not known, please report' % sys.platform)
			assert os.path.isdir(configpath), Exception('configpath "%s" is not a folder' % configpath)
			self._configpath = configpath
		return self._configpath
	configpath = property(GetDbConfigFolder)

	_connection = None
	def GetDbConnection(self):
		if not self._connection:
			lastdir = os.getcwd()
			os.chdir(self.configpath) # there is a bug in sqlite on windows UTF paths or something like it.
			self._connection = sqlite3.connect(self.configfile, isolation_level=None)
			os.chdir(lastdir)
			#XXX connection.close() is never called. Python should take care of it.
		return self._connection
	connection = property(GetDbConnection)

	def GetDbConfigValue(self, key):
		cursor = self.connection.cursor()
		cursor.execute('SELECT value FROM config WHERE key=?', (key,))
		row = cursor.fetchone()
		cursor.close()
		if row:
			return row[0]
		else:
			return None

	def SetDbConfigValue(self, key, value):
		cursor = self.connection.cursor()
		cursor.execute('REPLACE INTO config (key,value) VALUES (?,?)', (key, value))

	_schemaversion = None
	def GetDbSchemaVersion(self):
		if self.configversion == 0:
			self._schemaversion = 0
		else:
			self._schemaversion = self.GetDbConfigValue('config_schema_version')
		return self._schemaversion
	schemaversion = property(GetDbSchemaVersion)

	_dbfolder = None
	def GetDbFolder(self):
		if not self._dbfolder:
			if self.hostfile:
				lines = open(self.hostfile).readlines()
				if python3: # already unicode, and b64 needs bytes
					tfolder = str(base64.b64decode(bytes(lines[1].strip(),'utf-8')),'utf-8')
				else:
					tfolder = base64.b64decode(lines[1].strip().encode('utf-8')).decode('utf-8')
			else:
				tfolder = self.GetDbConfigValue('dropbox_path')
				if tfolder is not None:
					if self.configversion == 0:
						if python3: # b64 needs bytes
							tfolder = pickle.loads(str(base64.b64decode(bytes(tfolder,'utf-8')),'utf-8'))
						else:
							tfolder = pickle.loads(base64.b64decode(tfolder))
				else: # No luck! Try to guess the location of the folder
					if sys.platform in ('linux2','darwin'):
						tfolder = os.path.join(os.environ['HOME'],'Dropbox')
					elif sys.platform == 'win32':
						# Always complicated on windows :/ try really hard...
						# On XP, its MyDocs/Dropbox
						# On Vista/7 it can be in Users/UserName/Dropbox
						homepath = os.environ.get('HOMEDRIVE') + os.environ.get('HOMEPATH')
						import ctypes
						dll = ctypes.windll.shell32
						buf = ctypes.create_string_buffer(300)
						dll.SHGetSpecialFolderPathA(None, buf, 0x0005, False)
						dbfolders = (
							os.path.join(buf.value,'My Dropbox'), os.path.join(buf.value,'Dropbox'), 
							os.path.join(homepath,'My Dropbox'),  os.path.join(homepath,'Dropbox'),
							)
						for f in dbfolders:
							if os.path.isdir(f):
								tfolder = f
					else:
						raise Exception('platform %s not known, please report' % sys.platform)
			# XXX can't assert this. We may have moved it to another place, mmkay?
			#assert os.path.isdir(tfolder), Exception('dbfolder "%s" is not a folder' % tfolder)
			self._dbfolder = tfolder
		return self._dbfolder
	def SetDbFolder(self, newloc):
		self._dbfolder = newloc
		if self.configversion == 0:
			if python3: # b64 needs bytes
				newloc = str(base64.b64encode(bytes(pickle.dumps(newloc),'utf-8')),'utf-8')
			else:
				newloc = base64.b64encode(pickle.dumps(newloc))
		self.SetDbConfigValue('dropbox_path',newloc)
		if self.hostfile: # update host.db too
			# we change *only* the SECOND line; first line is something else (hostid?),
			# and I don't know if there can be a third line.
			lines = open(self.hostfile).readlines()
			if python3:
				nl = str(base64.b64encode(bytes(newloc,'utf-8')),'utf-8')
			else:
				nl = base64.b64encode(newloc) 
			if len(lines) > 2: # the second line needs a newline
				nl += '\n'
			lines[1] = nl
			open(self.hostfile, 'w').writelines(lines)
	dbfolder = property(GetDbFolder, SetDbFolder)

	# FIXME Once we list every variable that can be changed and the format, there should be more SetXXX here.

if __name__ == '__main__':
	config = DBConfig()
	print('Configuration path:')
	print('\t%s\n' % config.configpath)
	print('Dropbox folder:')
	print('\t%s\n' % config.dbfolder)
