"""   QuArK  -  Quake Army Knife

Implementation of QuArK Map editor's "Quake" menu
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#


import string
import quarkx
from qdictionnary import Strings
from maputils import *
import qmenu
import qquake



class BspConsole(qquake.BatchConsole):
    "StdOut console for programs that modify a .bsp file."

    def __init__(self, cmdline, currentdir, bspfile, editor, next):
        qquake.BatchConsole.__init__(self, cmdline, currentdir, next)
        try:
            attr = quarkx.getfileattr(bspfile)
            if (attr!=FA_FILENOTFOUND) and (attr&FA_ARCHIVE):
                quarkx.setfileattr(bspfile, attr-FA_ARCHIVE)
        except quarkx.error:
            pass
        self.bspfile = bspfile

    def close(self):
        attr = quarkx.getfileattr(self.bspfile)
        if (attr==FA_FILENOTFOUND) or not (attr&FA_ARCHIVE):
            print "-"*79
            print "Failed to build the file", self.bspfile
            quarkx.console()
            del self.next
        else:
            qquake.BatchConsole.close(self)
            return 1

#df<-**************************************************************************
#see qconsole.py, qquake.py (Batch may work better for MAPWALK)
class Map2CSConsole(qquake.BatchConsole):
    "StdOut console for non-bsp programs." 
    def __init__(self, cmdline, currentdir, next):
        qquake.BatchConsole.__init__(self, cmdline, currentdir, next)

    def close(self):
        qquake.BatchConsole.close(self)
        return 1    
#df->***************************************************************************    


class QBSPConsole(BspConsole):
    "BspConsole for the program QBSP."

    def __init__(self, cmdline, currentdir, bspfile, editor, next):
        BspConsole.__init__(self, cmdline, currentdir, bspfile, editor, next)
        self.editor = editor
        self.linfile = bspfile[:-4] + ".lin"
        try:
            attr = quarkx.getfileattr(self.linfile)
            if (attr!=FA_FILENOTFOUND) and (attr&FA_ARCHIVE):
                quarkx.setfileattr(self.linfile, attr-FA_ARCHIVE)
        except quarkx.error:
            pass


    def close(self):
        if BspConsole.close(self):
            attr = quarkx.getfileattr(self.linfile)
            if (attr!=FA_FILENOTFOUND) and (attr&FA_ARCHIVE):
                if self.editor is None:
                    print "NOTE: QBSP has found a hole in this map"
                else:
                    import mapholes
                    mapholes.LoadLinFile(self.editor, self.linfile)
        self.editor = None



class CloseConsole:
    def run(self):
        if self.console:
            print "Finished !"
        quarkx.console(self.console)



def checkfilename(filename):
    filename = filter(lambda c: c in r"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ$%'-_@{}~`!#()", filename)
    return filename or Strings[180]


def writemapfile(root, mapname, selonly, wadfile, hxstr=None):
    saveflags = 0
    if MapOption("IgnoreToBuild"):
        saveflags = saveflags | SO_IGNORETOBUILD
    if MapOption("DisableEnhTex"):
        saveflags = saveflags | SO_DISABLEENHTEX
    if MapOption("DisableFPCoord"):
        saveflags = saveflags | SO_DISABLEFPCOORD
    if selonly:
        saveflags = saveflags | SO_SELONLY
    m = quarkx.newfileobj(mapname+'.map')
    m.filename = quarkx.outputfile("maps/%s.map" % mapname)
    worldspawn = root.copy(1)   # preserve selection while copying
    m["Root"] = worldspawn.name
    m.setint("saveflags", saveflags)
    m.appenditem(worldspawn)
    if wadfile:
        worldspawn["wad"] = wadfile
    if hxstr:
        m["hxstrings"] = hxstr
    m.savefile()
    return hxstr and m["hxstrings"]


def filesformap(map):
    setup = quarkx.setupsubset()
    map = "maps/"+map
    mapholes = setup["MapHoles"]
    if not mapholes:
        mapholes = ".lin"
    return [map+".bsp", map+mapholes]


def FirstBuildCmd():
    if quarkx.setupsubset()["NeedQCSG"]:
        return "QCSG1"
    else:
        return "QBSP1"


def qmenuitem1click(m):
    editor = mapeditor(SS_MAP)
    if editor is None: return
    if m.info["SelOnly"] and not len(editor.layout.explorer.sellist):
        quarkx.msgbox(Strings[223], MT_ERROR, MB_OK)
        return
    if MapOption("AutoCheckMap", SS_MAP) and m.info[FirstBuildCmd()]:
        import mapsearch
        if mapsearch.CheckMap() == 0:
            return
    if m.info["RunGame"]:
        editor.layout.closeOpenGL()
    RebuildAndRun([(editor.fileobject, editor.Root, m.info)], editor, m.info["RunGame"], m.info["MAP2CS1"], m.text, 0, [], "", None)    
#df<-**************************************************************************
#RebuildAndRun([(editor.fileobject, editor.Root, m.info)], editor, m.info["MAP2CS1"], m.text, 0, [], "", None)
      
def RebuildAndRun(maplist, editor, runquake, runmap2cs, text, forcepak, extracted, cfgfile, defaultbsp):
#def RebuildAndRun(maplist, editor, runquake, text, forcepak, extracted, cfgfile, defaultbsp):
    #
    # Turn the "extracted" to lowercase.
    #

    for i in range(len(extracted)):
        extracted[i] = string.lower(extracted[i])

    #
    # First, extract all textures and compute .map file names.
    #

    if editor is None:
        texsrc = None
    else:
        texsrc = editor.TexSource
    setup = quarkx.setupsubset()
    newlist = []
    textures = {}
    texwarning = 0
    gameneedwad = setup["GameNeedWad"]
    for mapfileobject, root, buildmode in maplist:
        map = string.lower(checkfilename(mapfileobject["FileName"] or mapfileobject.shortname))
        mapinfo = {"map": map}
        if buildmode["QCSG1"] or buildmode["QBSP1"] or buildmode["VIS1"] or buildmode["LIGHT1"]:
            bspfile = quarkx.outputfile("maps/%s.bsp" % map)
            if bspfile in extracted:
                continue
            extracted = extracted + filesformap(map)
            newlist.append((mapfileobject, root, buildmode, mapinfo))
        #
        # Find textures used in map
        #
        if buildmode["Textures"] or gameneedwad:
            list2 = quarkx.texturesof([root])
        if gameneedwad:
            texwad = "%s.wad" % map
            list = []
            wadlist = {}
            for t in list2:
                t1 = quarkx.loadtexture(t)
                if t1 is None:
                    texwarning = texwarning + 1
                elif (t1.type == '.wl') and t1["h"]:        # Half-Life texture link
                    wadlist["../"+t1["s"]+"/"+t1["d"]+".wad"] = None
                else:
                    list.append(t)
            list2 = list
            if len(list2):
                wadlist[texwad] = None
            mapinfo["wad"] = string.join(wadlist.keys(), ';')
        else:
            texwad = setup["TextureWad"]
            mapinfo["wad"] = texwad
        if buildmode["Textures"] and len(list2):
            try:       # put the textures in the list of textures to extract
                texlist = textures[texwad]
            except:
                texlist = []
                textures[texwad] = texlist
            for t in list2:
                if not (t in texlist):
                    texlist.append(t)

    if texwarning:
        if quarkx.msgbox(Strings[-103] % texwarning, MT_WARNING, MB_OK_CANCEL) != MR_YES:
            return

    texcount = None
    for texwad, texlist in textures.items():
        if gameneedwad:
            setup["TextureWad"] = texwad
        list2 = quarkx.maptextures(texlist, 2, texsrc)    # extract the textures
        texlist = len(texlist)
        list2 = len(list2)
        if texcount is not None:
            texlist = texlist + texcount[0]
            list2 = list2 + texcount[1]
        texcount = (texlist, list2)

    if gameneedwad:
        setup["TextureWad"] = "?"
    if texcount is None:    # extract at least the base files
        quarkx.maptextures([], 2)

    #
    # Precompute a few variables.
    #

    tmpquark = quarkx.outputfile("")
    if tmpquark[-1]=='\\':
        tmpquark = tmpquark[:-1]
    consolecloser = CloseConsole()   # close or reopens the console at the end
    consolecloser.console = len(maplist) and maplist[-1][2]["Pause"]
    next = consolecloser
    missing = ""
    hxstr = ""
    hxstrfile = setup["HxStrings"]
    if hxstrfile and len(maplist):
        try:
            hxstr = quarkx.needgamefile(hxstrfile)["Data"]
            extracted.append(string.lower(hxstrfile))
        except:
            pass
    firstcmd = FirstBuildCmd()

    if runquake or len(extracted):
        if runquake:    # if we have to run the game
            if defaultbsp:
                map = defaultbsp
            elif len(newlist):
                map = newlist[0][3]["map"]
            elif len(maplist)==1:
                map = mapinfo["map"]
            else:
                map = qquake.GameConsole.NO_MAP
                cfgfile = cfgfile + "echo\necho \"No map to begin with.\"\necho \"To choose a map, type: map <filename>\"\n"
        else:
            map = qquake.GameConsole.DONT_RUN
        next = qquake.GameConsole(map, extracted, cfgfile, forcepak, next)

# Df modifedied by pm *******************************************************
#this is for map2cs (commandline works)  
    if runmap2cs:             
        mapfileobject = editor.fileobject
        map = string.lower(checkfilename(mapfileobject["FileName"] or mapfileobject.shortname))
        mapfile = "./maps/" + map + ".map"
        map2cszfile = map + ".csz"
        mapcfg = "../map2cs.cfg"
        Cmd = mapfile + " " + map2cszfile + " " + mapcfg
        cmdline = setup["MAP2CS1"]
        cmdline = '"%s"' % cmdline
        cmdline = cmdline + " " + Cmd
        next = Map2CSConsole(cmdline, tmpquark, next) 
# Df modifedied by pm *******************************************************


    #
    # Loop through the maps to rebuild.
    #

    newlist.reverse()
    for mapfileobject, root, buildmode, mapinfo in newlist:

        map = mapinfo["map"]
        mapcmd = "./maps/" + map
        bspfile = quarkx.outputfile("maps/%s.bsp" % map)

        for pgrm, console in (("LIGHT", BspConsole), ("VIS", BspConsole), ("QBSP", QBSPConsole), ("QCSG", BspConsole)):
            pgrm1 = pgrm+"1"
            if buildmode[pgrm1]:    # prepare to run this program
                cmdline = setup[pgrm1]
                if (not cmdline) or (quarkx.getfileattr(cmdline)==FA_FILENOTFOUND):
                    desc = setup[pgrm+"Desc"] or pgrm
                    missing = "     %s\n%s" % (desc, missing)
                else:
                    cmdline = '"%s"' % cmdline
                    pgrmcmd = pgrm+"Cmd"
                    p1 = setup[pgrmcmd]
                    if p1: cmdline = cmdline + " " + p1
                    p1 = buildmode[pgrmcmd]
                    if p1: cmdline = cmdline + " " + p1
                    next = console(cmdline + " " + mapcmd, tmpquark, bspfile, editor, next)
            if pgrm1 == firstcmd:
                break

        if missing:
            msg = "%s\n%s" % (missing, Strings[5586])
            if quarkx.msgbox(msg, MT_CONFIRMATION, MB_YES | MB_NO) == MR_YES:
                quarkx.openconfigdlg(":")
            return

        if buildmode[firstcmd]:    # if we have to run QBSP
            hxstr = writemapfile(root, map, buildmode["SelOnly"], mapinfo["wad"], hxstr)

    hxstr = writemapfile(root, map, buildmode["SelOnly"], mapinfo["wad"], hxstr)
    if hxstr:
        hxf = quarkx.newfileobj("hxstr.txt")
        hxf["Data"] = hxstr
        del hxstr
        hxf.savefile(quarkx.outputfile(hxstrfile))
        del hxf

    #
    # AutoSave
    #
    if quarkx.setupsubset(SS_MAP, "Building")["AutoSaveRun"] and editor is not None:
        editor.AutoSave()

    #
    # Run the above queued programs in the console.
    #

    if next is not consolecloser:
        print
        str = " " + filter(lambda c: c!="&", text) + " "
        l = (79-len(str))/2
        if l>0:
            str = "_"*l + str + "_"*l
        print str
        print
        if qquake.BuildConsole():
            quarkx.console()
        next.run()    # do it !

    elif texcount is not None:
        target = setup["TextureWad"] or setup["Q2TexPath"]
        target = quarkx.outputfile(target)
        c1,c2 = texcount
        if c1<c2:
            msg = Strings[5590] % (c2, target, c2-c1)
        else:
            msg = Strings[5589] % (c2, target)
        quarkx.msgbox(msg, MT_INFORMATION, MB_OK)

    else:
        quarkx.msgbox(Strings[5653], MT_INFORMATION, MB_OK)


def Customize1Click(mnu):
    editor = mapeditor(SS_MAP)
    if editor is None: return
    setup = quarkx.setupsubset()
    if setup["NeedQCSG"]:
        form1 = "CustomQuakeMenuQCSG"
    else:
        form1 = "CustomQuakeMenu"
    gamename = setup.shortname
    # Pete Mistich ************************************************************
    sourcenameP = "%s" % gamename
    if sourcenameP == 'CrystalSpace':
        form1 = "CustomQuakeMenuMAP2CS"
    # Pete Mistich ************************************************************
    group = quarkx.newobj("%s menu:config"%gamename)
    sourcename = "UserData %s.qrk" % gamename
    file = LoadPoolObj(sourcename, quarkx.openfileobj, sourcename)
    ud = file.findname("Menu.qrk")
    for p in ud.subitems:
        txt = p["Txt"]
        ci = quarkx.newobj("%s.toolbar"%txt)
        ci.copyalldata(p)
        ci["Form"] = (form1, "CustomQuakeMenuSep")[txt=="-"]
        group.appenditem(ci)
    #explorer.addroot(group)
    newitem = quarkx.newobj("menu item.toolbar")
    newitem[";desc"] = "create a new menu item"
    newitem["Form"] = form1
    newsep = quarkx.newobj("-.toolbar")
    newsep[";desc"] = "create a new separator"
    newsep["Form"] = "CustomQuakeMenuSep"
    if quarkx.openconfigdlg("Customize %s menu" % gamename, group,
     [newsep, newitem]):
        for i in range(ud.itemcount-1, -1, -1):
            ud.removeitem(i)
        for ci in group.subitems:
            p = quarkx.newobj("item:")
            p.copyalldata(ci)
            p["Form"] = None
            p["Txt"] = ci.shortname
            ud.appenditem(p)
        editor.initmenu(quarkx.clickform)
        file.savefile()


def QuakeMenu(editor):
    "The Quake menu, with its shortcuts."

     # this menu is read from UserData.qrk.

    items = []
    sc = {}
    isbsp = "Bsp" in editor.fileobject.classes   # some items don't apply for BSP files
    gamename = quarkx.setupsubset().shortname
    firstcmd = FirstBuildCmd()
    sourcename = "UserData %s.qrk" % gamename
    ud = LoadPoolObj(sourcename, quarkx.openfileobj, sourcename)
    ud = ud.findname("Menu.qrk")
    if ud is not None:
        for p in ud.subitems:
            txt = p["Txt"]
            if txt=="-":
                items.append(qmenu.sep)
            else:
                m = qmenu.item(txt, qmenuitem1click, "|The commands in this menu lets you run your map with the game. The most common commands are the first few ones, which lets you try your map as a one-step operation.\n\nBefore a map can be played, it must be compiled (translated into a .bsp file). This is done by other programs that QuArK will call for you. See the Configuration dialog box, under the page of this game, where you must tell QuArK where these programs are installed. The programs themselves are available in Build Packs, one for each game you want to make maps for, and that can be downloaded from http://www.planetquake.com/quark (page Armin's News).")
                m.info = p
                if isbsp and p[firstcmd]:
                    m.state = qmenu.disabled
                elif p["Shortcut"]:
                    sc[p["Shortcut"]] = m
                items.append(m)
        items.append(qmenu.sep)
        items.append(qmenu.item("&Customize menu...", Customize1Click, "customizes this menu"))
    Quake1 = qmenu.popup("&"+gamename, items)
    Quake1.state = not len(items) and qmenu.disabled
    return Quake1, sc

