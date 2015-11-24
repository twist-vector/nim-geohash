#
#                     Nim Geohash Library
#
# The geohash module is a latitude/longitude geocode system invented by
# Gustavo Niemeyer.  It is a hierarchical spatial data structure which
# subdivides cells into 32 (sub)cells and represents the location by a short
# alphanumeric string.  That is, each of the 32 cells is assigned a
# character code and the cell can be further subdivided into 32 cells which is
# represented by an additional character.
#
# See
#   https://en.wikipedia.org/wiki/Geohash
#   http://geohash.org
#   http://www.movable-type.co.uk/scripts/geohash.html
#
# (c) Copyright 2015 Tom Krauss
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import
  math,
  strutils

type
  Bounds* = tuple[minLatitude: float, minLongitude: float,
                  maxLatitude, maxLongitude: float]

  Coord*  = tuple[latitude: float, longitude: float]

  Direction* = enum north, east, south, west
  Neighbors* = tuple[nw: string, n: string, ne:string,
                      w: string, c: string,  e:string,
                     sw: string, s: string, se:string ]
  DirType = enum lat, lon

const
  base32 = "0123456789bcdefghjkmnpqrstuvwxyz"



include private/hashutils


proc encode*(coord: Coord, precision: int = 12): string =
  ## Encodes a location (latitude and longitude as a Coord) into a geohash
  ## string. 'precision' indicates the number of characters to return.  More
  ## characters means more accuracy.  Default precision is 12 characters.
  if precision < 1:
    var e: ref ValueError
    new(e)
    e.msg = "Invalid geohash encode request - precision must be greater than 0"
    raise e

  var
    idx = 0         # The index into base32 map of allowable geohash characters
    bit = 0         # The bit number we're processing - 5 bits per character
    evenBit = true  # Switch between lat and lon (even and odd bits) - start even
    geohash = ""    # The aggregated geohash string
    latMin = -90.0  # Starting bounding box "lower left" latitude
    latMax =  90.0  # Starting bounding box "upper right" latitude
    lonMin = -180.0 # Starting bounding box "lower left" longitude
    lonMax = 180.0  # Starting bounding box "upper right" longitude

  # Keep adding bits (characters) until we have the requested precision
  while len(geohash) < precision:
    if evenBit:
        # Bisect E-W longitude
        let lonMid = (lonMin + lonMax) / 2.0
        if coord.longitude>lonMid:
          idx = idx*2 + 1
          lonMin = lonMid
        else:
          idx = idx*2
          lonMax = lonMid
    else:
        # Bisect N-S latitude
        let latMid = (latMin + latMax) / 2.0
        if coord.latitude>latMid:
            idx = idx*2 + 1
            latMin = latMid
        else:
            idx = idx*2
            latMax = latMid
    evenBit = not evenBit

    # 5 bits gives us a character.  If we have 5 bits accumulated append the
    # character and start the bit count over
    bit += 1
    if bit == 5:
        geohash &= $base32[idx]
        bit = 0
        idx = 0

  return geohash


proc getBounds*(geohash: string): Bounds =
  ## Computes and returns the bounding box of the specified geohash string.
  ## Bounds are returned as a 'Bounds' tuple.
  var
    evenBit = true
    latMin =  -90.0
    latMax =  90.0
    lonMin = -180.0
    lonMax = 180.0

  for i in low(geohash)..high(geohash):
    let chr = geohash[i].toLower()
    let idx = base32.find(chr)
    if idx == -1:
      var e: ref ValueError
      new(e)
      e.msg = "Bad value in supplied hash"
      raise e

    # Process the 5 bits associated with each character
    for n in countdown(4, 0):
      let bitN = (idx shr n) and 1
      if evenBit:
          # longitude
          let lonMid = (lonMin+lonMax) / 2.0
          if bitN == 1:
            lonMin = lonMid
          else:
            lonMax = lonMid
      else:
          # latitude
          let latMid = (latMin+latMax) / 2.0
          if bitN == 1:
            latMin = latMid
          else:
            latMax = latMid
      evenBit = not evenBit

  return (minLatitude: latMin, minLongitude: lonMin,
          maxLatitude: latMax, maxLongitude: lonMax)




proc decode*(geohash: string): Coord =
  ## Decodes the supplied geohash string into a location. Location is returned
  ## as a Coord tuple (latitude and longitude as a Coord).
  let
    bounds = getBounds(geohash)
    lat = (bounds.minLatitude + bounds.maxLatitude)/2.0
    lon = (bounds.minLongitude + bounds.maxLongitude)/2.0

  return (latitude: lat, longitude: lon)



proc getAdjacent*(geohash: string , dir: Direction): string =
  ## Returns the adjacent geohash cell in the specified direction.  Note only
  ## north, south, east, and west directions are directly supported.  To getBorder
  ## the diagonal directions (e.g., northwest) two calls to 'adjacent' would
  ## be required.
  if len(geohash) == 0:
    var e: ref OSError
    new(e)
    e.msg = "Invalid adjacent request - geohash string invalid"
    raise e

  var gridType: DirType
  case len(geohash) mod 2
  of 0:
    gridType = lon
  else:
    gridType = lat

  let
    geoLen = len(geohash)
    lastCh = geohash[geoLen-1].toLower()    # Last character of hash
    borderString = getBorder(dir, gridType)
    idx = borderString.find(lastCh)

  # Recursively call getAdjacent
  var parent = geohash[0..geoLen-2].toLower() # Hash without last character
  if (idx != -1) and (parent != ""):
    parent = getAdjacent(parent, dir)

  let neigh = getNeighbor(dir, gridType)
  let idxNeigh = neigh.find(lastCh)
  return parent & base32[idxNeigh]



proc getNeighbors*(loc: string): Neighbors =
  ## Returns the neighbor geohash strings for the specified location.  This is
  ## a convenience function that calls the `getAdjacent` routine multiple
  ## times to return all adjacent cells (neighbors).
  let
    n = getAdjacent(loc, north)
    s = getAdjacent(loc, south)

  return (nw: getAdjacent(n, west),
           n: n,
          ne: getAdjacent(n, east),
           w: getAdjacent(loc, west),
           c: loc,
           e: getAdjacent(loc, east),
          sw: getAdjacent(s, west),
           s: s,
          se: getAdjacent(s, east))


proc `$`*(neigh: Neighbors): string =
  ## "pretty print" for the Neighbors tuple.  This procedure returns a string
  ## that shows the specified "Neighbors" tuple as a 3x3 grid.  It supports
  ## direct printing of the Neighbors tuple via echo.
  result = ""
  result &= neigh.nw & "  " & neigh.n & "  " & neigh.ne & "\n"
  result &= neigh.w  & "  " & neigh.c & "  " & neigh.e & "\n"
  result &= neigh.sw & "  " & neigh.s & "  " & neigh.se
