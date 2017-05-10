
 type Point
     x::Float32
     y::Float32
     # z::Float32
     Point(x,y) = new(x,y)
 end

 # ==============================================================================
 function restrict(lower, i, upper)
     if i > upper
         return upper
     end
     if i < lower
         return lower
     end
     return i
 end
# ==============================================================================
 function Lens(origin,  point, size)
     d = distance(origin, point)/size
     return 1 / ((d)+1) # or optionally (d*d) for a more gradual curve
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
     # Then convert radians to degrees
      return rad * (180 / pi)
end
# Rotate around the z-axis
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
