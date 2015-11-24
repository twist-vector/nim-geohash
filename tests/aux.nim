#
#                     Nimrod Geohash Library
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
  unittest,
  math,
  geohash


suite "auxiliary function checks":

  test "adjacent checks":
    # Verify the adjacent calculation (via getNeighbors)
    let
      coor1:     Coord = (latitude: 57.64911, longitude: 10.40744)
      loc:      string = encode(coor1, 6)
      neigh: Neighbors = getNeighbors(loc)

    check:
      neigh.nw == "u4prux"
      neigh.n  == "u4pruz"
      neigh.ne == "u4prvp"
      neigh.w  == "u4pruw"
      neigh.c  == loc
      neigh.e  == "u4prvn"
      neigh.sw == "u4prut"
      neigh.s  == "u4pruv"
      neigh.se == "u4prvj"



  test "bounds checks":
    # Verify the bounds calculation.  The southern bounds of the north adjacent
    # should equal the north bounds of the original.  Longitude boundaries should
    # be unchanged.  Try some random locations...
    randomize()
    for i in 0..100:
      let
        randLat:    float = 90.0 - random(180.0)
        randLon:    float = 180.0 - random(360.0)
        randLoc:   string = encode( (latitude: randLat, longitude: randLon) )
        bounds:    Bounds =  getBounds(randLoc)
        cellNorth: Bounds = getBounds( getAdjacent(randLoc,north) )

      check:
        bounds.maxLatitude == cellNorth.minLatitude
        bounds.minLongitude == cellNorth.minLongitude
        bounds.maxLongitude == cellNorth.maxLongitude
