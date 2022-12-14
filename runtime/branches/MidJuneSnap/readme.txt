
             QuArK Snapshot 06??01 

Changes from 052101

 4 Users:
  *texture search button in texture browser
  *storeable 3d camera positions
    - add them on the 3d view eye handles & background
        RMB menus
    - they appear in the map and treeview like
        duplicators, can be dragged, deleted, etc
        like ordinary map objects
    - set and store view menu items on their RMB
    - if multiple views are open, these commands use
       the last 3d view clicked on (usually, doesn't
       quite always seem to work, dunno why)
    - cycle the ones in a group with prev/next +
        'C' depressed (should be made user-configurable)
    - find camera positions dialog on search menu
  *extruder 'revert to duplicator' now imports
    texture changes back to duplicator, so you can
    texture at least the first segment of the extruder
    by dissociating images, then change shape by revert
    to duplicator.  Hopefully useful when 1-segment
    extruder is put into path duplicator.
  *group selection movement commands (swap & align,
   suggested by Alan Donald and quantum_red)
  *due north path duplicator bug fixed
  *menu promotion/demotion added to the basic distribution
  *incrementable specifics added to basic, linear, symx/y/z
    and Copy/New Copy One duplicators.
     - If 'increment' specific is checked, then target,
         targetname and killtarget specifics ending in
         a string of digits have the digid string incremented
         in the sequence.
     - if 'incr. all targ. specific is checked, all specifics
         whose name contains 'target' get incremented.
     - any specifics listed in 'incrementable; are also
         incremented.
     - if 'final_target' has a value, this is used as the
         'target' value in the last image.  Likewise
         for 'final_killtarget' etc.
     - if 'increment by' has a value, then this is used
         as the increment, rather than 1.  This can be
         used to use increments with nested duplicators,
         if the outer one increments by 10 and the inner
         by 1, you can have an Nx9 grid,etc.
     - if 'incre_lip' has a value, then that value is
         used to increment the 'lip' speciric, likewise
         incre_<spec> for any other choice of <spec>.
     - for (New) Copy One, each duplictor needs a different
         'increment by' value (otherwise crosstalk).

     Limitation: Doesn't work for symxy and
       Radial duplicators (yet; if you want it to,
       holler).
  *corrections to the 'vertex movement' plugin (this is
    still basically experimental)
  *new 3 point plane stuff:
    a) introduce one from New Map Items|tools, drag
         the handles around and tag it, the glue, cut
         etc.
    b) use tag plane command after tagging an edge
                
 Under the hood:
   *entity conversion (fgd->qrk) tools pythonified
   *'Code Code' specific for toolbarbuttons (tbbtn) and 
     the python buttons (Typ="P" only).
   
    Example for tbbtn:
   
     search1:tbbtn = {
       Typ = "P"
       Cap = "Search"
       Code = "import plugins.tex_search; plugins.tex_search.openbox()"
     }
   
     GetEntitiesBtn: =
     {
       Typ = "P"
       Cap = "Get entities for this game"
       Code = "import quarkx; quarkx.beep()"
     }
   
   will execute the python string in the Code specifics.
   

               63 Snapshot 052101

 Changes from 050701:

  *Bsp opening bug in 050701 fixed
  *Map writing altered for brush primitives, Valve mapversion
    220, and 'No TX comments' mode so that if integral or
    almost integral vertexes for a face are found, they are
    used as its threepoints.  This enables better export
    of maps to editors and tools that don't support fp
    coordinates.
  *'thin face' finder added (similar to microbrush h/k);
     detect & remove suspiciously thin faces.
  *when an 'out' duplicator is dissociated, all
    other 'out' dups in its immediate group are
    dissociated also
  *caulk of hidden faces added to brush curves & extruder
    (default tex used for games w/o a caulk texture)
  *wrong shape for non-inner non-inverse cap/bevels
    fixed (missing faces added)
  *'linear' (matrix) specific editor.
    try out with New Copy One duplicator, push button
    to call up editing dialog.
  *matrix2 support changed to linear in radial dup.
  *rotate/scale specifics removed from linearform
  *linear duplicators changed to so that by default,
    mappings apply around 'usercenter' of each item
    in their group, rather than duplicator location

     -- group
          |
          ---- linear duplicator
          |
          ----- group: if this group has a usercenter,
          |        and the dup has a linear specific,
          |        the mapping will apply with the
          |        usercenter as fixed point
          |        
          ------group: ditto for this one (each around
                  its own center, seems wierd but
                  features of the code make it tricky
                  to do otherwise).
           
    old behavior can be restored by unchecking 'item center'.
  *support for the commercial counterstrike/hl
     expansion.
  *Hollowmaker/Wallmaker bug fixed
  *debug writing 'left' to console bug fixed

 
 Changes from  Snapshot 042801
 
  *Dragging on RMB blocked.  If anyone wants it back, an option
    could be provided.
  *instance duplicator removed from toolbox, pushing
    'instance' drops it into path dup, where it
    dumps things at the path points.  linear stuff
    removed from path point forms, prolly not useful
    New Copy One does that stuff better.
  *extruder functionality extended.  RMB menu has
    items for punching holes in things (e.g. putting
    a pipe thru a wall w/o overlap).  After 'dissociate
    images', RMB on the resulting group has an 'Extruder
    Stuff' submenu with the hole-punching, some texturing
    stuff that doesn't work right, and a 'revert' that
    restores the duplicator.
  *New Copy One duplicator, implementing ideas of Rolf
     Hulsbergen (better than Instance Dup, for many
     purposes): drop NCO into group like ordinary
     duplicator , drag image away with handle, use scale\
     & rotation fields to rotate around dup location.
  *rotation specific for linear & other dups changed
     to Typ E, so that rotation handles will work.
  *wrap texture from tagged works for parallel faces
  *wrap texture hotkey works.
  *forms creation added to forms editor
  *stvef maps now readable (no more reversion to Q3A mode,
    if in STVEF mode)


 Changes from Snapshot 042001:

  *RMB Menus for the Texture L handles: (tiglari)
    glue/align to tagged.

  *Reimplementation of addon builder: (Andy) still crashes on
    missionpack, this can be avoided by extracting the .bsp's &
    temporarily giving the .pk3 a different extension.
               
  *Selection menu: (tiglari, major Decker design input)
    change selection to Parent, Next, Previous in group.
      (no 'type' selections yet)

  *Reorganize/Navigate tree added to bezier RMB

  *having 'F' depressed with LMB will now select a face of current
     poly, rather than next poly.


 Changes from 6.2:
 
  *Customizable hot keys: (tiglari)
    Perhaps more hot  keys should be added.  Which ones?
    
  *Custom Centers for groups: (tiglari)
    various linear matrix operations (rotations etc)
    will use these if present
    
  *'scale' and 'rotation' specifics: (tiglari)
    for Linear & some other duplicators.  Does the
    work of 'linear' but more perspicuously.
    
  *Extuder: (tiglari)
    Makes solid & hollow pipes from 2d outline.  Put
    into path duplicator to extrude along path.
      
  *Instance Duplicator: (tiglari)
    For lots of copies in various places, idependent
    scale & rotation.
    
  *Entity Extractor: (Andy)
    I see some problem, not sure if I'm using it right.
    
  *Merge Polys in Group: (tiglari)
    Mergeable polys in a group are merged.  Not guaranteed
    optimal.
    
    
    
   