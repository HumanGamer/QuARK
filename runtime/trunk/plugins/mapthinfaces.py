"""   QuArK  -  Quake Army Knife

Python code to find thin faces
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

#$Header$

Info = {
   "plug-in":       "Thin Face Finder",
   "desc":          "Thin Face Finder.",
   "date":          "19 Feb 2001",
   "author":        "tiglari",
   "author e-mail": "tiglari@planetquake.com",
   "quark":         "Version 6.3" }


from quarkpy.maputils import *
import quarkpy.mapmenus
import quarkpy.mapcommands
import quarkpy.dlgclasses
import mapmadsel
import quarkx

#
# A `Live Edit' dialog.  Note the action buttons, which
#   use a rather convoluted technique to produce their
#   effects (when a button is bushed,
#   quarkpy.qmacro.MACRO_fixview is executed with an index
#   saying which, this calls the appropriate function of the
#   dialog, which was attached to the editor when executed).
#
# A ListBox would be better than a ComboBox for data entry,
#   but FormCFG.pas doesn't at the moment support ListBoxes.
#   In principle, this could be fixed.
#

class ThinFaceDlg (quarkpy.dlgclasses.LiveEditDlg):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (220,160)
    dfsep = 0.35

    dlgdef = """
        {
        Style = "9"
        Caption = "Thin Face Finder"

        useless: = {
          Typ = "C"
          Txt = "Brushes:"
          Items = "%s"
          Values = "%s"
          Hint = "These are the brushes that have thin faces.  Pick one," $0D " then push buttons on row below for action."
        }

          
        sep: = { Typ="S"}

        buttons: = {
        Typ = "PM"
        Num = "2"
        Macro = "fixview"
        Caps = "IF"
        Txt = "Actions:"
        Hint1 = "Inspect the chosen one"
        Hint2 = "Fix the chosen one"
        }

        num: = {
          Typ = "EF1"
          Txt = "# found"
        }

        thin: = {
          Typ = "EF001"
          Txt = "too thin: "
          Hint = "Faces that aren't wider than this are too thin."
        }
        
        sep: = { Typ="S"}

        exit:py = { }
    }
    """

    def inspect(self):
        index = eval(self.chosen)
        #
        # FIXME: dumb hack, revise mapmadsel
        #
        m = qmenu.item("",None)
        m.object=self.pack.useless[index]
        mapmadsel.ZoomToMe(m)
        mapmadsel.SelectMe(m)
        thinones = hasThinFaces(m.object,eval(self.pack.thin),retvals=1)
        self.pack.thinfaces=thinones
        self.editor.layout.explorer.sellist=thinones

    def fix(self):
        index = eval(self.chosen)
        undo=quarkx.action()
        remains=0
        brush = self.pack.useless[index]
        for thin in self.pack.thinfaces:
            if thin.parent is brush:
               undo.exchange(thin,None)
            else:
               remains=1
        if remains:
            quarkx.msgbox("Some thin faces weren't removed because they are shared",
              MT_INFORMATION, MB_OI)
        self.editor.ok(undo,'delete thin faces')
        if remains==0:
            self.pack.useless.remove(brush)   
        self.src["useless"]=''
        #
        # This seems to need to be called to get the dialog
        #   to reset itself with the new data (not quite sure
        #   why it doesn't happen automatically here, but it
        #   dosnt seem to)
        #
        self.datachange(self.dlg)

    def zapall(self):
        undo=quarkx.action()
        for brush in self.pack.useless:
            undo.exchange(brush,None)
        self.editor.ok(undo,'delete microbrushes')
        self.src["useless"]=''
        self.datachange(self.dlg)

#
# Define the fixview macro here, put the definition into
#  quarkpy.qmacro, which is where macros called from delphi
#  live.
#
def macro_fixview(self, index=0):
    editor = mapeditor()
    if editor is None: return
    if index==1:
        editor.uselessfacedlg.inspect()
    elif index==2:
        editor.uselessfacedlg.fix()
    #
    # probably won't use this
    #
    elif index==3:
        editor.uselessfacedlg.zapall()
        
quarkpy.qmacro.MACRO_fixview = macro_fixview

def hasThinFaces(brush, factor=1.0, retvals=0):
    vals = []
    for face in brush.faces:
        vertices = face.verticesof(brush)
        point = vertices[0]
        norm = (vertices[1]-point).normalized
        for vertex in vertices[2:]:
            perp = perptonormthru(vertex,point,norm)
            if abs(perp)>=factor:
                break
        #
        # if the loop finishes without a break, then all of
        #  the perps are too small and the face is suspect
        #
        else:
            if retvals:
                vals.append(face)
            else:
               return 1
    if retvals:
        return vals
    else:
       return 0 
                

def getThin(thin, editor):
    useless = []
    for brush in editor.Root.findallsubitems("",":p"):
        if hasThinFaces(brush,thin):
            useless.append(brush)
    return useless
    
def thinClick(m):
    editor=mapeditor()
    useless=[]

    thin = quarkx.setupsubset(SS_MAP, "Options")["thinfacesize"]
    if thin==None:
        thin="1.0"

    useless=getThin(eval(thin),editor)    
    
    #
    # Here we start the Live Edit dialog invocation sequence.
    #  Data to be tracked during the life of the dialog goes
    #  here.
    #
    class pack:
        "stick stuff in this"
    pack.useless=useless
    pack.thin=thin
      
    #
    # This loads the relevant data into the dialog, gets
    #  recalled after changes.
    #
    def setup(self, pack=pack, editor=editor):
        self.pack=pack
        #
        # Part of the convolution for the buttons, to communicate
        #  which objects methods should be called when one pushed.
        # Cleaned up in onclosing below.
        #
        editor.uselessfacedlg=self
        
        #
        # Names and list-indexes of thin brushes
        #
        pack.slist = map(lambda obj:obj.shortname, pack.useless)
        pack.klist = map(lambda d:`d`, range(len(pack.useless)))

        #
        #  wtf doesn't this work, item loads but function is trashed
        #
#        self.src["useless"] = pack.klist[0]
        self.src["useless$Items"] = string.join(pack.slist, "\015")
        self.src["useless$Values"] = string.join(pack.klist, "\015")
        #
        # Note the commas, EF..1 controls take 1-tuples as data
        #
        self.src["num"]=len(pack.klist),
        self.src["thin"]=eval(pack.thin),

    #
    # When data is entered, this gets executed.
    #
    def action(self, pack=pack, editor=editor):
       src = self.src
       #
       # note what's been chosen
       #
       self.chosen = src["useless"]
       #
       # see if thinness threshold has been changed
       #
       newthin, = self.src["thin"]
       if newthin!=pack.thin:
           if newthin==1.0:
               quarkx.setupsubset(SS_MAP, "Options")["thinfacesize"]=None
           else:
               quarkx.setupsubset(SS_MAP, "Options")["thinfacesize"]="%f2"%newthin
           pack.useless=getThin(newthin, editor)
           pack.thin="%.2f"%newthin
           
    #
    # Cleanup when dialog closes (not needed if no mess has
    #  been created)
    #
    def onclosing(self,editor=editor):
        del editor.uselessfacedlg
        
    #
    # And here's the invocation. 2nd arg is a label for storing
    #  position info in setup.qrk.
    #
    ThinFaceDlg(quarkx.clickform, 'thinface', editor, setup, action, onclosing)


quarkpy.mapsearch.items.append(qmenu.item('Find &Thin Faces', thinClick,
  "|This identifies brushes with faces that are suspiciously thin."))

#$Log$
