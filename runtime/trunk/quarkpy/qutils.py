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

# window states (needs to match Delphi's TWindowState)
#RESTORED  = 0       # normal
#MINIMIZED = 1
#MAXIMIZED = 2

# filedialogbox
SAVEDIALOG     = 1   # These have to match Delphi's TOpenOptions flags, except for '1', which is overwritten in QuarkX.pas
MULTIPLEFILES  = 64

# setupset
SS_GENERAL     = 0   # These have to match the ones in Setup.pas
SS_GAMES       = 1
SS_MAP         = 2
SS_MODEL       = 3
SS_TOOLBARS    = 4
SS_FILES       = 5
#SS_TEMP        = 6

# floating windows flags
FWF_NOCAPTION  = 1
FWF_NOCLOSEBOX = 2
FWF_NORESIZE   = 4
FWF_POPUPCLOSE = 8
FWF_NOESCCLOSE = 16
FWF_KEEPFOCUS  = 32

# internal objects' "flags" value (needs to match QkObjects.pas)
OF_TVSUBITEM         = 1   # all objects in a tree-view except top-level
OF_TVINVISIBLE       = 2   # present but invisible in the tree-view
OF_TVALREADYEXPANDED = 4   # node has been expanded once
OF_TVEXPANDED        = 8   # node is expanded
OF_ONDISK            = 16  # has not been loaded yet (loading is automatic when Python code reads the object's Specifics or sub-items)
OF_FILELINK          = 32  # is a file link
OF_WARNBEFORECHANGE  = 64  # warn the user before he makes changes
OF_MODIFIED          = 128 # modified by the user

# values of the ';view' Specific (as text) of TreeMapGroup objects (needs to match QkMapObjects.pas)
VF_GRAYEDOUT        = 1    # whole group is grayed out
VF_HIDDEN           = 2    # whole group is hidden
VF_IGNORETOBUILDMAP = 4    # the group is ignored when writing the .map file with the SO_IGNORETOBUILD flag
VF_HIDEON3DVIEW     = 8    # not displayed on textured views
VF_CANTSELECT       = 16   # the objects in this group can't be selected by clicking on the map view

# values of the 'saveflags' Specific (as integer) of Map objects, to control how it should be saved (needs to match QkMapObjects.pas)
SO_SELONLY         = 1    # only the selection is saved
SO_IGNORETOBUILD   = 2    # the groups marked VF_IGNORETOBUILDMAP are not saved
#SO_DISABLEENHTEX   = 4    # don't write the "//TX1"-style comments required by TXQBSP for enhanced texture positioning
SO_DISABLEFPCOORD  = 8    # don't write floating-point coordinates in .map files, round all values
#SO_ENABLEBRUSHPRIM = 16   # enable brush primitives format
SO_USEINTEGRALVERTICES = 64 # use integral vertices as threepoints if possible

# values of the saveflags for savefileobj (must be same as in QkFileObjects.pas!)
FM_Save           = 1
FM_SaveAsFile     = 2
FM_SaveIfModif    = 3
FM_SaveTagOnly    = 4

# values of FileType parameter for resolvefilename (must be same as in QuarkX.pas!)
FT_ANY  = 0
FT_GAME = 1
FT_TOOL = 2
FT_PATH = 3

# values of the flag for findtoolboxes
TB_CLOSED = 0
TB_HIDDEN = 1
TB_OPEN = 2

# log constants
# !! Must match the constants in Logging.PAS !!
LOG_ALWAYS   = 0
LOG_CRITICAL = 10
LOG_WARNING  = 20
LOG_INFO     = 30
LOG_VERBOSE  = 40

# icon indexes of internal objects (to be used with quarkx.seticons; must be same as in QkObjects.pas!)
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
iiGroupXed              = 31
iiGroupHidden           = 32
iiGroupHiddenXed        = 33
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
iiSprFile               = 45
iiMD3Tag                = 46
iiMD3Bone               = 47
iiFormElement           = 48
iiForm                  = 49
iiFormContext           = 50
iiMesh                  = 51

iiTotalImageCount       = 52


#
# Pool Manager : when you read data that doesn't change, like icon
# bitmaps, you should store the result in the Pool so that if you
# need the data again you don't have to reload it. So instead of :
#     functionthatloadstuff(argument, ...)
# write :
#     LoadPoolObj(uniquestring, functionthatloadstuff, argument, ...)
#

def LoadPoolObj(tag, loadfn, *loadargs):
    "Retrieve the content of a pool object, or call a function if not found."

    obj = quarkx.poolobj(tag)
    if obj == None:
        obj = apply(loadfn, loadargs)
        quarkx.setpoolobj(tag, obj)
    return obj


def LoadIconSet(filename, width, transparencypt=(0,0)):
    "Load a set of bitmap files and returns a tuple of image lists."

    def loadset(ext, filename=filename, width=width, transparencypt=transparencypt):
        pooltag = "%s_%i_%s" % (filename + ext, int(width), transparencypt)
        try:
            img = LoadPoolObj(pooltag, quarkx.loadimages, filename + ext, width, transparencypt)
        except quarkx.error:
            return None
        return img

    setup = quarkx.setupsubset(SS_GENERAL, "Display")

    # load the unselected version of the icons
    if setup["Unsel"]:
        unsel = loadset("-1.bmp")
    else:
        unsel = loadset("-0.bmp")

    # load the selected version of the icons
    if setup["Sel"]:
        sel = loadset("-1.bmp")
    else:
        sel = loadset("-0.bmp")

    # load xxx-2.bmp, the triggered version for on/off buttons
    trig = loadset("-2.bmp")
    if trig is None:
        return (unsel, sel)
    else:
        return (unsel, sel, trig)


def LoadIconSet1(filename, width, transparencypt=(0,0)):
    return LoadIconSet(quarkx.setupsubset(SS_GENERAL, "Display")["IconPath"]+filename, width, transparencypt)


#
# Map modules loader (map*.py modules require a special load order)
#
def loadmapeditor(what=None):
    global loadmapeditor
    import maputils
    import mapeditor
    import mapmenus
    #---- import the plug-ins ----
    import plugins
    plugins.LoadPlugins("MAP")

    def reLoad(what=None):
        #---- import the bezier plug-ins if so stated in Defaults.QRK ----
        #---- and bsp support if we're editing a bsp
        if what=='bsp':
            plugins.LoadPlugins("BSP")

        beziersupport = quarkx.setupsubset()["BezierPatchSupport"]
        if (beziersupport is not None) and (beziersupport == "1"):
            pluginprefixes = quarkx.setupsubset()["BezierPatchPluginPrefixes"]
            if (pluginprefixes is None) or (pluginprefixes == ""):
                raise RuntimeError("Serious failure in quarkpy.qutils.loadmapeditor: Missing specific-value 'BezierPatchPluginPrefixes' in Defaults.QRK")
            loadmapeditor = lambda: None # next calls to loadmapeditor() do nothing. Everything is now loaded!
            import mapbezier
            for prefix in pluginprefixes.split():
                plugins.LoadPlugins(prefix.strip())

    # force an initial load of bezier-support, if any for the current game-mode.
    reLoad(what)
    # next call to loadmapeditor, will check to see if there is a new need to load
    # bezier/bsp-support, when/if the user changes game-mode in QuArK explorer.
    loadmapeditor = reLoad

#
# Model modules loader (mdl*.py modules require a special load order)
#
def loadmdleditor():
    global loadmdleditor
    loadmdleditor = lambda: None    # next calls to loadmdleditor() do nothing
    import mdlutils
    import mdleditor
    import mdlmenus
    # --- import the importers/exporters if they haven't been loaded yet
    import qmacro
    qmacro.MACRO_loadmdlimportexportplugins(None)
    #---- import the plug-ins ----
    import plugins
    plugins.LoadPlugins("MDL")


#
# Icon sets that aren't always loaded should go into this
#   dictionary, indexed by their names.  The dictionary
#   is cleaned up in qmacro.MACRO_shutdown to avoid
#   live pointer memory leaks.
#
ico_dict = {}

#
# Putting these two in the ico_dict doesn't achieve
#  any purpose (lots of code gets clunkier, no benefit)
#
# Default icons for the objects
ico_objects = LoadIconSet("images\\objects", 16)

# Generic editor icons
ico_editor = LoadIconSet("images\\editor", 16)

# Note: There are also some icon-loading calls in qeditor.py; search for "Icons for the layout of the Map/Model Editor"


#
# Variable icons handlers for Quake entities
#

def EntityIcon(entity, iconset):
    #
    # Sets the default icons for each entity type, by figuring out their type from their name.
    #
    if not ico_dict.has_key('ico_mapents'):
        ico_dict['ico_mapents'] = LoadIconSet("images\\mapents", 16)
    icons = ico_dict['ico_mapents'][iconset]
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
    if dup.name.startswith("Editor Std 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] == "1":
            iconindex = 4
    elif dup.name.startswith("Editor True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] != "1":
            iconindex = 4
    elif dup.name.startswith("Full3D Standard"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] == "1":
            iconindex = 4
    elif dup.name.startswith("Full3D True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] != "1":
            iconindex = 4
    return iconlist[0][iconindex]

def DuplicatorIconSel(dup):
    loadmapeditor()
    import mapduplicator
    iconlist, iconindex = mapduplicator.DupManager(dup).Icon
    if dup.name.startswith("Editor Std 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] == "1":
            iconindex = 4
    elif dup.name.startswith("Editor True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] != "1":
            iconindex = 4
    elif dup.name.startswith("Full3D Standard"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] == "1":
            iconindex = 4
    elif dup.name.startswith("Full3D True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] != "1":
            iconindex = 4
    return iconlist[1][iconindex]


#
# Variable icons handlers for groups
#

def GroupIconUnsel(grp, ico_objects_group_set={
  (0,0):ico_objects[0][iiGroupHidden],
  (0,1):ico_objects[0][iiGroup],
  (4,0):ico_objects[0][iiGroupHiddenXed],
  (4,1):ico_objects[0][iiGroupXed]}):
    if grp[";view"]:
        try:
            view = int(grp[";view"])
            return ico_objects_group_set[view&4, not (view&~4)]
        except:
            pass
    iiGroup = 13
    if grp.name.startswith("Editor Std 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] == "1":
            iiGroup = 31
    elif grp.name.startswith("Editor True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] != "1":
            iiGroup = 31
    elif grp.name.startswith("Full3D Standard"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] == "1":
            iiGroup = 31
    elif grp.name.startswith("Full3D True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] != "1":
            iiGroup = 31
    return ico_objects[0][iiGroup]

def GroupIconSel(grp, ico_objects_group_set={
  (0,0):ico_objects[1][iiGroupHidden],
  (0,1):ico_objects[1][iiGroup],
  (4,0):ico_objects[1][iiGroupHiddenXed],
  (4,1):ico_objects[1][iiGroupXed]}):
    if grp[";view"]:
        try:
            view = int(grp[";view"])
            return ico_objects_group_set[view&4, not (view&~4)]
        except:
            pass
    iiGroup = 13
    if grp.name.startswith("Editor Std 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] == "1":
            iiGroup = 31
    elif grp.name.startswith("Editor True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["EditorTrue3Dmode"] != "1":
            iiGroup = 31
    elif grp.name.startswith("Full3D Standard"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] == "1":
            iiGroup = 31
    elif grp.name.startswith("Full3D True 3D"):
        if quarkx.setupsubset(SS_MODEL, "Options")["Full3DTrue3Dmode"] != "1":
            iiGroup = 31
    return ico_objects[1][iiGroup]

#
# Variable icons handlers for Model objects
#

def ModelIcon(modelobj, iconset):

    #
    # Sets the default icons for each group type ex: ":sg", ":fg"...
    # Also individual component group type icons can be set here as well.
    # See the "EntityIcon" function above for examples.
    #
    if not ico_dict.has_key('mdlobjs'):
        ico_dict['mdlobjs'] = LoadIconSet("images\\mdlobjs", 16)
    icons = ico_dict['mdlobjs'][iconset]
    #
    # Figure out if this model group is hidden
    #
    DummyItem = modelobj
    while DummyItem is not None:
        if DummyItem.type == ":mr":
            DummyItem = None
            break
        if DummyItem.type == ":mc":
            # Found the parent component!
            break
        DummyItem = DummyItem.parent
    # If it is hidden, draw an X
    if DummyItem is not None:
        if DummyItem['show'] != chr(1):
            return ico_editor[iconset][0]

    # Needed to display the correct icons of these groups for imported models.
    if modelobj.type ==":bbg":
        if modelobj['show'][0] == 1.0:
            return icons[8]
        else:
            return icons[9]
    if modelobj.type ==":fg":
        return icons[1]
    if modelobj.type ==":bg":
        if quarkx.setupsubset(SS_MODEL, "Options")['HideBones'] is not None:
            return icons[7]
        return icons[5]

    #
    # Read the type tag of the model
    #
    tag = modelobj.getint("type")
    if tag < len(icons):
        return icons[tag]
    else:
        return ico_objects[iconset][iiUnknown]

def ModelGroupIconSel(obj):
    "This function is called from the Delphi code, QObject.DisplayDetails function,"
    "for which icon to use when the obj is selected."
    return ModelIcon(obj, 1)

def ModelGroupIconUnsel(obj):
    "This function is called from the Delphi code, QObject.DisplayDetails function,"
    "for which icon to use when the obj is un-selected."
    return ModelIcon(obj, 0)

#
# Variable icons handlers for Model component objects
#

def ComponentIcon(compobj, iconset):
    ##
    ## Sets the default icons for each component.
    ## Also individual component icons can be set here as well.
    ## See the "EntityIcon" function above for examples.
    ##
    #if not ico_dict.has_key('mdlobjs'):
    #    ico_dict['mdlobjs'] = LoadIconSet("images\\mdlobjs", 16)   CHANGE NAME!
    #icons = ico_dict['mdlobjs'][iconset]

    if compobj['show'] == chr(1):
        return ico_objects[iconset][iiComponent]
    else:
        return ico_editor[iconset][0]

def ComponentIconSel(obj):
    return ComponentIcon(obj, 1)

def ComponentIconUnsel(obj):
    return ComponentIcon(obj, 0)

#
# Variable icons handlers for Model bbox (poly:p) objects
#

def BBoxIcon(bbox, iconset):
    if not ico_dict.has_key('ico_objects'):
        ico_dict['ico_objects'] = LoadIconSet("images\\objects", 16)
    icons = ico_dict['ico_objects'][iconset]

    if bbox['show'][0] == 1.0:
        return icons[54]
    else:
        return icons[53]

def BBoxIconSel(bbox):
    from qeditor import mapeditor
    editor = mapeditor()
    if (editor is None) or (editor.MODE != SS_MODEL):
        return ico_objects[1][iiPolyhedron]
    return BBoxIcon(bbox, 1)

def BBoxIconUnsel(bbox):
    from qeditor import mapeditor
    editor = mapeditor()
    if (editor is None) or (editor.MODE != SS_MODEL):
        return ico_objects[0][iiPolyhedron]
    return BBoxIcon(bbox, 0)

#
# Variable icons handlers for Model bone objects
#

def BoneIcon(bone, iconset):
    if not ico_dict.has_key('ico_objects'):
        ico_dict['ico_objects'] = LoadIconSet("images\\objects", 16)
    icons = ico_dict['ico_objects'][iconset]

    if bone['show'][0] == 1.0:
        return icons[47]
    else:
        return icons[51]

def BoneIconSel(bone):
    return BoneIcon(bone, 1)

def BoneIconUnsel(bone):
    return BoneIcon(bone, 0)

#
# Variable icons handlers for Model tag objects
#

def TagIcon(tag, iconset):
    if not ico_dict.has_key('ico_objects'):
        ico_dict['ico_objects'] = LoadIconSet("images\\objects", 16)
    icons = ico_dict['ico_objects'][iconset]

    if not tag.dictspec.has_key("show"):
        tag['show'] = (1.0,)
    if tag['show'][0] == 1.0 and quarkx.setupsubset(SS_MODEL, "Options")['HideTags'] is None:
        return icons[46]
    else:
        return icons[52]

def TagIconSel(tag):
    return TagIcon(tag, 1)

def TagIconUnsel(tag):
    return TagIcon(tag, 0)


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



def debug(text):
    import sys
    sys.stderr.write(text+"\n")
    # rowdy: debug logging #FIXME: Make this a togglable option
    #o = open('c:/rowdy/QuArK_debug.log', 'a')
    #o.write('%s\n' % text)
    #o.close()

def MapHotKey(keytag, keyfunc, menu):
    key = quarkx.setupsubset(SS_GENERAL,"HotKeys")[keytag]
    if key:
        menu.shortcuts[key] = keyfunc

def MapHotKeyList(keytag, keyfunc, list):
    key = quarkx.setupsubset(SS_GENERAL,"HotKeys")[keytag]
    if key:
        list[key] = keyfunc

def clearimagelist(list):
    for (im1, im2) in list:
        del im1
        del im2



#
# Utilities for accessing attributes of objects
#  (class instances) that might not be defined
#
def getAttr(object, attr, default=None):
    if hasattr(object, attr):
        return getattr(object,attr)
    else:
        return default

def delAttr(object, attr):
    if hasattr(object, attr):
         delattr(object, attr)

def appendToAttr(object, attr, thing):
    if hasattr(object, attr):
        getattr(object,attr).append(thing)
    else:
        setattr(object,attr,[thing])

def removeFromAttr(object, attr, thing):
    getattr(object,attr).remove(thing)
    if getattr(object,attr)==[]:
        delattr(object,attr)

def hintPlusInfobaselink(hint, url):
    if url:
        return "%s|%s"%(hint,url)
    return hint



#
# Texture and Color Utilities
# that can be used in both editors.
#

# Converts separate Red, Green, Blue color components into a long integer color.
def RGBToColor(RGB):
    RGB = (65536 * RGB[2]) + (256 * RGB[1]) + RGB[0]
    if RGB > 999999999:
        RGB = int(RGB*.1)
        quarkx.msgbox("RGB caused a long integer !\n\nThe file or function you have\njust used is causing this error\nin converting three R,G,B values\ninto a color integer number.\nThese values should range from 0 to 1.0\nas a percentage of 256 color per channel.\nCheck the file or function code and correct.", MT_ERROR, MB_OK)
    return RGB

# Converts long integer color number into separate color components Red Green Blue (RGB)
# Returns those components as a list of three integer numbers but backwards BGR
#   because that is how Windows and other image editing programs draw them.
def ColorToRGB(Color):
    return (int(round(Color / 65536)) & 255, int(round(Color / 256)) & 255, int(Color) & 255)

# Converts long integer color number into separate color components Red Green Blue (RGB)
# Reverses the R and the B values and returns the new color as a BGR color.
def SwapRandB(LongIntNbr):
    Color = ColorToRGB(LongIntNbr)
    TMPColor = Color[2]
    Color[2] = Color[0]
    Color[0] = TMPColor
    return RGBToColor(Color)

#---- import the plug-ins ----
import plugins
plugins.LoadPlugins("Q_")
#-----------------------------
