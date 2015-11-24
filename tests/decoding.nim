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


suite "decoding checks":
  test "precision checks":
    let
      coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
      decVal = decode( encode(coor1, 12) )

    check:
      abs(coor1.latitude - decVal.latitude) < 1.0e-6
      abs(coor1.longitude - decVal.longitude) < 1.0e-6


  test "invalid geohash checks":
    let badhash = "u4prauy"  # 'a' not allowed
    expect(ValueError):
      discard decode(badHash)


  test "invertibility checks":
    randomize()
    for i in 0..100:
      let
        randLat:    float = 90.0 - random(180.0)
        randLon:    float = 180.0 - random(360.0)
        randLoc:   string = encode( (latitude: randLat, longitude: randLon) )

        decLoc:     Coord = decode(randLoc)

      check:
        abs(decLoc.latitude - randLat) < 1.0e-6
        abs(decLoc.longitude - randLon) < 1.0e-6
