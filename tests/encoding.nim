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
  geohash


suite "encoding checks":

  test "precision checks":
    # Geohash for the Råbjerg Mile
    let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
    check(encode(coor1, 3) == "u4p")
    check(encode(coor1, 6) == "u4pruy")
    check(encode(coor1, 9) == "u4pruydqq")
    check(encode(coor1, 12) == "u4pruydqqvj8")

  test "invalid geohash checks":
    let coor1: Coord = (latitude: 57.64911, longitude: 10.40744)
    expect(ValueError):
      discard encode(coor1, 0)
