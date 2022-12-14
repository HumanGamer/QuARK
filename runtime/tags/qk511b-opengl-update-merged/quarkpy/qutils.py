"""   QuArK  -  Quake Army Knife

Various constants and routines
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

import quarkx


# a few colors
BLACK     = 0x000000
MAROON    = 0x000080
GREEN     = 0x008000
OLIVE     = 0x008080
NAVY      = 0x800000
PURPLE    = 0x800080
TEAL      = 0x808000
GRAY      = 0x808080
SILVER    = 0xC0C0C0
RED       = 0x0000FF
LIME      = 0x00FF00
YELLOW    = 0x00FFFF
BLUE      = 0xFF0000
FUCHSIA   = 0xFF00FF
AQUA      = 0xFFFF00
LTGRAY    = 0xC0C0C0
DKGRAY    = 0x808080
WHITE     = 0xFFFFFF
NOCOLOR   = 0x1FFFFFFF    # for map view backgrounds and model components

# panels 'align' values
LEFT      = "left"
RIGHT     = "right"
TOP       = "top"
BOTTOM    = "bottom"
FULL      = "full"
NOALIGN   = None

# toolbars 'dock' values
TOPDOCK   = "topdock"
BOTTOMDOCK= "bottomdock"
LEFTDOCK  = "leftdock"
RIGHTDOCK = "rightdock"
NODOCK    = None

# window states
RESTORED  = 0       # normal
MINIMIZED = 1
MAXIMIZED = 2

# filedialogbox
SAVEDIALOG     = 1
MULTIPLEFILES  = 64

# setupset
SS_GENERAL     = 0
SS_GAMES       = 1
SS_MAP         = 2
SS_MODEL       = 3
SS_TOOLBARS    = 4

# floating windows flags
FWF_NOCAPTION  = 1
FWF_NOCLOSEBOX = 2
FWF_NORESIZE   = 4
FWF_POPUPCLOSE = 8
FWF_NOESCCLOSE = 16
FWF_KEEPFOCUS  = 32

# internal objects' "flags" value !!! WARNING !!! DO NOT MODIFY unless you know what you're doing !
OF_TVSUBITEM         = 1   # all objects in a tree-view except top-level
OF_TVINVISIBLE       = 2   # present but invisible in the tree-view
OF_TVALREADYEXPANDED = 4   # node has been expanded once
OF_TVEXPANDED        = 8   # node is expanded
OF_ONDISK            = 16   # has not been loaded yet (loading is automatic when Python code reads the object's Specifics or sub-items)
OF_FILELINK          = 32   # is a file link
OF_WARNBEFORECHANGE  = 64   # warn the user before he makes changes
OF_MODIFIED          = 128   # modified by the user

# values of the ';view' Specific (as text) of TreeMapGroup objects
VF_GRAYEDOUT        = 1    # whole group is grayed out
VF_HIDDEN           = 2    # whole group is hidden
VF_IGNORETOBUILDMAP = 4    # the group is ignored when writing the .map file with the SO_IGNORETOBUILD flag
VF_HIDEON3DVIEW     = 8    # not displayed on textured views
VF_CANTSELECT       = 16   # the objects in this group can't be selected by clicking on the map view

# values of the 'saveflags' Specific (as integer) of Map objects, to control how it should be saved
SO_SELONLY        = 1     # only the selection is saved
SO_IGNORETOBUILD  = 2     # the groups marked VF_IGNORETOBUILDMAP are not saved
SO_DISABLEENHTEX  = 4     # don't write the "//TX1"-style comments required by TXQBSP for enhanced texture positionning
SO_DISABLEFPCOORD = 8     # don't write floating-point coordinates in .map files, round all values

# icon indexes of internal objects (to be used with quarkx.seticons)
iiUnknownFile           = 0
iiExplorerGroup         = 1
iiQuakeC                = 2
iiBsp                   = 3
iiToolBox               = 4
iiUnknown               = 5
iiPakFolder             = 6
iiLinkOverlay           = 7
iiModel                 = 8
iiMap                   = 9
iiPak                   = 10
iiEntity                = 11
iiBrush                 = 12
iiGroup                 = 13
iiDuplicator            = 14
iiPolyhedron            = 15
iiFace                  = 16
iiCfgFolder             = 17
iiCfg                   = 18
iiInvalidPolyhedron     = 19
iiInvalidFace           = 20
iiNewFolder             = 21
iiWad                   = 22
iiTexture               = 23
iiTextureLnk            = 24
iiPcx                   = 25
iiQuArK                 = 26
iiTexParams             = 27
iiQme                   = 28
iiToolbar               = 29
iiToolbarButton         = 30
 # iiFrameGroup            = 31
 # iiSkinGroup             = 32
 # iiSkin                  = 33
iiFrame                 = 34
iiComponent             = 35
iiModelGroup            = 36
iiQCtx                  = 37
iiWav                   = 38
iiCin                   = 39
iiText                  = 40
iiCfgFile               = 41
iiImport                = 42
iiPython                = 43
iiBezier                = 44
#Sprite File Support
iiSprFile		= 45
iiTotalImageCount       = 46


def LoadIconSet(filename, width, transparencypt=(0,0)):
    "Load a set of bitmap files and returns a tuple of image lists."

    def loadset(tag, filename=filename, width=width, transparencypt=transparencypt, setup=quarkx.setupsubset(SS_GENERAL, "Display"), cache={}):
        if setup[tag]:
            ext = "-1.bmp"
        else:
            ext = "-0.bmp"
        try:
            return cache[ext]
        except:
            img = quarkx.loadimages(filename + ext, width, transparencypt)
            cache[ext] = img
            return img

    # load the unselected version of the icons
    unsel = loadset("Unsel")

    # load the selected version of the icons
    sel = loadset("Sel")

    # load xxx-2.bmp, the triggered version for on/off buttons
    try:
        trig = quarkx.loadimages(filename + "-2.bmp", width, transparencypt)
        return (unsel, sel, trig)
    except quarkx.error:
        return (unsel, sel)


def LoadIconSet1(filename, width, transparencypt=(0,0)):
    return LoadIconSet(quarkx.setupsubset(SS_GENERAL, "Display")["IconPath"]+filename, width, transparencypt)


#
# Map modules loader (map*.py modules require a special load order)
#
def loadmapeditor():
    global loadmapeditor
    import maputils
    import mapeditor
    import mapmenus
    #---- import the plug-ins ----
    import plugins
    plugins.LoadPlugins("MAP")
    #-----------------------------
    loadmapeditor = lambda: None    # next calls to loadmapeditor() do nothing

#
# Model modules loader (mdl*.py modules require a special load order)
#
def loadmdleditor():
    global loadmdleditor
    import mdlutils
    import mdleditor
    import mdlmenus
    #---- import the plug-ins ----
    import plugins
    plugins.LoadPlugins("MDL")
    #-----------------------------
    loadmdleditor = lambda: None    # next calls to loadmdleditor() do nothing


# Default icons for the objects
ico_objects = LoadIconSet("images\\objects", 16)

# Generic editor icons
ico_editor = LoadIconSet("images\\editor", 16)


#
# Variable icons handlers for Quake entities
#

def EntityIcon(entity, iconset):
    #
    # Load the Variable icons for Quake Entity objects
    #
    global ico_mapents
    try:
        icons = ico_mapents[iconset]
    except NameError:
        ico_mapents = LoadIconSet("images\\mapents", 16)
        icons = ico_mapents[iconset]
    #
    # Read the classname of the entity
    #
    name = entity.shortname
    #
    # Analyse the beginning of the classname
    #
    if name[:4]=="item" or name[:6]=="weapon" or name[:9]=="wp_weapon" or name[:4]=="art_":
        return icons[1]
    if name[:4]=="info":
        return icons[2]
    if name[:5]=="light":
        return icons[3]
    if name[:7]=="monster":
        return icons[0]
    return icons[4]

def EntityIconSel(entity):
    return EntityIcon(entity, 1)

def EntityIconUnsel(entity):
    return EntityIcon(entity, 0)


#
# Variable icons handlers for duplicators
#

def DuplicatorIconUnsel(dup):
    loadmapeditor()
    import mapduplicator
    iconlist, iconindex = mapduplicator.DupManager(dup).Icon
    return iconlist[0][iconindex]

def DuplicatorIconSel(dup):
    loadmapeditor()
    import mapduplicator
    iconlist, iconindex = mapduplicator.DupManager(dup).Icon
    return iconlist[1][iconindex]



#
# Variable icons handlers for groups
#

def GroupIconUnsel(grp, ico_objects_group_set={
  (0,0):ico_objects[0][32],
  (0,1):ico_objects[0][13],
  (4,0):ico_objects[0][33],
  (4,1):ico_objects[0][31]}):
    if grp[";view"]:
        try:
            view = int(grp[";view"])
            return ico_objects_group_set[view&4, not (view&~4)]
        except:
            pass
    return ico_objects[0][13]

def GroupIconSel(grp, ico_objects_group_set={
  (0,0):ico_objects[1][32],
  (0,1):ico_objects[1][13],
  (4,0):ico_objects[1][33],
  (4,1):ico_objects[1][31]}):
    if grp[";view"]:
        try:
            view = int(grp[";view"])
            return ico_objects_group_set[view&4, not (view&~4)]
        except:
            pass
    return ico_objects[1][13]


#
# Variable icons handlers for Model objects
#

def ModelIcon(modelobj, iconset):
    #
    # Load the Variable icons for Quake Entity objects
    #
    global ico_mdlobjs
    try:
        icons = ico_mdlobjs[iconset]
    except NameError:
        ico_mdlobjs = LoadIconSet("images\\mdlobjs", 16)
        icons = ico_mdlobjs[iconset]
    #
    # Read the type tag of the model
    #
    tag = modelobj.getint("type")
    if tag < len(icons):
        return icons[tag]
    else:
        return ico_objects[iconset][iiUnknown]


def ModelGroupIconSel(obj):
    return ModelIcon(obj, 1)

def ModelGroupIconUnsel(obj):
    return ModelIcon(obj, 0)



# quarkx.msgbox
MT_WARNING           = 0
MT_ERROR             = 1
MT_INFORMATION       = 2
MT_CONFIRMATION      = 3
MB_YES               = 1
MB_NO                = 2
MB_OK                = 4
MB_CANCEL            = 8
MB_ABORT             = 16
MB_RETRY             = 32
MB_IGNORE            = 64
MB_ALL               = 128
# MB_HELP            = 256
MB_YES_NO_CANCEL     = MB_YES | MB_NO | MB_CANCEL
MB_OK_CANCEL         = MB_OK | MB_CANCEL
MB_ABORT_RETRY_IGNORE= MB_ABORT | MB_RETRY | MB_IGNORE
MR_OK     = 1
MR_CANCEL = 2
MR_ABORT  = 3
MR_RETRY  = 4
MR_IGNORE = 5
MR_YES    = 6
MR_NO     = 7
MR_ALL    = 8

# "style" of ":form" objects (convert the numeric value into a string to assign to "style")
GF_GRAY       = 1
GF_EXTRASPACE = 2
GF_NOICONS    = 4
GF_NOBORDER   = 8

# file attributes
FA_READONLY     = 1
FA_HIDDEN       = 2
FA_ARCHIVE      = 32
FA_FILENOTFOUND = -1
FA_DELETEFILE   = -1


SetupRoutines = []

def SetupChanged(level):
    "Called by QuArK when the setup is modified."
    for s in SetupRoutines:
        s(level)


#
# Pool Manager : when you read data that don't change, like icon
# bitmaps, you should store the result in the Pool so that if you
# need the data again you don't have to reload it. So instead of :
#     functionthatloadstuff(argument, ...)
# write :
#     LoadPoolObj(uniquestring, functionthatloadstuff, argument, ...)
#

def LoadPoolObj(tag, loadfn, *loadargs):
    "Retrive the content of a pool object, or call a function if not found."

    obj = quarkx.poolobj(tag)
    if obj == None:
        obj = apply(loadfn, loadargs)
        quarkx.setpoolobj(tag, obj)
    return obj


def debug(text):
    import sys
    sys.stderr.write(text+"\n")



#---- import the plug-ins ----
import plugins
plugins.LoadPlugins("Q_")
#-----------------------------

