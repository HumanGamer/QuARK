"""   QuArK  -  Quake Army Knife

Implementation of QuArK Model editor's "Options" menu
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$



import quarkx
from qdictionnary import Strings
from mdlutils import *
import qmenu



def ToggleOption(item):
    "Toggle an option in the setup."
    tag = item.tog
    setup = apply(quarkx.setupsubset, item.sset)
    newvalue = not setup[tag]
    setup[tag] = "1"[:newvalue]
    if item.sendupdate[newvalue]:
        quarkx.reloadsetup()


def Config1Click(item):
    "Configuration Dialog Box."
    quarkx.openconfigdlg()

def Plugins1Click(item):
    "Lists the loaded plug-ins."
    import plugins
    group = quarkx.newobj("Loaded Plug-ins:config")
    for p in plugins.LoadedPlugins:
        txt = p.__name__.split(".")[-1]
        ci = quarkx.newobj("%s.toolbar" % txt)
        try:
            info = p.Info
        except:
            info = {}
        for spec, arg in info.items():
            ci[spec] = arg
        ci["File"] = p.__name__
        ci["Form"] = "PluginInfo"
        try:
            ci.shortname = info["plug-in"]
        except:
            pass
        group.appenditem(ci)
    quarkx.openconfigdlg("List of Plug-ins", group)
    

def Options1Click(menu):
    for item in menu.items:
        try:
            setup = apply(quarkx.setupsubset, item.sset)
            item.state = not (not setup[item.tog]) and qmenu.checked
        except:
            pass

def toggleitem(txt, toggle, sendupdate=(1,1), sset=(SS_MODEL,"Options"), hint=None):
    item = qmenu.item(txt, ToggleOption)
    item.tog = toggle
    item.sset = sset
    item.sendupdate = sendupdate
    return item


#
# Global variables to update from plug-ins.
#

items = [
    toggleitem("&Paste objects at screen center", "Recenter", (0,0)),
    ]
shortcuts = { }


def OptionsMenu():
    "The Options menu, with its shortcuts."

    PlugIns = qmenu.item("List of Plug-ins...", Plugins1Click)
    Config1 = qmenu.item("Confi&guration...", Config1Click)
    Options1 = qmenu.popup("&Options", items+[qmenu.sep, PlugIns, Config1], Options1Click)
    return Options1, shortcuts

# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.4  2005/08/31 05:36:32  cdunde
#To add hint argument for toggleitem function.
#
#Revision 1.3  2003/12/17 13:58:59  peter-b
#- Rewrote defines for setting Python version
#- Removed back-compatibility with Python 1.5
#- Removed reliance on external string library from Python scripts
#
#Revision 1.2  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#
