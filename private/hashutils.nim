


proc getNeighbor(dir: Direction, dirtype: DirType): string =
  case dir
  of north:
    case dirtype
    of lon: result = "p0r21436x8zb9dcf5h7kjnmqesgutwvy"
    of lat: result = "bc01fg45238967deuvhjyznpkmstqrwx"
  of south:
    case dirtype
    of lon: result = "14365h7k9dcfesgujnmqp0r2twvyx8zb"
    of lat: result = "238967debc01fg45kmstqrwxuvhjyznp"
  of east:
    case dirtype
    of lon: result = "bc01fg45238967deuvhjyznpkmstqrwx"
    of lat: result = "p0r21436x8zb9dcf5h7kjnmqesgutwvy"
  of west:
    case dirtype
    of lon: result = "238967debc01fg45kmstqrwxuvhjyznp"
    of lat: result = "14365h7k9dcfesgujnmqp0r2twvyx8zb"



proc getBorder(dir: Direction, dirtype: DirType): string =
  case dir
  of east:
    case dirtype
    of lon: result = "bcfguvyz"
    of lat: result = "prxz"
  of west:
    case dirtype
    of lon: result = "0145hjnp"
    of lat: result = "028b"
  of north:
    case dirtype
    of lon: result = "prxz"
    of lat: result = "bcfguvyz"
  of south:
    case dirtype
    of lon: result = "028b"
    of lat: result = "0145hjnp"
