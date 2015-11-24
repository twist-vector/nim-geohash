# Nim Geohash Library

The geohash module is a latitude/longitude geocode system invented by
Gustavo Niemeyer.  It is a hierarchical spatial data structure which
subdivides cells into 32 (sub)cells and represents the location by a short
alphanumeric string.  That is, each of the 32 cells is assigned a
character code and the cell can be further subdivided into 32 cells which is
represented by an additional character.

## See
   - [https://en.wikipedia.org/wiki/Geohash](https://en.wikipedia.org/wiki/Geohash)
   - [http://geohash.org](http://geohash.org)
   - [http://www.movable-type.co.uk/scripts/geohash.html](http://www.movable-type.co.uk/scripts/geohash.html)

## Examples

### Encode and Decode
There are mltiple types defined in the Geohash library.  These types are
intended to ease the use of the various functions and/or to make the code more
readable.  To specify a location on the ground in decimal latitude and longitude,
use the `Coord` type.  The resulting variable can be passed to the `encode`
function to generate the geohash for that location.  The precision (i.e., the
number of characters) can be supplied to `encode` or the default value of 12 can
be used.
```nim
import geohash
let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
echo "coor1:  ", coor1
echo "Len 5:  ", encode(coor1, 5)
echo "Len 12: ", encode(coor1)
```
Here we've encoded the location of the Råbjerg Mile.  The resulting output would
show the length 5 and length 12 geohash encodings.
```
coor1:  (latitude: 57.64911, longitude: 10.40744)
Len 5:  u4pru
Len 12: u4pruydqqvj8
```

The output of the `encode` function is a string.  The inverse function, `decode`
takes the geohash string and decodes it back to a decimal `Coord` location.
```nim
import geohash
let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
echo "coor1:  ", coor1
echo "Len 5:  ", encode(coor1, 5)
echo "Len 12: ", encode(coor1)
echo ""

let coor2: Coord = decode( encode(coor1, 5) )
echo "coor2:  ", coor2
```
which results in the following output:
```
coor1:  (latitude: 57.64911, longitude: 10.40744)
Len 5:  u4pru
Len 12: u4pruydqqvj8

coor2:  (latitude: 57.63427734375, longitude: 10.39306640625)
```
Note that the output of decode is *not* identical to the input `coor1` since
only 5 digits of precision were used.  We can see the effects of the precision
below:
```nim
import geohash
let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
echo "orig:     ", coor1
echo "3 digit:  ", decode( encode(coor1, 3) )
echo "6 digit:  ", decode( encode(coor1, 6) )
echo "9 digit:  ", decode( encode(coor1, 9) )
echo "12 digit: ", decode( encode(coor1, 12) )
```
As can be seen, the resulting accuracy of the encode/decode process improves as
more precision, e.g., more characters, are used.
```
orig:     (latitude: 57.64911, longitude: 10.40744)
3 digit:  (latitude: 56.953125, longitude: 10.546875)
6 digit:  (latitude: 57.64801025390625, longitude: 10.4095458984375)
9 digit:  (latitude: 57.64910459518433, longitude: 10.40742158889771)
12 digit: (latitude: 57.64911004342139, longitude: 10.40743986144662)
```

### Supporting functions
Each encoded Geohash represents a "cell" or a region on the ground.  The size of
the region depends on the precision requested.  The function `getBounds` returns
a `Bounds` tuple that describes the latitude and longitude bondaries of the cell
associated with the supplied Geohash string.
```nim
import geohash
let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
let hash = encode(coor1, 5)
echo "orig:     ", coor1
echo "5 digit:  ", hash
echo "bounds:   ", getBounds(hash)
```
The above code shows the bounds of the 5 digit geohash `u4pru`:
```
orig:     (latitude: 57.64911, longitude: 10.40744)
5 digit:  u4pru
bounds:   (minLatitude: 57.6123046875, minLongitude: 10.37109375, maxLatitude: 57.65625, maxLongitude: 10.4150390625)
```

Since the Geohash algorithm divides the world into a hierarchy of "cells", at
any given level (precision) each cell has eight neighbors.  Severa functions are
provided to determine the neighbors of a given HGeohash.
```nim
import geohash
let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
let hash = encode(coor1, 5)
echo "orig:     ", coor1
echo "5 digit:  ", hash
echo "bounds:   ", getBounds(hash)
echo "north:    ", getAdjacent(hash, north)
echo "Neighbors:"
echo getNeighbors(hash)
```
Notice that the return type of the `getNeighbors` convenience function is a
`Neighbors` tuple.  This tuple has nine elements representing the adjacent
cells in the eight directions (plus the specified, center cell).  An
overloaded stringify operator (`$`) is provided for nice display of the
Neighbors structure using `echo`.
```
orig:     (latitude: 57.64911, longitude: 10.40744)
5 digit:  u4pru
bounds:   (minLatitude: 57.6123046875, minLongitude: 10.37109375, maxLatitude: 57.65625, maxLongitude: 10.4150390625)
north:    u4r2h
Neighbors:
u4r25  u4r2h  u4r2j
u4prg  u4pru  u4prv
u4pre  u4prs  u4prt
```
