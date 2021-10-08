# FB SVG Clipper

**FB (FreeBasic) SVG Clipper** is a tool that helps to **clip images** using the **Bézier tool** and exports it in a **SVG file**  with a linked and clipped image.

It's written in **FreeBasic language**, it's released under the terms of the *GNU LESSER GENERAL PUBLIC LICENSE Version 3*. It works on Windows an Linux environnements.

![Image of the Laoconte clipped](_examples/example_laoconte.png)

## User guide

To launch the program input as arguments the name of the fvg file to open (_if it doesn't exist it will be created when saving_) and a valid JPG file. The program should be launched by the command-line.

Example (_windows_):

`fbvg filename.fvg filename.jpg`

At the moment it's important that both `fvg file` and `image file` are in the same folder of the program.

### Compiling instructions

`fbc -exx -g -w all "%f"`

In the console the list of the working commands will appear during the running of the program.


### Keyboard shortcuts

#### Tools:

`P` - **Pen tool**

**Click and drag** the mouse to **create a node**. Press `alt` key while dragging to create a not sloped node. Click on the beginning of the path to close the path itself.

`CANC (DELETE)` **Delete** the last node created

`CTRL + CANC (DELETE)` Delete the whole working path

----

`H` - **Hand tool** Click and drag the mouse to pan the workarea

----

`Mouse wheel` will affect the zoom ratio

----

`V` - **Select tool**

Click and drag to **select** path / paths

`CANC (DELETE)` **delete** selected paths

----

`CTRL + S` **Save** the .fvg file

`CTRL + E` **Export** the SVG file

`CTRL + Q` **Quit** the program

----

## Aknowledgments

This source includes parts of code written by other
(in some cases I've slightly modified the code in order to suit the needs of the program).

**paul doe:**

- keyboard and mouse class https://www.freebasic.net/forum/viewtopic.php?t=28958

**d.j. peters:**

- jpg loader
https://freebasic.net/forum/viewtopic.php?f=7&t=15284&hilit=othings.org%2Fstb_image.c
- imagescale
https://www.freebasic.net/forum/viewtopic.php?f=7&t=10533&hilit=ImageScale
- Base64 de/encoder
https://freebasic.net/forum/viewtopic.php?t=24127

**MrSwiss:**

- Loading a CSV file into an array
https://www.freebasic.net/forum/viewtopic.php?t=25693

**bcohio2001:**
- Base64 de/encoder
https://freebasic.net/forum/viewtopic.php?t=24127

_I wish also thank_

**A Primer on Bézier Curves**
- https://pomax.github.io/bezierinfo/

----

### TO DO List in order of importance

- select nodes
- Export SVG compound path
- Export SVG with embedded clipped bitmap
- better image handling
- Move points
- Move paths
- SPACEBAR -> Hand Tool
- Undo Levels
- Join paths
- Cut paths
- Scale paths
- Rotate paths
- Copy paths
- Export as transparent PNG

### Version history

**0.0.9**

- delete selected paths

**0.0.8**

- delete last node
- delete working path

**0.0.7**

- more options from the command-line

**0.0.6**

- thick line
- improved panning 

**0.0.5**

- save and load file
- export svg
- better pen tool pointer icon

**0.0.4**

- auto close paths

**0.0.3**

- improved paths

**0.0.2**

- adding paths

**0.0.1**

- pan and zoom
- jpg load

## Important note
This software is developed in the hope it will be useful. *It's still a beta version and the developer is not responsible of any data loss it could cause*. By compiling and running it on your local machine you agree this statement.