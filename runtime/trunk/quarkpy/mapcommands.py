"""   QuArK  -  Quake Army Knife

The map editor's "Commands" menu (to be extended by plug-ins)
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

import quarkx
import qmenu
from qutils import MapHotKeyList

def newitem1click(m):
    quarkx.opentoolbox("New map items...")

NewItem1 = qmenu.item("&Insert map item...", newitem1click, "|Opens the 'New Map items' window:\n\nThis window contains all objects that are available to use in the map-views and dataform-display.|intro.mapeditor.misctools.html#newmapitem")

def onclick(menu):
    pass

items = []
shortcuts = {}

def CommandsMenu():
    "The Commands menu, with its shortcuts."

    #
    # Global variables to update from plug-ins.
    #
    global items
    global shortcuts

    items2 = [NewItem1, ] + items

    MapHotKeyList("Insert", NewItem1, shortcuts)
    return qmenu.popup("&Commands", items2, onclick), shortcuts
