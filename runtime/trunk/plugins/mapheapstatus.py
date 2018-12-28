"""   QuArK  -  Quake Army Knife

Heap debugging functions.
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

import quarkx
import quarkpy.mapmenus
import quarkpy.mapcommands
import quarkpy.dlgclasses
import quarkpy.qtoolbar
from quarkpy.maputils import *


#Field   Meaning
#
#TotalAddrSpace    The (current) total address space available to your program,
#                   in bytes. This will grow as your program's dynamic memory
#                   usage grows.
#TotalUncommitted  The total number of bytes (of TotalAddrSpace) for which
#                   space has not been allocated in the swap file. 
#TotalCommitted    The total number of bytes (of TotalAddrSpace) for which
#                   space has been allocated in the swap file.
#                   Note:TotalUncommitted + TotalCommitted = TotalAddrSpace
#TotalAllocated    The total number of bytes dynamically allocated by your program.
#
#TotalFree         The total number of free bytes available in the (current)
#                   address space for allocation by your program. If this number
#                   is exceeded, and enough virtual memory is available, more
#                   address space will be allocated from the OS; TotalAddrSpace
#                   will be incremented accordingly.
#FreeSmall         Total bytes of small memory blocks which are not currently
#                   allocated by your program. 
#FreeBig           Total bytes of big memory blocks which are not currently
#                   allocated by your program. Large free blocks can be
#                   created by coalescing smaller, contiguous, free blocks
#                   or by freeing a large dynamic allocation.  (The exact
#                   size of the blocks is immaterial)
#Unused            Total bytes which have never been allocated by your program.
#                   Note: Unused + FreeBig + FreeSmall = TotalFree
#                   These three fields (Unused, FreeBig, and FreeSmall) refer
#                   to dynamic allocation by the user program.
#Overhead          The total number of bytes required by the heap manager to
#                   manage all the blocks dynamically allocated by your program. 
#HeapErrorCode     Indicates the current status of the heap, as internally
#                   determined.

#Note:   TotalAddrSpace, TotalUncommitted and TotalCommitted refer to OS memory used by the program, where as TotalAllocated and TotalFree refer to the heap memory used within the program by dynamic allocations. Therefore, to monitor dynamic memory used in your program use TotalAllocated and TotalFree.

class HeapStatus(quarkpy.dlgclasses.placepersistent_dialogbox):
    #
    # dialog layout
    #

    endcolor = AQUA
    size = (250,120)
    dfsep = 0.50
    flags = FWF_KEEPFOCUS
    
    dlgdef = """
        {
        Style = "9"
        Caption = "Heap Status Dialog"

        TotalAllocated: =
        {
        Txt = "&"
        Typ = "ESR"
        Hint = "Total Bytes Allocated by the Program"
        }

        ChangeAllocated: =
        {
        Txt = "&"
        Typ = "ESR"
        Hint = "Change in Total Bytes Allocated by the Program"
        }

        

        sep: = { Typ="S" Txt=" " }

        cancel:py = {Txt="" }
    }
    """

    #
    # __init__ initialize the object
    #

    def __init__(self, form, editor, src):

    #
    # General initialization of some local values
    #

        self.editor = editor
        #
        # heapstatus object passed as parameter used directly to load
        #   dialog
        #
        self.src = src
        totalalloc=eval(src["TotalAllocated"])
        try:
            oldalloc = editor.oldalloc
            src["ChangeAllocated"]=`totalalloc-oldalloc`
        except:
            pass
        editor.oldalloc = totalalloc
        self.form = form
          
    #
    # Create the dialog form and the buttons
    #

        quarkpy.dlgclasses.placepersistent_dialogbox.__init__(self, form, src, "heapstatus",
        cancel = quarkpy.qtoolbar.button(
            self.cancel,
            "Close",
            ico_editor, 0,
            "Cancel"))

    def cancel(self, dlg):
        self.src = None 
        qmacro.dialogbox.close(self, dlg)


def HeapStatusClick(m):
    status = quarkx.heapstatus()
    HeapStatus(quarkx.clickform,mapeditor(),status)

quarkpy.mapoptions.items.append(quarkpy.mapoptions.toggleitem("Developer Mode","Developer", hint = "|Developer Mode:\n\nIn this mode, two extra items appear on the 'Commands' menu, to help with debugging, etc.|intro.mapeditor.menu.html#reload"))

hint = "|Reload:\n\nThis is a 'Developer Mode' function to help with debugging, etc.|intro.mapeditor.menu.html#heapstatus"

menheapstatus = qmenu.item("HeapStatus",HeapStatusClick,hint)

if quarkx.setupsubset(SS_MAP, "Options")["Developer"]:
  quarkpy.mapcommands.items.append(menheapstatus)
