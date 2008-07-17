"""   QuArK  -  Quake Army Knife

Various Model importer\exporter utility functions.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$


import os, os.path
import quarkx
import quarkpy.qutils

# Globals
textlog = "model_ie_log.txt"
tobj = None

'''
NOTE: ALL IMPORTERS AND EXPORTERS SHOULD INCLUDE THIS LOGGING CODE.

1) To add logging to an importer or exporter put these lines near the top in this order:
import os, time, operator
import ie_utils
from ie_utils import tobj

# Globals
logging = 0
exportername = "" (or importername = "" depending on which one you're doing)
textlog = ""

2) Setup for a text file like this in TWO PLACES:
def save_md2(filename):
    global tobj, logging, exportername, textlog
    start = time.time()
    if quarkx.setupsubset(3, "Options")['IELogging'] != "0":
        logging = 1
        exportername = "ie_md2_exporter.py"
        if quarkx.setupsubset(3, "Options")['IELogByFileType'] != "1" and textlog == "md2_ie_log.txt" and tobj.txtobj is not None:
            tobj.txtobj.close()
            textlog = "model_ie_log.txt"
            tobj = ie_utils.tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.

        if quarkx.setupsubset(3, "Options")['IELogByFileType'] == "1" and textlog == "model_ie_log.txt" and tobj.txtobj is not None:
            tobj.txtobj.close()
            textlog = "md2_ie_log.txt"
            tobj = ie_utils.tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.

        if quarkx.setupsubset(3, "Options")['IELogAll'] != "1":
            if quarkx.setupsubset(3, "Options")['IELogByFileType'] != "1":
                textlog = "model_ie_log.txt"
                tobj = ie_utils.tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.
            else:
                textlog = "md2_ie_log.txt"
                tobj = ie_utils.tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.
        else:
            if tobj is None:
                if quarkx.setupsubset(3, "Options")['IELogByFileType'] != "1":
                    textlog = "model_ie_log.txt"
                    tobj = ie_utils.tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.
                else:
                    textlog = "md2_ie_log.txt"
                    tobj = ie_utils.dotext(textlog) # Calls the class to handle logging.

        tobj.logcon ("#####################################################################")
        tobj.logcon ("This is: %s" % exportername)
        tobj.logcon ("Exporting file:")
        tobj.logcon (filename)
        tobj.pprint ("#####################################################################")
        tobj.logcon ("")
    else:
        logging = 0

    ### Line below here saves the model (just for this example---DO NOT COPY NEXT LINE).
    fill_md2(md2, component)

    end = time.time()
    seconds = "in %.2f %s" % (end-start, "seconds")
    if logging == 1:
        tobj.pprint ("=====================================================================")
        tobj.logcon ("Successfully exported " + os.path.basename(filename))
        tobj.logcon (seconds + " " + time.asctime(time.localtime()))
        tobj.logcon ("")
        tobj.logcon ("Any used skin textures that are not a .pcx")
        tobj.logcon ("will need to be created to go with the model")
        tobj.logcon ("=====================================================================")
        tobj.logcon ("")
        tobj.logcon ("")
        if quarkx.setupsubset(3, "Options")['IELogAll'] != "1":
            tobj.txtobj.close()

3) Then in any function you want logging declair the global and call for tobj like this:
def fill_md2(md2, component):
    global tobj
    if logging == 1:
        tobj.logcon ("#####################################################################")
        tobj.logcon ("Skins group data: " + str(md2.num_skins) + " skins")
        tobj.logcon ("#####################################################################")
        tobj.logcon ("")

'''

def safestring(st):
    "Makes sure what it gets is a string,"
    "deals with strange chars"

    myst = ""
    for ll in xrange(len(st)):
        if st[ll] < " ":
            myst += "#"
        else:
            myst += st[ll]
    return myst

class dotext:

    _NO = 0    #use internal to class only
    LOG = 1    #write only to LOG
    CON = 2    #write to both LOG and CONSOLE

    def __init__(self, textlog, where=LOG):
        self.textlog = textlog
        self.dwhere = where
        self.txtobj = None

    def write(self, wstring, maxlen=80):
        # Opens a text file in QuArK's main directory for logging to.
        # See QuArK's Defaults.qrk file for additional setup code for IELogging option.
        if quarkx.setupsubset(3, "Options")['IELogging'] != "0":
            if self.txtobj == None or not os.path.exists(quarkx.exepath + self.textlog):
                self.txtobj = open(quarkx.exepath + self.textlog, "w")
        if (self.txtobj==None):
            return
        while (1):
            ll = len(wstring)
            if (ll>maxlen):
                self.txtobj.write((wstring[:maxlen]))
                self.txtobj.write("\n")
                if int(quarkx.setupsubset(3, "Options")['IELogging']) == 2:
                    print (wstring[:maxlen])
                wstring = (wstring[maxlen:])
            else:
                try:
                    self.txtobj.write(wstring)
                except:
                    self.txtobj = open(quarkx.exepath + self.textlog, "w")
                    self.txtobj.write(wstring)
                if int(quarkx.setupsubset(3, "Options")['IELogging']) == 2:
                    if wstring != "\n":
                        print wstring
                break

    def pstring(self, ppstring, where = _NO):
        where = int(quarkx.setupsubset(3, "Options")['IELogging'])
        if where == dotext._NO: where = self.dwhere
        self.write(ppstring)
        self.write("\n")

    def plist(self, pplist, where = _NO):
        self.pprint ("list:[")
        for pp in xrange(len(pplist)):
            self.pprint ("[%d] -> %s" % (pp, pplist[pp]), where)
        self.pprint ("]")

    def pdict(self, pdict, where = _NO):
        self.pprint ("dict:{", where)
        for pp in pdict.keys():
            self.pprint ("[%s] -> %s" % (pp, pdict[pp]), where)
        self.pprint ("}")

    def pprint(self, parg, where = _NO):
        if parg == None:
            self.pstring("_None_", where)
        elif type(parg) == type ([]):
            self.plist(parg, where)
        elif type(parg) == type ({}):
            self.pdict(parg, where)
        else:
            self.pstring(safestring(str(parg)), where)

    def logcon(self, parg):
        self.pprint(parg, dotext.CON)

"""
NOTE: ALL IMPORTERS AND EXPORTERS SHOULD INCLUDE THIS PATH CHECKING CODE.

1) To add path checking to an importer or exporter put this lines near the top:
import ie_utils

2) Call for the path check like this:
def loadmodel(root, filename, gamename, nomessage=0):
    ### First we test for a valid (proper) model path.
    basepath = ie_utils.validpath(filename)
    if basepath is None:
        return

"""

def validpath(filename):
    "Tests for a proper model path."

    basepath = ""
    name = filename.split('\\')
    for word in name:
        if word == "models":
            break
        basepath = basepath + word + "\\"
    if not filename.find(basepath + "models\\") != -1:
        quarkx.beep() # Makes the computer "Beep" once if folder structure is not valid.
        quarkx.msgbox("Invalid Path Structure!\n\nThe location of a model must be in the\n    'gamefolder\\models' sub-folder.\n\nYour model selection to import shows this path:\n\n" + filename + "\n\nPlace this model's folder within the game's 'models' sub-folder\nor make a main folder with a 'models' sub-folder\nand place this model's folder in that sub-folder.\n\nThen re-select it for importing.\n\nAny added textures needed half to also be placed\nwithin the 'game' folder using their proper sub-folders.", quarkpy.qutils.MT_ERROR, quarkpy.qutils.MB_OK)
        return None
    else:
        return basepath


# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.4  2008/06/17 20:39:13  cdunde
#To add lwo model importer, uv's still not correct though.
#Also added model import\export logging options for file types.
#
#Revision 1.3  2008/06/16 00:11:46  cdunde
#Made importer\exporter logging corrections to work with others
#and started logging function for md2 model importer.
#
#Revision 1.2  2008/06/15 02:41:21  cdunde
#Moved importer\exporter logging to utils file for global use.
#
#Revision 1.1  2008/06/14 07:52:15  cdunde
#Started model importer exporter utilities file.
#
#