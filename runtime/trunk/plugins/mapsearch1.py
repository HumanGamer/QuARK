"""   QuArK  -  Quake Army Knife

Implementation of QuArK Map editor features for the "Search" menu
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$


Info = {
   "plug-in":       "Basic Search",
   "desc":          "Basic items for the Search menu.",
   "date":          "31 oct 98",
   "author":        "Armin Rigo",
   "author e-mail": "arigo@planetquake.com",
   "quark":         "Version 5.1" }


import string
import quarkpy.qmenu
import quarkpy.qmacro
import quarkpy.mapsearch
import quarkpy.mapentities
from quarkpy.maputils import *


#
# Search broken polyhedron and faces.
#

def Brok1Click(m):
    editor = mapeditor()
    if editor is None: return
    list = editor.Root.findallsubitems("", ':p')+editor.Root.findallsubitems("", ':f')
    list = filter(lambda p: p.broken, list)
    quarkpy.mapsearch.SearchResult(editor, list)



class SearchDlg(quarkpy.qmacro.dialogbox):

    src_backup = {}

    def __init__(self, reserved):
        editor = mapeditor()
        self.sellist = editor.visualselection()

        src = quarkx.newobj(":")
        if not self.sellist:
            src ["scope"] = "W"
            src ["scope$Items"] = "Whole map"
            src ["scope$Values"] = "W"
        else:
            src ["scope"] = "W"  ## "S"
            src ["scope$Items"] = "Selection\nWhole map"
            src ["scope$Values"] = "S\nW"

        src["kind"] = "e,b"
        slist = ["All entities"]
        klist = ["e,b"]
        for key, value in quarkpy.mapentities.Mapping.items():
            klist.append(key[1:])
            if value.__class__.__doc__:
                slist.append(value.__class__.__doc__)
            else:
                slist.append("'%s' objects" % key)
        slist.append("All objects")
        klist.append(string.join(klist[1:], ","))
        src["kind$Items"] = string.join(slist, "\015")
        src["kind$Values"] = string.join(klist, "\015")

        for key, value in self.src_backup.items():
            src[key]=value


        quarkpy.qmacro.dialogbox.__init__(self, quarkx.clickform, src,
          ok = qtoolbar.button(self.search, "search for the given classname", ico_editor, 1, " Search ", 1),
          cancel = qtoolbar.button(self.close, "close this box", ico_editor, 0, " Cancel ", 1))
        self.editor = editor

    def search(self, reserved):
        quarkx.globalaccept()
        self.__class__.src_backup = self.src.dictspec
        quarkpy.mapsearch.SearchResult(self.editor, self.search1())
        self.close()

    def search_list(self, classname=None):
        classname = classname or ""
        if self.src["scope"] == "S" and self.sellist:
            sellist = self.sellist
        else:
            sellist = self.editor.Root.subitems
        list = []
        def fix(s):
            s = string.strip(s)
            if s[:1] != ':':
                return ':'+s
            return s
        tlist = map(fix, string.split(self.src["kind"], ","))
        for obj in sellist:
            for t in tlist:
                list = list + obj.findallsubitems(classname, t)
        return list


#
# Search by Classname.
#

class SearchByName(SearchDlg):

    #
    # dialog layout
    #

    size = (300, 194)
    dfsep = 0.4        # separation at 40% between labels and edit boxes

    dlgdef = """
      {
        Style = "15"
        Caption = "Search by classname"
        sep: = {Typ="S" Txt=" "}
        classname: = {
          Txt = " Search for :"
          Typ = "E"
          SelectMe = "1"
        }
        scope: = {
          Typ = "CL"
          Txt = " Search in :"
          Items = "%s"
          Values = "%s"
        }
        kind: = {
          Typ = "C"
          Txt = " Object type :"
          Items = "%s"
          Values = "%s"
        }
        sep: = {Typ="S" Txt=" "}
        sep: = {Typ="S" Txt=" "}
        ok:py = { }
        cancel:py = { }
      }
    """

    def search1(self):
        return self.search_list(self.src["classname"])


#
# Search by Specific/Arg.
#

class SearchBySpec(SearchDlg):

    #
    # dialog layout
    #

    size = (300, 214)
    dfsep = 0.4        # separation at 40% between labels and edit boxes

    dlgdef = """
      {
        Style = "15"
        Caption = "Search by Specific/Arg"
        sep: = {Typ="S" Txt=" "}
        spec: = {
          Txt = " Search for Specific :"
          Typ = "E"
          SelectMe = "1"
          Hint = "Specific to search for (optionnal)"
        }
        arg: = {
          Txt = " Search for Arg :"
          Typ = "E"
          Hint = "Arg to search for (optionnal)"
        }
        scope: = {
          Typ = "CL"
          Txt = " Search in :"
          Items = "%s"
          Values = "%s"
        }
        kind: = {
          Typ = "C"
          Txt = " Object type :"
          Items = "%s"
          Values = "%s"
        }
        sep: = {Typ="S" Txt=" "}
        sep: = {Typ="S"}
        ok:py = { }
        cancel:py = { }
      }
    """

    def search1(self):
        spec = self.src["spec"]
        arg = self.src["arg"]
        list = self.search_list()

        if not spec:
            if not arg:
                testfn = lambda x: 1
            else:
                def testfn(obj, arg0=arg):
                    for spec, arg in obj.dictspec.items():
                        if arg == arg0:
                            return 1
                    return 0
        else:
            if not arg:
                def testfn(obj, spec0=spec):
                    return obj[spec0]
            else:
                def testfn(obj, spec0=spec, arg0=arg):
                    return obj[spec0]==arg0

        return filter(testfn, list)



#
# Register these new menu items for the "Search" menu.
#

quarkpy.mapsearch.items.append(quarkpy.qmenu.item("Object by &name", SearchByName))
quarkpy.mapsearch.items.append(quarkpy.qmenu.item("Object by &Specific", SearchBySpec))
quarkpy.mapsearch.items.append(quarkpy.qmenu.item("&Broken polys and faces", Brok1Click))


# ----------- REVISION HISTORY ------------
#
#
# $Log$
# Revision 1.2  2000/06/03 10:25:30  alexander
# added cvs headers
#
#
#
#