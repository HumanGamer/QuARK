"""   QuArK  -  Quake Army Knife

Python macros available for direct call by QuArK
"""

#
#  $Header
#

import string, time, os, sys

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
        if (self.m_defaultvalue is None):
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
        s["txt"] = "&"
        s["hint"] = self.m_desc
        indent.appenditem(s)
        return s

class KeyNumeric(Key):
    def __init__(self):
        Key.__init__(self)

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_keyname + ":")
        s["txt"] = "&"
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
          s["txt"] = "&"
          s["hint"] = ""
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
        s["txt"] = "&"
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

    def Type(self):
        raise "This is pure virtual"

    def SetClassname(self, classname):
        self.m_classname = classname

    def SetDesc(self, desc):
        self.m_desc = desc

    def SetSize(self, sizestring):
        self.m_size = sizestring

    def InheritsFrom(self, inherit):
        self.m_inherit = self.m_inherit + [INHERITPREFIX + inherit]

    def AddKey(self, key):
        self.m_keys = self.m_keys + [key]

    def TypeForm(self):
        return ":form"

    def GetFolderStuff(self, s):
        return ""

    def GenerateFolder(self, indent):
        s = quarkx.newobj(self.m_classname + self.Type())
        folder = indent
        p = string.find(s.name, "_")
        if (p == -1):
            folder = indent.findname("other entities.qtxfolder")
            if (folder is None):
                folder = quarkx.newobj("other entities.qtxfolder")
                indent.appenditem(folder)
        else:
            folder = indent.findname(s.name[:p+1]+"* entities.qtxfolder")
            if (folder is None):
                folder = quarkx.newobj(s.name[:p+1]+"* entities.qtxfolder")
                indent.appenditem(folder)
        folder.appenditem(s)
	self.GetFolderStuff(s)
	s[";desc"] = self.m_desc
        founddefaults = 0
        for key in self.m_keys:
            k = key.GenerateFolder(s)

    def GenerateForm(self, indent):
        s = quarkx.newobj(self.m_classname + self.TypeForm())
        if (self.m_size is not None):
            s["bbox"] = str(self.m_size)
        for inh in self.m_inherit:
            s.specificadd(inh+"=!")
        for key in self.m_keys:
            key.GenerateForm(s)
        indent.appenditem(s)

class BrushEntity(Entity):
    def __init__(self):
        Entity.__init__(self)

    def Type(self):
        return ":b"

    def GetFolderStuff(self, s):
        if (string.lower(self.m_classname) == "worldspawn"):
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
currentkeyname = None
currentinherit = None
currentinheritargs = None
currentkeyflag = None
currentkeychoice = None

def CreateClass(token):
    global theEntity, theEntities
    CloseClass("--CloseByCreateClass--")
    # Create entity-type
    if (string.lower(token) == "solidclass"):
        theEntity = BrushEntity()
    elif (string.lower(token) == "pointclass"):
        theEntity = PointEntity()
    elif (string.lower(token) == "baseclass"):
        theEntity = InheritEntity()
    else:
        raise "Unknown @-token:", token

def CloseClass(token):
    global theEntity, theEntities
    # Add to large list of entities
    if (theEntity is not None):
        theEntities = theEntities + [theEntity]

def BeginInherit(token):
    global currentinherit, currentinheritargs
    EndInherit("--EndByBeginInherit--")
    currentinherit = string.lower(token)
    currentinheritargs = []

def AddInherit(token):
    global currentinherit, currentinheritargs
    currentinheritargs = currentinheritargs + [token]

def EndInherit(token):
    global currentinherit, currentinheritargs, theEntity
    if (currentinherit is None):
        return
    if (currentinherit == "base"):
        for arg in currentinheritargs:
            theEntity.InheritsFrom(arg)
    elif (currentinherit == "size"):
        if (len(currentinheritargs) == 6):
            sizeargs = ""
            for arg in currentinheritargs:
                sizeargs = sizeargs + " " + arg
            theEntity.SetSize(string.strip(sizeargs))
    else:
        pass
    currentinherit = None

def BeginClassname(token):
    global currentclassname, theEntity
    EndClassname("--EndByBeginClassname--")
    currentclassname = token
    theEntity.SetClassname(token)

def AddClassnameDesc(token):
    global theEntity
    theEntity.SetDesc(token)

def EndClassname(token):
    global currentclassname
    if (currentclassname is None):
        return
    EndKey("--EndByEndClassname--")
    currentclassname = None

def BeginKey(token):
    global currentkeyname
    EndKey("--EndByBeginKey--")
    currentkeyname = token

def AddKeyType(token):
    global currentkeyname, theKey
    # Determine what type this key is, so the correct object can be created
    token = string.lower(token)
    if (token == "integer"):
        theKey = KeyNumeric()
    elif (token == "string" \
       or token == "target_source" \
       or token == "target_destination" \
       or token == "color255" \
       or token == "studio" \
       or token == "sound" \
       or token == "sprite" \
       or token == "decal"):
        theKey = KeyString()
    elif (token == "flags"):
        theKey = KeyFlags()
    elif (token == "choices"):
        theKey = KeyChoices()
    else:
        raise "Unknown KeyType-token:", token
    theKey.SetKeyname(currentkeyname)

def AddKeyDesc(token):
    global theKey
    theKey.SetDesc(token)

def AddKeyDefa(token):
    global theKey
    theKey.SetDefaultValue(token)

def AddKeyFlagNum(token):
    global currentkeyflag
    EndKeyFlag("--EndByAddKeyFlagNum--")
    currentkeyflag = token

def AddKeyFlagDesc(token):
    global currentkeyflag
    value = currentkeyflag
    currentkeyflag = (value, token)

def AddKeyFlagDefa(token):
    global currentkeyflag
    value, desc = currentkeyflag
    currentkeyflag = (value, desc, token)

def EndKeyFlag(token):
    global currentkeyflag, theKey
    if (currentkeyflag is None):
        return
    value, desc, selected = currentkeyflag
    theKey.AddKeyFlag(value, desc, selected)
    currentkeyflag = None

def AddKeyChoiceNum(token):
    global currentkeychoice
    EndKeyChoice("--EndByAddKeyChoiceNum--")
    currentkeychoice = token

def AddKeyChoiceDesc(token):
    global currentkeychoice
    value = currentkeychoice
    currentkeychoice = (value, token)

def EndKeyChoice(token):
    global currentkeychoice, theKey
    if (currentkeychoice is None):
        return
    value, desc = currentkeychoice
    theKey.AddKeyChoice(value, desc)
    currentkeychoice = None

def EndKey(token):
    global currentkeyname, theEntity, theKey
    if (currentkeyname is None):
        return
    if (theKey is None or theEntity is None):
        raise "Failure in EndKey()"
    theEntity.AddKey(theKey)
    currentkeyname = None

def EndKeyFlags(token):
    EndKeyFlag("--EndByEndKeyFlags--")
    EndKey(token)

def EndKeyChoices(token):
    EndKeyChoice("--EndByEndKeyChoices--")
    EndKey(token)

## ------------

def readentirefile(file):
    f = open(file, "r")
    filecontents = ""
    while 1:
        line = f.readline()
        if not line:
            break
        line = string.strip(line)
        line = string.split(line, "//")[0] # Remove end-of-line comments
        if line:
            filecontents = filecontents + line + "\n"
    f.close()
    return filecontents

TYPE_UNKNOWN    = 0
TYPE_NUMERIC    = 1
TYPE_STRING     = 2
TYPE_SYMBOL     = 3
TYPE_SPLITTER_AT        = 10
TYPE_SPLITTER_COLON     = 11
TYPE_SPLITTER_EQUAL     = 12
TYPE_SPLITTER_SQUARE_B  = 13
TYPE_SPLITTER_SQUARE_E  = 14
TYPE_SPLITTER_PARENTS_B = 15
TYPE_SPLITTER_PARENTS_E = 16
TYPE_SPLITTER_COMMA     = 17

CHARS_NUMERIC  = "-0123456789."
CHARS_STRING   = "\""
CHARS_SPLITTER = "@:=[](),"

def getnexttoken(srcstring):
    def nextnonwhitespace(srcstring):
        i = 0
        while (srcstring[i] in " \t\n\r"):
            i = i + 1
        return srcstring[i:]

    def gettoken(srcstring, delims=None):
        token = ""
        i = 0
        if delims is None:
            delims = " \t\n\r" + CHARS_SPLITTER
        if not (srcstring[i] in delims):
            token = token + srcstring[i]
            i = i + 1
        while not (srcstring[i] in delims):
            token = token + srcstring[i]
            i = i + 1
        return token, srcstring[i:]

    token_is = TYPE_UNKNOWN
    srcstring = nextnonwhitespace(srcstring)
    if (not srcstring):
        return None, TYPE_UNKNOWN, srcstring

    if (srcstring[0] in CHARS_NUMERIC):
        token_is = TYPE_NUMERIC
        token, srcstring = gettoken(srcstring)
    elif (srcstring[0] in CHARS_STRING):
        token_is = TYPE_STRING
        token, srcstring = gettoken(srcstring[1:], CHARS_STRING)
        srcstring = srcstring[1:] # Jump over the last " character
    elif (srcstring[0] in CHARS_SPLITTER):
        token = srcstring[0]
        srcstring = srcstring[1:] # Jump over the splitter character
        if (token == "@"):
            token_is = TYPE_SPLITTER_AT
        elif (token == ":"):
            token_is = TYPE_SPLITTER_COLON
        elif (token == "="):
            token_is = TYPE_SPLITTER_EQUAL
        elif (token == "["):
            token_is = TYPE_SPLITTER_SQUARE_B
        elif (token == "]"):
            token_is = TYPE_SPLITTER_SQUARE_E
        elif (token == "("):
            token_is = TYPE_SPLITTER_PARENTS_B
        elif (token == ")"):
            token_is = TYPE_SPLITTER_PARENTS_E
        elif (token == ","):
            token_is = TYPE_SPLITTER_COMMA
    else:
        token_is = TYPE_SYMBOL
        token, srcstring = gettoken(srcstring)
    return token, token_is, srcstring


statediagram =                                                                                  \
{                                                                                               \
 'STATE_UNKNOWN'        :[(TYPE_SPLITTER_AT        ,'STATE_CLASSBEGIN'     ,None)             ] \
                                                                                                \
,'STATE_CLASSBEGIN'     :[(TYPE_SYMBOL             ,'STATE_CLASSINHERIT'   ,CreateClass)      ] \
,'STATE_CLASSINHERIT'   :[(TYPE_SYMBOL             ,'STATE_INHERITBEGIN'   ,BeginInherit)       \
                         ,(TYPE_SPLITTER_EQUAL     ,'STATE_CLASSNAME'      ,None)             ] \
                                                                                                \
,'STATE_INHERITBEGIN'   :[(TYPE_SPLITTER_PARENTS_B ,'STATE_INHERITMEDIUM'  ,None)             ] \
,'STATE_INHERITMEDIUM'  :[(TYPE_SYMBOL             ,'STATE_INHERITMEDIUM'  ,AddInherit)         \
                         ,(TYPE_NUMERIC            ,'STATE_INHERITMEDIUM'  ,AddInherit)         \
                         ,(TYPE_STRING             ,'STATE_INHERITMEDIUM'  ,AddInherit)         \
                         ,(TYPE_SPLITTER_COMMA     ,'STATE_INHERITMEDIUM'  ,None)               \
                         ,(TYPE_SPLITTER_PARENTS_E ,'STATE_CLASSINHERIT'   ,EndInherit)       ] \
                                                                                                \
,'STATE_CLASSNAME'      :[(TYPE_SYMBOL             ,'STATE_CLASSNAME2'     ,BeginClassname)   ] \
,'STATE_CLASSNAME2'     :[(TYPE_SPLITTER_COLON     ,'STATE_CLASSNAME3'     ,None)               \
                         ,(TYPE_SPLITTER_SQUARE_B  ,'STATE_KEYSBEGIN'      ,None)             ] \
,'STATE_CLASSNAME3'     :[(TYPE_STRING             ,'STATE_CLASSNAME4'     ,AddClassnameDesc) ] \
,'STATE_CLASSNAME4'     :[(TYPE_SPLITTER_SQUARE_B  ,'STATE_KEYSBEGIN'      ,None)             ] \
                                                                                                \
,'STATE_KEYSBEGIN'      :[(TYPE_SPLITTER_SQUARE_E  ,'STATE_UNKNOWN'        ,EndClassname)       \
                         ,(TYPE_SYMBOL             ,'STATE_KEYBEGIN'       ,BeginKey)         ] \
                                                                                                \
,'STATE_KEYBEGIN'       :[(TYPE_SPLITTER_PARENTS_B ,'STATE_KEYTYPE'        ,None)             ] \
,'STATE_KEYTYPE'        :[(TYPE_SYMBOL             ,'STATE_KEYTYPE2'       ,AddKeyType)       ] \
,'STATE_KEYTYPE2'       :[(TYPE_SPLITTER_PARENTS_E ,'STATE_KEYTYPE3'       ,None)             ] \
,'STATE_KEYTYPE3'       :[(TYPE_SPLITTER_EQUAL     ,'STATE_VALUEFLAGS'     ,None)               \
                         ,(TYPE_SPLITTER_COLON     ,'STATE_VALUE'          ,None)               \
                         ,(TYPE_SYMBOL             ,'STATE_KEYBEGIN'       ,BeginKey)           \
                         ,(TYPE_SPLITTER_SQUARE_E  ,'STATE_UNKNOWN'        ,EndClassname)     ] \
                                                                                                \
,'STATE_VALUEFLAGS'     :[(TYPE_SPLITTER_SQUARE_B  ,'STATE_VALUEFLAGS2'    ,None)             ] \
,'STATE_VALUEFLAGS2'    :[(TYPE_SPLITTER_SQUARE_E  ,'STATE_KEYSBEGIN'      ,EndKeyFlags)        \
                         ,(TYPE_NUMERIC            ,'STATE_VALUEFLAG'      ,AddKeyFlagNum)    ] \
,'STATE_VALUEFLAG'      :[(TYPE_SPLITTER_COLON     ,'STATE_VALUEFLAG2'     ,None)             ] \
,'STATE_VALUEFLAG2'     :[(TYPE_STRING             ,'STATE_VALUEFLAG3'     ,AddKeyFlagDesc)   ] \
,'STATE_VALUEFLAG3'     :[(TYPE_SPLITTER_COLON     ,'STATE_VALUEFLAG4'     ,None)             ] \
,'STATE_VALUEFLAG4'     :[(TYPE_NUMERIC            ,'STATE_VALUEFLAGS2'    ,AddKeyFlagDefa)   ] \
                                                                                                \
,'STATE_VALUE'          :[(TYPE_STRING             ,'STATE_VALUE2'         ,AddKeyDesc)       ] \
,'STATE_VALUE2'         :[(TYPE_SYMBOL             ,'STATE_KEYBEGIN'       ,BeginKey)           \
                         ,(TYPE_SPLITTER_SQUARE_E  ,'STATE_UNKNOWN'        ,EndClassname)       \
                         ,(TYPE_SPLITTER_COLON     ,'STATE_VALUE3'         ,None)               \
                         ,(TYPE_SPLITTER_EQUAL     ,'STATE_CHOICES'        ,None)             ] \
,'STATE_VALUE3'         :[(TYPE_NUMERIC            ,'STATE_VALUE4'         ,AddKeyDefa)         \
                         ,(TYPE_STRING             ,'STATE_VALUE4'         ,AddKeyDefa)       ] \
,'STATE_VALUE4'         :[(TYPE_SYMBOL             ,'STATE_KEYBEGIN'       ,BeginKey)           \
                         ,(TYPE_SPLITTER_SQUARE_E  ,'STATE_UNKNOWN'        ,EndClassname)       \
                         ,(TYPE_SPLITTER_EQUAL     ,'STATE_CHOICES'        ,None)             ] \
                                                                                                \
,'STATE_CHOICES'        :[(TYPE_SPLITTER_SQUARE_B  ,'STATE_CHOICES2'       ,None)             ] \
,'STATE_CHOICES2'       :[(TYPE_SPLITTER_SQUARE_E  ,'STATE_KEYSBEGIN'      ,EndKeyChoices)      \
                         ,(TYPE_NUMERIC            ,'STATE_CHOICES3'       ,AddKeyChoiceNum)  ] \
,'STATE_CHOICES3'       :[(TYPE_SPLITTER_COLON     ,'STATE_CHOICES4'       ,None)             ] \
,'STATE_CHOICES4'       :[(TYPE_STRING             ,'STATE_CHOICES2'       ,AddKeyChoiceDesc) ] \
}

import qutils
import quarkx

def makeqrk(root, filename, gamename):
    qutils.debug(filename)
    global currentclassname
    srcstring = readentirefile(filename)
    state = 'STATE_UNKNOWN'
    while (len(srcstring) > 1):
        token, token_is, srcstring = getnexttoken(srcstring)
        # Figure out, if the token_is type is expected or not
        expectedtypes = []
        newstate = None
        typestates = statediagram[state]
        for type, nextstate, func in typestates:
            if (type == token_is):
                # We found the correct token type, now remember what new state we're going into
                newstate = nextstate
                break
            expectedtypes = expectedtypes + [type]
        if newstate is None:
            qutils.debug("Parse error: Got type", token_is, "but expected type(s);", expectedtypes)
            qutils.debug( "Debug: Last classname was =", currentclassname )
            raise "Parse error!"
        if (func is not None):
            # This state have a function attached to it. Call it giving it the found token.
            func(token)
        # Change to new state
        state = newstate
    CloseClass("--EndByEOF--")
    indent = 2
    qutils.debug("Here")
    r_tbx = quarkx.newobj("Toolbox Folders.qtx")
    r_tbx["Toolbox"] = "New map items..."
    r_tbx.flags = r_tbx.flags | qutils.OF_TVSUBITEM
    root.appenditem(r_tbx)
    qutils.debug("Here .")

    e_tbx = quarkx.newobj("Entities for "+gamename+".qtxfolder")
    e_tbx[";desc"] = "Created from "+filename
    r_tbx.appenditem(e_tbx)

    r_tbx["Root"] = e_tbx.name
    qutils.debug("Here ..")
    
    for ent in theEntities:
        ent.GenerateFolder(e_tbx)

    f_tbx = quarkx.newobj("Entity Forms.fctx")
    f_tbx.flags = f_tbx.flags | qutils.OF_TVSUBITEM
    root.appenditem(f_tbx)
    
    for ent in theEntities:
        ent.GenerateForm(f_tbx)
    qutils.debug("Here ...")
    root.refreshtv()

#
# $Log
#