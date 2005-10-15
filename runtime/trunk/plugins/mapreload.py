
#$Header$

import quarkx
import quarkpy.mapmenus
import quarkpy.mapcommands
import quarkpy.qmacro
import quarkpy.mapoptions

from quarkpy.maputils import *


prevreload = ""

class remodule:
  "a place to stick stuff"

class ReloadDlg (quarkpy.qmacro .dialogbox):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (200,120)
    dfsep = 0.35
    flags = FWF_KEEPFOCUS
    
    dlgdef = """
        {
        Style = "9"
        Caption = "Reload Dialog"

        module: =
        {
        Txt = "reload:"
        Typ = "EP"
        DefExt = "py"
        BasePath = "%splugins"
        DirSep = "."
        CutPath = "C:\?\\"
        Hint = "Type in the name of the module (.py file),"$0D
               "preceded with its folder name,"$0D
               "(ex. plugins.mapreload) the .py is optional,"$0D
               "or just use the file browser ... to the right."$0D
        }

        sep: = { Typ="S" Txt=" " }

        close:py = {Txt="" }
        cancel:py = {Txt="" }

    }
    """%quarkx.exepath  # suggestion by tiglari(the quotes stay)

    #
    # __init__ initialize the object
    #

    def __init__(self, form, editor, action):

    #
    # General initialization of some local values
    #

        self.editor = editor
        src = quarkx.newobj(":")
        self.src = src
        self.action = action
        self.form = form
        self.src["module"] = quarkx.setupsubset(SS_MAP, "Options")["ReloadModule"]


    #
    # Create the dialog form and the buttons
    #

        quarkpy.qmacro.dialogbox.__init__(self, form, src,
        close = quarkpy.qtoolbar.button(
            self.close,
            "Reload the named module",
            ico_editor, 2,
            "Reload"),
        cancel = quarkpy.qtoolbar.button(
            self.cancel,
            "Cancel & close window",
            ico_editor, 0,
            "Cancel"))

#    def datachange(self, df):
#        self.close()   # "OK" is automatic when the user changed the data.

    def onclose(self, dlg):
        if self.src is None:
#            quarkx.msgbox("Empty string does not name a module, nothing done", MT_ERROR, MB_OK)
            qmacro.dialogbox.onclose(self, dlg)
            return
        quarkx.globalaccept()
        self.action(self)
        qmacro.dialogbox.onclose(self, dlg)

    def cancel(self, dlg):
        self.src = None 
        qmacro.dialogbox.close(self, dlg)




def ReloadClick(m):
  def action(self):
    if self.src["module"] is None:
      quarkx.msgbox("Empty string does not name a module, nothing done", MT_ERROR, MB_OK)
      return
    module = self.src["module"]
    quarkx.setupsubset(SS_MAP, "Options")["ReloadModule"] = module

    command = "reload(%s)"%module.replace(".py", "")
    eval(command)
    
  editor=mapeditor()
  if editor is None: return
  ReloadDlg(quarkx.clickform,editor,action)

quarkpy.mapoptions.items.append(quarkpy.mapoptions.toggleitem("Developer Mode","Developer", hint = "|Developer Mode:\n\nIn this mode, some extra items appear on the menu, to help with debugging, etc.|intro.mapeditor.menu.html#optionsmenu"))

menreload = qmenu.item("Reload",ReloadClick,"Reload module")

if quarkx.setupsubset(SS_MAP, "Options")["Developer"]:
  quarkpy.mapcommands.items.append(menreload)


# ----------- REVISION HISTORY ------------
#
#
# $Log$
# Revision 1.9  2003/12/18 21:51:46  peter-b
# Removed reliance on external string library from Python scripts (second try ;-)
#
# Revision 1.8  2003/05/18 04:02:50  cdunde
# To change code to avoid path hard coding
#
# Revision 1.7  2003/05/13 20:33:29  cdunde
# To add file browser and correct closing errors
#
# Revision 1.6  2003/05/11 16:03:20  cdunde
# To correct cancel console error
#
# Revision 1.5  2003/03/28 02:54:40  cdunde
# To update info and add infobase links.
#
# Revision 1.4  2001/06/17 21:10:57  tiglari
# fix button captions
#
# Revision 1.3  2001/03/20 08:02:16  tiglari
# customizable hot key support
#
# Revision 1.2.4.1  2001/03/11 22:10:42  tiglari
# customizable hotkeys
#
# Revision 1.2  2000/06/03 10:25:30  alexander
# added cvs headers
#
#
#
#