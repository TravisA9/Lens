

# the problem with this curve is that the values beyond Curve[1000] are inverted!
# Curve = [( 1/(X+1) ) for X in 1000:-1:-1000]
# Let's try a bell curve... No way! this curve is way too steep.
# Curve = [( X*X ) for X in 1000:-1:-1000]

# Ok, now this looks closer to what we need.
#Curve = [ 1/((X*X)/10) for X in 1000:-1:-1000]
Curve = [ (1/(X+1)) for X in 999:-1:-1001]

 Curve[1001] = Curve[1000]*2 # because it was "Inf"

# ==============================================================================
# this gets the 1/distance from center
# ==============================================================================
function dist(i,center)
    if i>=center
        return 1/(i-center)
    elseif i==center
        return 0
    else
        return 1/(center-i)
    end
end
# ==============================================================================
function normal(xa,ya, xb,yb)
     dx = xb-xa
     dy = yb-ya
     return [ -dy,  dx,
               dy,  -dx ]
end
# ==============================================================================
function rayPoint( vec, distance)
    return ((vec[3]-vec[1])/(vec[4]-vec[2])) * distance
end
# ==============================================================================
function rayPoint( xa, ya, xb, yb, distance)
   return ((xb-xa)/(yb-ya)) * distance
end
# ==============================================================================
# X is the +/- index in the array, z is to change magnification (experimental)
function diffract(x,z)
     x = round(Int64, x) + 1000 # this is to convert to +/- values (1000 = 0) ..translate the matrix if you will!
     xa, xb = x, Curve[x+1]
     ya, yb = Curve[x]*z, Curve[x+1]*z
     n = collect(normal(xa,ya, xb,yb))
end
# ==============================================================================












 type Point
     x::Float64
     y::Float64
     z::Float64
     Point(x,y,z) = new(x,y,z)
 end
 type Vector3D
     x::Float64
     y::Float64
     z::Float64
     Vector3D(x,y,z) = new(x,y,z)
 end

function AddVector(a, b)
    c = Vector3D()
    c.x = a.x + b.x
    c.y = a.y + b.y
    c.z = a.z + b.z
    return c
end

# ==============================================================================
# restrict plotting to bounds of window/image
# ==============================================================================
#=
 function restrict(lower, i, upper)
     if i > upper
         return upper
     end
     if i < lower
         return lower
     end
     return i
end
=#
# ==============================================================================
# Only plot if within bounds
# ==============================================================================
function plotIfVisible(lowerX, X, upperX, lowerY, Y, upperY)
      if lowerX <= X && X <= upperX && lowerY <= Y && Y <= upperY
          return true
      end
   return false
end
# ==============================================================================
 function Lens(origin,  point, size)
     d = distance(origin, point)/size
     return 1 / ((d)+1) # or optionally (d*d) for a more gradual curve
 end
# ==============================================================================
function distance(xa,ya, xb,yb)
    X, Y = (xa - xb), (ya - yb)
    return sqrt( (X*X) + (Y*Y) )
end
# ==============================================================================
function distance(origin, point)
    X = origin.x - point.x
    Y = origin.y - point.y
    return sqrt( (X*X) + (Y*Y) )
end
# ==============================================================================
function getAngle(x1,y1, x2,y2)
      deltaX = x2 - x1;
      deltaY = y2 - y1;
      rad = atan2(deltaY, deltaX); # In radians
      return rad * (180 / pi) # Then convert radians to degrees
end
# Rotate around the z-axis
# ==============================================================================
function rotateXYZ(points, ϑx, ϑy, ϑz)
        sinϑz, cosϑz = sin(ϑz), cos(ϑz)
        sinϑy, cosϑy = sin(ϑy), cos(ϑy)
        sinϑx, cosϑx = sin(ϑx), cos(ϑx)

    for p in points
        X   = p.x * cosϑz - p.y * sinϑz;
        p.y = p.y * cosϑz + p.x * sinϑz;
        p.x = X
        X   = p.x * cosϑy - p.z * sinϑy;
        p.z = p.z * cosϑy + p.x * sinϑy;
        p.x = X
        Y   = p.y * cosϑx - p.z * sinϑx;
        p.z = p.z * cosϑx + p.y * sinϑx;
        p.y = Y
    end
end

# ==============================================================================
function rotateZ3D(theta, x, y)
      # theta<0 && (theta = 0)
        sinTheta = sin(theta);
        cosTheta = cos(theta);

            X = x * cosTheta - y * sinTheta;
            Y = y * cosTheta + x * sinTheta;

        return (X,Y)
end
      # round(Int64, r*cos(t) + x),
      # round(Int64, r*sin(t) + y)
# ==============================================================================
function  rotateY3D(theta, x, z)
     sinTheta = sin(theta);
     cosTheta = cos(theta);

        X = x * cosTheta - z * sinTheta;
        Z = z * cosTheta + x * sinTheta;
    return (X,Z)
end
# ==============================================================================
function  rotateX3D(theta, y, z)
     sinTheta = sin(theta);
     cosTheta = cos(theta);

        Y = y * cosTheta - z * sinTheta;
        Z = z * cosTheta + y * sinTheta;
    return (Y,Z)
end
# ==============================================================================
# rotateZ3D(30);
# rotateY3D(30);
# rotateX3D(30);
# ==============================================================================
# ==============================================================================
# ==============================================================================
# slope intercept form: y = mx+b
#   where m = slope and b = y intercept
# if y = Intercept(m = .3, x = 2, b = -2)    m*x +b
# ==============================================================================
intercept(m, x, b) = m*x+b
# ==============================================================================
