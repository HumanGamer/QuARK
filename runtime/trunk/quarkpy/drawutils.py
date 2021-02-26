"""   QuArK  -  Quake Army Knife

Various simple drawing routines
"""
#
# Copyright (C) 1996-99 Armin Rigo
# THIS FILE IS PROTECTED BY THE GNU GENERAL PUBLIC LICENCE
# FOUND IN FILE "COPYING.TXT"
#

import quarkx
from qeditor import BS_CLEAR

def drawsquare(cv, o, side):
  "function to draw a square around o"
  if o.visible:
    dl = side/2
    cv.brushstyle = BS_CLEAR
    cv.rectangle(int(o.x+dl), int(o.y+dl), int(o.x-dl), int(o.y-dl))

def drawredface(view, cv, face): #drawhighlightface
    for vtx in face.vertices: # is a list of lists
      sum = quarkx.vect(0, 0, 0)
      p2 = view.proj(vtx[-1])  # the last one
      for v in vtx:
        p1 = p2
        p2 = view.proj(v)
        sum = sum + p2
        cv.line(p1,p2)
      drawsquare(cv, sum/len(vtx), 8)
