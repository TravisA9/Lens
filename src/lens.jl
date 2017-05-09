module lens

using ImageView, Images, TestImages #, CoordinateTransformations, OffsetArrays
using ImageFiltering, Colors, ImageMetadata

type Point
    x::Float32
    y::Float32
    Point(x,y) = new(x,y)
end

imgc = testimage("mandrill")
# or this to load your own file!
# using FileIO


#imgc = imfilter(img, Kernel.gaussian(3));
# imgc = rand(RGB{Float32},200,200)

function Lens(origin,  point, size)
    d = distance(origin, point)/size
    return 1 / ((d)+1) # or optionally (d*d) for a more gradual curve
end

function distance(origin, point)
    X = origin.x - point.x
    Y = origin.y - point.y
    return sqrt( (X*X) + (Y*Y) )
end

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

imshow(imgc, pixelspacing = [1,1])

end # module
