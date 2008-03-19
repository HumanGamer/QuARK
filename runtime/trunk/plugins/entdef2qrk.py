"""   QuArK  -  Quake Army Knife

Python macros available for direct call by QuArK
"""

#
#$Header$
#

import time, sys

class Key:
    def __init__(self):
        self.m_keyname = None
        self.m_desc = ""
        self.m_defaultvalue = None

    def SetKeyname(self, keyname):
        self.m_keyname = keyname

    def SetDesc(self, desc):
        self.m_desc = desc

    def SetDefaultValue(self, defvalue):
        self.m_defaultvalue = defvalue

    def GetDefaultValue(self):
        return self.m_defaultvalue

    def GenerateFolder(self, indent):
        if (self.m_defaultvalue is None) or (self.m_defaultvalue == ""):
            return None
        indent[self.m_keyname] = str(self.m_defaultvalue)
        return None

    def GenerateForm(self, indent):
        return "This is pure virtual"

    def AddKeyFlag(self, value, desc, selected):
        return "This is pure virtual"

    def AddKeyChoice(self, value, desc):
        return "This is pure virtual"

class KeyString(Key):
    def __init__(self):
        Key.__init__(self)

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_keyname + ":")
        # s["txt"] = "&"
        s["hint"] = self.m_desc
        indent.appenditem(s)
        return s

class KeyNumeric(Key):
    def __init__(self):
        Key.__init__(self)

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_keyname + ":")
        # s["txt"] = "&"
        s["hint"] = self.m_desc
        indent.appenditem(s)
        return None

class KeyFlags(Key):
    def __init__(self):
        Key.__init__(self)
        self.m_flags = []

    def AddKeyFlag(self, value, desc, selected):
        self.m_flags = self.m_flags + [(value, desc)]
        if (int(selected) > 0):
            try:
                oldvalue = int(self.GetDefaultValue())
            except:
                oldvalue = 0
            self.SetDefaultValue(oldvalue + int(value))

    def GenerateForm(self, indent):
        s = ""
        nl = "" # no first newline
        for value, desc in self.m_flags:
          s = quarkx.newobj(self.m_keyname + ":")
          # s["txt"] = "&"
          # s["hint"] = ""
          s["typ"] = "X"+value
          s["cap"] = desc
          indent.appenditem(s)
        return None

class KeyChoices(Key):
    def __init__(self):
        Key.__init__(self)
        self.m_choices = []

    def AddKeyChoice(self, value, desc):
        self.m_choices = self.m_choices + [(value, desc)]

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_keyname + ":")
        # s["txt"] = "&"
        s["hint"] = self.m_desc
        s["typ"] = "C"
        indent.appenditem(s)
        it = ""
        vl = ""
        c = 0
        for value, desc in self.m_choices:
          it = it + desc
          vl = vl + value
          c = c + 1
          if (c <> len(self.m_choices)):
            it = it + "\r"
            vl = vl + "\r"
        s["items"] = it
        s["values"] = vl
        return None

## --------

INHERITPREFIX = "t_"

class Entity:
    def __init__(self):
        self.m_classname = None
        self.m_desc = ""
        self.m_keys = []
        self.m_inherit = []
        self.m_size = None
        self.m_color = None
        self.m_help = None

    def Type(self):
        raise "This is pure virtual"

    def SetClassname(self, classname):
        self.m_classname = classname

    def SetDesc(self, desc):
        self.m_desc = desc

    def SetSize(self, sizeargs):
        if (len(sizeargs) == 6):
            self.m_size = (float(sizeargs[0]), float(sizeargs[1]), float(sizeargs[2]),
                           float(sizeargs[3]), float(sizeargs[4]), float(sizeargs[5]))

    def SetHelp(self, helpstring):
        self.m_help = helpstring

    def InheritsFrom(self, inherit):
        self.m_inherit = self.m_inherit + [INHERITPREFIX + inherit]

    def AddKey(self, key):
        self.m_keys = self.m_keys + [key]

    def TypeForm(self):
        return ":form"

    def GetFolderStuff(self, s):
        return ""

    def GenerateFolder(self, indent):
        def SortedAppendItem(obj, subitem):
            i = 0
            for s in obj.subitems:
                if (s.shortname.lower() > subitem.shortname.lower()):
                    break
                i = i + 1
            obj.insertitem(i, subitem)

        s = quarkx.newobj(self.m_classname + self.Type())
        folder = indent
        p = s.name.find("_")
        if (p == -1):
            folder = indent.findname("other entities.qtxfolder")
            if (folder is None):
                folder = quarkx.newobj("other entities.qtxfolder")
                SortedAppendItem(indent, folder)
        else:
            folder = indent.findname(s.name[:p+1]+"* entities.qtxfolder")
            if (folder is None):
                folder = quarkx.newobj(s.name[:p+1]+"* entities.qtxfolder")
                SortedAppendItem(indent, folder)
        SortedAppendItem(folder, s)
        self.GetFolderStuff(s)
        s[";desc"] = self.m_desc
        founddefaults = 0
        for key in self.m_keys:
            k = key.GenerateFolder(s)

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_classname + self.TypeForm())
        if (self.m_help is not None):
            s["help"] = self.m_help
        if (self.m_size is not None):
            s["bbox"] = self.m_size
        for key in self.m_keys:
            key.GenerateForm(s)
        # Place "<keyword>=!"-statements at the _end_ of ":form" definitions, because of a problem which Decker found but can't solve.
        for inh in self.m_inherit:
            s.specificadd(inh+"=!")
        indent.appenditem(s)

class BrushEntity(Entity):
    def __init__(self):
        Entity.__init__(self)

    def Type(self):
        return ":b"

    def GetFolderStuff(self, s):
        if (self.m_classname.lower() == "worldspawn"):
            return
        s["angle"] = "360"
        s[";incl"] = "defpoly"

class PointEntity(Entity):
    def __init__(self):
        Entity.__init__(self)

    def Type(self):
        return ":e"

    def GetFolderStuff(self, s):
        s["angle"] = "360"
        s["origin"] = "0 0 0"

class InheritEntity(Entity):
    def __init__(self):
        Entity.__init__(self)

    def SetClassname(self, classname):
        self.m_classname = INHERITPREFIX + classname

    def GenerateFolder(self, indent):
        return

    def Type(self):
        return

    def TypeForm(self):
        return ":incl"

## --------

theEntities = []
theEntity = None
theKey = None
currentclassname = None
currentsize = None
currentspawnflagbit = None
currentcomment = None

def CheckQUAKED(token):
    if not (token == "QUAKED"):
        raise "Expected 'QUAKED' token, but found: "+token

def CreateClass(token):
    global currentclassname, currentspawnflagbit, currentsize
    CloseClass("--CloseByCreateClass--")
    # Create entity
    currentclassname = token
    currentspawnflagbit = None
    currentsize = None
    currentcomment = None

def CloseClass(token):
    global theEntity, theEntities
    # Add to large list of entities
    if (theEntity is not None):
        theEntities = theEntities + [theEntity]

def MakePointEntity(token):
    global theEntity, currentclassname
    theEntity = PointEntity()
    theEntity.SetClassname(currentclassname)

def MakeBrushEntity(token):
    global theEntity, currentclassname
    theEntity = BrushEntity()
    theEntity.SetClassname(currentclassname)

def AppendSize(token):
    global currentsize
    if (currentsize is None):
        currentsize = [token]
    else:
        currentsize = currentsize + [token]

def SetSize(token):
    global currentsize, theEntity
    theEntity.SetSize(currentsize)
    currentsize = None

def AddSpawnflag(token):
    global currentspawnflagbit, theKey
    if (currentspawnflagbit == None):
        currentspawnflagbit = 1
        CloseSpawnflag("--CloseByAddSpawnflag--")
        theKey = KeyFlags()
        theKey.SetKeyname("spawnflags")
    # Only append spawnflag-tokens that are not "x" nor "-"
    if not (token == "x" or token == "-" or token == "?"):
        theKey.AddKeyFlag(str(currentspawnflagbit), token, 0)
    # Always double the spawnflagbit-value
    currentspawnflagbit = currentspawnflagbit * 2

def CloseSpawnflag(token):
    global theEntity, theKey
    if (theKey is not None):
        theEntity.AddKey(theKey)
        theKey = None

def AddComment(token):
    global currentcomment
    token = token.replace("\t", "    ")
    if (currentcomment is None):
        currentcomment = token
    else:
        currentcomment = currentcomment + "\r" + token

def DoneComment(token):
    global currentcomment, theEntity
    theEntity.SetHelp(currentcomment)
    currentcomment = None


## ------------

def readentirefile(file):
    f = open(file, "r")
    filecontents = ""
    while 1:
        line = f.readline()
        if not line:
            break
        line = line.strip()
        if line:
            filecontents = filecontents + line + "\n"
    f.close()
    return filecontents

TYPE_UNKNOWN    = 0
TYPE_NUMERIC    = 1
TYPE_STRING     = 2
TYPE_SYMBOL     = 3
TYPE_ANY        = 4
TYPE_ALFABETIC  = 5
TYPE_EOC        = 6 # End-Of-Comment == "*/"
TYPE_SPLITTER_AT        = 10 # @
TYPE_SPLITTER_COLON     = 11 # :
TYPE_SPLITTER_EQUAL     = 12 # =
TYPE_SPLITTER_SQUARE_B  = 13 # [
TYPE_SPLITTER_SQUARE_E  = 14 # ]
TYPE_SPLITTER_PRNTSHS_B = 15 # (
TYPE_SPLITTER_PRNTSHS_E = 16 # )
TYPE_SPLITTER_COMMA     = 17 # ,
TYPE_QUESTION_MARK      = 18 # ?
TYPE_ASTERISK           = 19 # *
TYPE_FORWARD_SLASH      = 20 # /
TYPE_NEWLINE            = 21 # \n

CHARS_NUMERIC           = "0123456789"
CHARS_NUMERIC_SYMBOLS   = "-."
CHARS_ALFABETIC         = "_-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

def getnexttoken(srcstring):
    # Remove heading spaces/tabs
    i = 0
    while (srcstring[i] in " \t"):
        i = i + 1

    if (srcstring[i] in "{"):
        while (not srcstring[i] in "}"):
            i = i + 1
        i = i + 1

    token_is = TYPE_UNKNOWN
    token = ""

    # Determine token-type
    if (srcstring[i] in CHARS_NUMERIC and not srcstring[i+1] in CHARS_ALFABETIC) \
    or (srcstring[i] in CHARS_NUMERIC_SYMBOLS and srcstring[i+1] in CHARS_NUMERIC):
        # Numeric
        token_is = TYPE_NUMERIC
        while (srcstring[i] in (CHARS_NUMERIC_SYMBOLS + CHARS_NUMERIC)):
            token = token + srcstring[i]
            i = i + 1
    elif (srcstring[i] in CHARS_ALFABETIC):
        # Alfabetic
        token_is = TYPE_ALFABETIC
        while (srcstring[i] in (CHARS_ALFABETIC + CHARS_NUMERIC + "*")):
            token = token + srcstring[i]
            i = i + 1
    else:
        # Character-symbol
        token = srcstring[i]
        i = i + 1
        if (token == "?"):
            token_is = TYPE_QUESTION_MARK
        elif (token == "*"):
            token_is = TYPE_ASTERISK
        elif (token == "/"):
            token_is = TYPE_FORWARD_SLASH
        elif (token == "("):
            token_is = TYPE_SPLITTER_PRNTSHS_B
        elif (token == ")"):
            token_is = TYPE_SPLITTER_PRNTSHS_E
        elif (token == "\n"):
            token_is = TYPE_NEWLINE
            if (srcstring[i] == "\r"):
                i = i + 1
        elif (token == "\r"):
            token_is = TYPE_NEWLINE
            if (srcstring[i] == "\n"):
                i = i + 1

    return token, token_is, srcstring[i:]

def getwholeline(srcstring):
    token = ""
    i = 0
    srclen = len(srcstring)
    while (i < srclen) and (not (srcstring[i] in "\n\r")):
        token = token + srcstring[i]
        i = i + 1
    i = i + 1
    if (token[-2:] == "*/"):
        token_is = TYPE_EOC
    else:
        token_is = TYPE_STRING
    return token, token_is, srcstring[i:]


statediagram =                                                                                  \
{                                                                                               \
# Current state            Token-type to go to ->    Next state             Function to call with token \
 'STATE_UNKNOWN'        :[(TYPE_FORWARD_SLASH      ,'STATE_COMMENTBEGIN'   ,None)               \
                         ,(TYPE_NEWLINE            ,'STATE_UNKNOWN'        ,None)             ] \
                                                                                                \
,'STATE_COMMENTBEGIN'   :[(TYPE_ASTERISK           ,'STATE_QUAKEEDBEGIN'   ,None)               \
                         ,(TYPE_FORWARD_SLASH      ,'STATE_EOL_COMMENT'    ,None)             ] \
                                                                                                \
,'STATE_EOL_COMMENT'    :[(TYPE_NEWLINE            ,'STATE_UNKNOWN'        ,None)               \
                         ,(TYPE_ANY                ,'STATE_EOL_COMMENT'    ,None)             ] \
                                                                                                \
,'STATE_QUAKEEDBEGIN'   :[(TYPE_ALFABETIC          ,'STATE_CLASSNAME'      ,CheckQUAKED)      ] \
                                                                                                \
,'STATE_CLASSNAME'      :[(TYPE_ALFABETIC          ,'STATE_CLASSCOLOR'     ,CreateClass)      ] \
                                                                                                \
,'STATE_CLASSCOLOR'     :[(TYPE_SPLITTER_PRNTSHS_B ,'STATE_CLASSCOLOR2'    ,None)             ] \
,'STATE_CLASSCOLOR2'    :[(TYPE_NUMERIC            ,'STATE_CLASSCOLOR3'    ,None)             ] \
,'STATE_CLASSCOLOR3'    :[(TYPE_NUMERIC            ,'STATE_CLASSCOLOR4'    ,None)             ] \
,'STATE_CLASSCOLOR4'    :[(TYPE_NUMERIC            ,'STATE_CLASSCOLOR5'    ,None)             ] \
,'STATE_CLASSCOLOR5'    :[(TYPE_SPLITTER_PRNTSHS_E ,'STATE_CLASSSIZE'      ,None)             ] \
                                                                                                \
,'STATE_CLASSSIZE'      :[(TYPE_SPLITTER_PRNTSHS_B ,'STATE_CLASSSIZE2'     ,MakePointEntity)    \
                         ,(TYPE_QUESTION_MARK      ,'STATE_SPAWNFLAGS'     ,MakeBrushEntity)  ] \
                                                                                                \
,'STATE_CLASSSIZE2'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE3'     ,AppendSize)       ] \
,'STATE_CLASSSIZE3'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE4'     ,AppendSize)       ] \
,'STATE_CLASSSIZE4'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE5'     ,AppendSize)       ] \
,'STATE_CLASSSIZE5'     :[(TYPE_SPLITTER_PRNTSHS_E ,'STATE_CLASSSIZE6'     ,None)             ] \
,'STATE_CLASSSIZE6'     :[(TYPE_SPLITTER_PRNTSHS_B ,'STATE_CLASSSIZE7'     ,None)             ] \
,'STATE_CLASSSIZE7'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE8'     ,AppendSize)       ] \
,'STATE_CLASSSIZE8'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE9'     ,AppendSize)       ] \
,'STATE_CLASSSIZE9'     :[(TYPE_NUMERIC            ,'STATE_CLASSSIZE10'    ,AppendSize)       ] \
,'STATE_CLASSSIZE10'    :[(TYPE_SPLITTER_PRNTSHS_E ,'STATE_SPAWNFLAGS'     ,SetSize)          ] \
                                                                                                \
,'STATE_SPAWNFLAGS'     :[(TYPE_ALFABETIC          ,'STATE_SPAWNFLAGS'     ,AddSpawnflag)       \
                         ,(TYPE_UNKNOWN            ,'STATE_SPAWNFLAGS'     ,AddSpawnflag)       \
                         ,(TYPE_NEWLINE            ,'STATE_COMMENT'        ,CloseSpawnflag)   ] \
                                                                                                \
,'STATE_COMMENT'        :[(TYPE_EOC                ,'STATE_UNKNOWN'        ,DoneComment)        \
                         ,(TYPE_STRING             ,'STATE_COMMENT'        ,AddComment)       ] \
}

## --------

import quarkpy.qutils
import quarkx

def makeqrk(root, filename, gamename):
    quarkx.msgbox("Please note, this is not always 100% accurate and will duplicate\nexisting entities and possibly miss some out.\n\nYou may need to handedit the .qrk file. For help with this,\nfeel free to ask questions at the QuArK forum:\n\nhttp://groups.yahoo.com/group/quark/messages\n", quarkpy.qutils.MT_INFORMATION, quarkpy.qutils.MB_OK)
    global currentclassname
    srcstring = readentirefile(filename)
    state = 'STATE_UNKNOWN'
    while (len(srcstring) > 1):
        if (state == 'STATE_COMMENT'):
            # Special case, to keep the comment-lines intact, and not tokenized
            token, token_is, srcstring = getwholeline(srcstring)
        else:
            token, token_is, srcstring = getnexttoken(srcstring)
        # Figure out, if the token_is type is expected or not
        expectedtypes = []
        newstate = None
        typestates = statediagram[state]
        for type, nextstate, func in typestates:
            if (type == token_is or type == TYPE_ANY or (token_is == TYPE_QUESTION_MARK and func == AddSpawnflag)):
                # We found the correct token type, now remember what new state we're going into
                newstate = nextstate
                break
            expectedtypes = expectedtypes + [type]
        if newstate is None:
            print "Parse error: Got type", token_is, "but expected type(s);", expectedtypes
            print "Debug: Last classname was =", currentclassname
            print "Debug:", srcstring[:64]
            print "Debug - Associated function: ", func
            raise "Parse error!"
        if (func is not None):
            # This state have a function attached to it. Call it giving it the found token.
            func(token)
        # Change to new state
        state = newstate
    CloseClass("--EndByEOF--")
    indent = 2
    r_tbx = quarkx.newobj("Toolbox Folders.qtx")
    r_tbx["Toolbox"] = "New map items..."
    r_tbx.flags = r_tbx.flags | quarkpy.qutils.OF_TVSUBITEM
    root.appenditem(r_tbx)

    e_tbx = quarkx.newobj("Entities for "+gamename.split("\\")[-1]+".qtxfolder")
    e_tbx[";desc"] = "Created from "+filename.split("\\")[-1]
    r_tbx.appenditem(e_tbx)

    r_tbx["Root"] = e_tbx.name

    for ent in theEntities:
        ent.GenerateFolder(e_tbx)

    f_tbx = quarkx.newobj("Entity Forms.fctx")
    f_tbx.flags = f_tbx.flags | quarkpy.qutils.OF_TVSUBITEM
    root.appenditem(f_tbx)

    for ent in theEntities:
        ent.GenerateForm(f_tbx)
    root.refreshtv()

    quarkx.msgbox("The .DEF file have now almost been converted to QuArK format.\n\nWhat remains is to save it as a 'Structured text for hand-editing (*.qrk)' file.\n\nIf you encounter any problems using this 'Convert from QeRadiant .DEF file' utility, please post a mail in the QuArK-forum.", quarkpy.qutils.MT_INFORMATION, quarkpy.qutils.MB_OK)

import quarkpy.qentbase
quarkpy.qentbase.RegisterEntityConverter("QERadiant .def file", "QERadiant .def file", "*.def", makeqrk)

#
#$Log$
#Revision 1.9  2005/10/15 00:49:51  cdunde
#To reinstate headers and history
#
#Revision 1.6  2003/12/17 13:58:59  peter-b
#- Rewrote defines for setting Python version
#- Removed back-compatibility with Python 1.5
#- Removed reliance on external string library from Python scripts
#
#Revision 1.5  2003/06/21 14:46:22  nerdiii
#I modified the .def importer to work around three bugs:
#1. {...} entries are ignored now, caused parse errors before
#2. tokens starting with a digit such as '1st_left' are no longer treated as
#a number
#3. some entities have unused flags, that are named '?' in QERadiant. The
#importer used to interpret them as special characters.
#
#Revision 1.4  2002/04/17 12:32:20  decker_dk
#Minor problem, which caused it to not convert the MOHAA .DEF file correctly.
#
#Revision 1.3  2002/02/05 18:32:58  decker_dk
#Corrected a problem with debug() calls
#
#Revision 1.2  2001/12/02 09:57:45  decker_dk
#Removing 'os' from the import list, and some other minor fixes.
#
#Revision 1.1  2001/10/05 17:56:42  decker_dk
#Created QERadiant .DEF file to .QRK file converter.
#
