module lens
include("Utility.jl")
using ImageView, Images, TestImages #, CoordinateTransformations, OffsetArrays
using ImageFiltering, Colors, ImageMetadata

<<<<<<< HEAD
using ImageView, Images, TestImages #, CoordinateTransformations, OffsetArrays
using ImageFiltering, Colors, ImageMetadata

type Point
    x::Float32
    y::Float32
    Point(x,y) = new(x,y)
end
=======

>>>>>>> Travis

imgc = testimage("mandrill")
# or this to load your own file!
# using FileIO


#imgc = imfilter(img, Kernel.gaussian(3));
# imgc = rand(RGB{Float32},200,200)
<<<<<<< HEAD

=======
# ------------------------------------------------------------------------------
# I think that the way to do the ray tracing is to use an array of "Lens" values
# as the curve of the imaginary lens. Since it is a curve and not a 3d shape the
# formula can be applied radially by simply measuring the distance of each pixel
# from the lens origion and using the distance as the index of the lens array.
#
# We must also keep track of the angle of the pixel (from the lens origin) for
# later use in ray tracing.
#
# The angle that the ray is bent to is an inversion relative to the angle of the
# point on the curve that is hit by the ray. So, for surface angle  +0.953
# ------------------------------------------------------------------------------
rot   =   1.5707963 # 90°

# ==============================================================================
>>>>>>> Travis
function Lens(origin,  point, size)
    d = distance(origin, point)/size
    return 1 / ((d)+1) # or optionally (d*d) for a more gradual curve
end

<<<<<<< HEAD
=======


# ==============================================================================
>>>>>>> Travis
function distance(origin, point)
    X = origin.x - point.x
    Y = origin.y - point.y
    return sqrt( (X*X) + (Y*Y) )
end

<<<<<<< HEAD
# println(typeof(imgc[]))
 width, height = size(imgc)

O = Point(width*.5, height*.5)
for x in 1:width
    for y in 1:height
        value = Lens(O,  Point(x,y), 50)
        p = imgc[x,y]

            r = (red(p)   + value)*.5
            b = (green(p) + value)*.5
            g = (blue(p)  + value)*.5
        imgc[x,y] = RGB(convert(N0f8,r),convert(N0f8,g),convert(N0f8,b))
    end
end
=======
 Curve = [( 1/(X+1) ) for X in 1:2000]
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
# * 180 / pi
# ==============================================================================
 width, height = size(imgc)
println("type: ", typeof(width))
halfWidth, halfHeight = width*.5, height*.5
O = Point(halfWidth, halfHeight)

for x in 1:width
    for y in 1:height
        #value = Lens(O,  Point(x,y), 50)
        dist = round(Int64 , abs(distance(O, Point(x,y))))
        angle = getAngle(halfWidth, halfHeight, x,y)
# println("dist: $dist")
    dist == 0 && (dist = 1)
        i = Curve[round(Int64, dist)]/10 #-Curve[dist+2]
        rx,ry = rotateZ3D(i, x+0.0, y+0.0)


        rx = round(Int64, rx )
        ry = round(Int64, ry )
        # println(rx, ry)
    if rx > 0 && rx <= width && ry > 0 && ry <= height
            p = imgc[rx,ry]
            imgc[x,y] = RGB(red(p),green(p),blue(p))
    else
            imgc[x,y] = RGB(convert(N0f8,0),convert(N0f8,0),convert(N0f8,0))
    end

    end
end
# ==============================================================================
>>>>>>> Travis

imshow(imgc, pixelspacing = [1,1])

end # module
