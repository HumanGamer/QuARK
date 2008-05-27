"""   QuArK  -  Quake Army Knife

Routines to execute Quake, Hexen II, or Quake 2
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#
#$Header$


import quarkx
from qdictionnary import Strings
import qutils
qutils.loadmapeditor()
from maputils import *
import qconsole


def BuildConsole():
    return quarkx.setupsubset()["Console"]


class BatchConsole(qconsole.console):
    "StdOut console for programs that run in batch."

    def __init__(self, cmdline, currentdir, next):
        qconsole.console.__init__(self, SILVER)
        self.cmdline = cmdline
        self.currentdir = currentdir
        self.next = next

    def close(self):
        try:
            fn = self.next.run
        except:
            return
        del self.next
        fn()

    def goon(self, reserved):
        self.close()

    def run(self):
        if BuildConsole():
            qconsole.runprogram(self.cmdline, self.currentdir, self)
        else:
            qconsole.runprogram(self.cmdline, self.currentdir).onexit(self.goon)



class GameConsole(BatchConsole):
    "StdOut console to run the game."

    DONT_RUN = 0
    NO_MAP = 1

    def __init__(self, map, filelist, cfgfile, forcepak, next):
        setup = quarkx.setupsubset()

        flst = []
        playerclass = setup["PlayerClass"]
        if playerclass:
            # 'PlayerClass' is specifically only for Hexen-II
            if playerclass != "X":
                cfgfile = "%splayerclass %s\n" % (cfgfile, playerclass)
            cfg = quarkx.newfileobj("quark.cfg")
            cfg["Data"] = cfgfile
            flst.append(("quark.cfg", cfg))
        else:
            cfgfile = None
        for cf in quarkx.getqctxlist(":", "CreateFiles"):
            for fobj in cf.subitems:
                flst.append((fobj.name, fobj.copy()))
        for f in filelist:
            flst.append((f, None))
        self.filelistdata = flst
        self.pakfile = quarkx.outputpakfile(forcepak)

        dir = quarkx.getquakedir()
        program = setup["Program"]
        tmpquarkdir = quarkx.gettmpquark()
        if not dir or not program:
            quarkx.openconfigdlg(":")
            raise "Invalid configuration of the game executable"

        if map is self.DONT_RUN:
            cmdline = ""
        else:
            format = setup["ExtraCmdLine"]
            customdir = quarkx.outputfile()  # get the current tmpQuArK directory
            if format:
                cmdline = program + " " + format % customdir
            else:
                cmdline = program
            if map is not self.NO_MAP:
                #debug('rowdy: before mangle run game command: "%s"' % cmdline)
                #cmdline = cmdline + setup["RunMapCmdLine"] % map

                # assume we have a clever game that can run anywhere, although we will probably
                # be running it from the game directory anyway
                argument_mappath = "maps"
                argument_mapfile = "maps/%s.map" % map
                argument_file    = "maps/%s" % map
                argument_filename= "%s" % map

                # this part is supposed to take care of games that do not need special processing
                runMapCmdLine = setup["RunMapCmdLine"]
                if not(runMapCmdLine is None):
                    #debug('rowdy: RunMapCmdLine before: "%s"' % runMapCmdLine)
                    if runMapCmdLine.find('%s') != -1:
                        runMapCmdLine = runMapCmdLine % map
                    #debug('rowdy: RunMapCmdLine after: "%s"' % runMapCmdLine)
                    cmdline = cmdline + ' ' + runMapCmdLine

                cmdline = cmdline.replace("%mappath%",  argument_mappath)
                cmdline = cmdline.replace("%mapfile%",  argument_mapfile)
                cmdline = cmdline.replace("%file%",     argument_file)
                cmdline = cmdline.replace("%filename%", argument_filename)
                cmdline = cmdline.replace("%basepath%", dir)
                cmdline = cmdline.replace("%gamedir%", tmpquarkdir)
                cmdline = cmdline.replace("%quarkpath%", quarkx.exepath)

                #debug('rowdy: after mangle run game command: "%s"' % cmdline)

        BatchConsole.__init__(self, cmdline, dir, next)


    def run(self):

        writeto = self.pakfile
        if writeto:
            pak = quarkx.newfileobj(writeto)
            pak["temp"] = "1"
            for qname, qobj in self.filelistdata:
                nopak = qname[:1]=='*'
                if nopak:
                    qname = qname[1:]
                err = ": ready"
                if qobj is None:
                    try:
                        qobj = quarkx.openfileobj(quarkx.outputfile(qname))
                    except:
                        err = ": ignored"
                if qobj is not None:
                    if nopak:
                        if quarkx.getfileattr(quarkx.outputfile(qname))>-1: #DECKER - do not overwrite something that already is there!
                            err = ": exists"                                #DECKER
                        else:                                               #DECKER
                            qobj.savefile(quarkx.outputfile(qname))
                    else:
                        type1 = qobj.type.upper()
                        if type1:
                            type2 = qname[-len(type1):].upper()
                            if type1 != type2:
                                raise "Invalid file types : %s should be of type %s" % (qname,type1)
                            qname = qname[:-len(type1)]
                        i = len(qname)
                        while i and not (qname[i-1] in ("/", "\\")):
                            i = i - 1
                        folder = pak.getfolder(qname[:i])
                        qobj.shortname = qname[i:]
                        folder.appenditem(qobj)
                print "/" + qname + err
            pak.filename = writeto
            pak.savefile()
        else:
            writeto = quarkx.outputfile("")
            for qname, qobj in self.filelistdata:
                if qname[:1]=='*':
                    qname = qname[1:]
                fname = quarkx.outputfile(qname)
                err = ": ready"
                if qobj is None:
                    if quarkx.getfileattr(fname)==-1:
                        err = ": ignored"
                else:
                    if quarkx.getfileattr(fname)>-1:    #DECKER - do not overwrite something that already is there!
                        err = ": exists"                #DECKER
                    else:                               #DECKER
                        qobj.savefile(fname)
                print "/" + qname + err
        print "Files stored in %s" % writeto
        del self.filelistdata

        if not self.cmdline:
            print "Operation finished."
        else:
            #
            # Run Quake !
            #
            formlist = quarkx.forms()
            if len(formlist):
                try:    # free some memory and closes 3D views
                    formlist[0].macro("FREE")
                except:
                    pass
            del formlist

            process = qconsole.runprogram(self.cmdline, self.currentdir, None)   # no console
            process.onexit(self.progexit)


    def progexit(self, reserved):
        self.close()

    def close(self):
        BatchConsole.close(self)
        try:
            del self.filelistdata
        except:
            pass

# ----------- REVISION HISTORY ------------
#
#
#$Log$
#Revision 1.15  2007/08/21 10:26:35  danielpharos
#Small changes to let HL2 build again.
#
#Revision 1.14  2007/03/22 22:27:31  danielpharos
#Fixed a typo.
#
#Revision 1.13  2006/11/30 01:19:33  cdunde
#To fix for filtering purposes, we do NOT want to use capital letters for cvs.
#
#Revision 1.12  2006/11/29 07:00:26  cdunde
#To merge all runtime files that had changes from DanielPharos branch
#to HEAD for QuArK 6.5.0 Beta 1.
#
#Revision 1.11.2.2  2006/11/01 22:22:42  danielpharos
#BackUp 1 November 2006
#Mainly reduce OpenGL memory leak
#
#Revision 1.11  2006/05/07 07:02:07  rowdy
#Added a rough hack to allow %file% type substitution in the '<game> command-line' option.  Also added %filename% parameter that is replaced with the map filename (without path, without extension).
#
#Revision 1.10  2005/10/15 00:47:57  cdunde
#To reinstate headers and history
#
#Revision 1.7  2003/12/17 13:58:59  peter-b
#- Rewrote defines for setting Python version
#- Removed back-compatibility with Python 1.5
#- Removed reliance on external string library from Python scripts
#
#Revision 1.6  2001/07/08 20:56:30  tiglari
#fix crash when ExtraCMDLine=""
#
#Revision 1.5  2001/06/21 17:34:12  decker_dk
#quarkx.openconfigdlg()
#
#Revision 1.4  2000/06/02 16:00:22  alexander
#added cvs headers
#
#
#
