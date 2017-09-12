module Generate
using ImageView, Images
using ImageFiltering, Colors, ImageMetadata, FixedPointNumbers
# using , TestImages
# ==============================================================================
# a few convenience variables...
     currentPath = pwd()
# ==============================================================================
# Calculate the distance between a and b
# ==============================================================================
function distance(xa,ya, xb,yb)
    X, Y = (xa - xb), (ya - yb)
    return sqrt( (X*X) + (Y*Y) )
end
# ==============================================================================
# Calculate a lens effect: x = ((oy-x)*(1/d) * degree) and y = ((oy-y)*(1/d) * degree)
# ------------------------------------------------------------------------------
# Let's pre-calculate the lens curvature  ...this should speed things up a bit.
# Curve = [ (1/X) for X in 1:10000]
# ------------------------------------------------------------------------------
type Body
    value::Float64            # value of curvature
    curve::Array{Float64,1}   # lens curvature
    voxels::Any               # Voxels image of body
    class::String
    x::Float64                # x origon
    y::Float64                # y origon
    z::Float64                # z origon
    Body(value, x, y, z) = new(value,Float64[],0, "", x, y, z)
end

# ------------------------------------------------------------------------------
type Space
    dir::String               # directory for saving images
    bodies::Array{Body,1}     # lens curvature
    limit::Float64            # the size of our universe
    Space() = new("", [], 100000)
    Space(limit) = new("", [], limit)
    Space(dir,limit) = new(dir, [], limit)
end
# ------------------------------------------------------------------------------
galaxies = ["E0", "E3", "E7", "S0", "Sa", "Sb", "SBa", "SBb", "SBc", "Sc"]
# ------------------------------------------------------------------------------
function createRandomBodies(space, number, bounds) # 1575
    Z = rand( 1:bounds, number) # Create Z coords before anything else
    sort!(Z) # Now sort them for depth
    str = "\t\t{  \"number\":$(number), \"bounds\":$(bounds),  \"bodies\":[  "
    for i in 1:number
        # Eventually the weight "10" will have to be correctly calculated!
        if i>1; str *= ", "; end
        str *= createBody(space, round(Int64, ((bounds-Z[i])*0.1)+1), rand(galaxies), rand(1:bounds), rand(1:bounds), Z[i])
    end

    return str*= "\n\t\t\t]\n\t\t}"
end
# ------------------------------------------------------------------------------
function createBody(body, weight, class, x, y, z)
    str = "\n\t\t\t{  \"class\":\"$(class)\", \"value\":$(weight), \"x\":$(x), \"y\":$(y), \"z\":$(z)  }"
    blackHole = Body(convert(Float64, weight), convert(Float64, x), convert(Float64, y), convert(Float64, z))
    blackHole.class = class * ".jpg"
    blackHole.curve = [ (1/X) for X in 1:10000] * weight
    push!(body.bodies, blackHole )
    return str
end
# ==============================================================================
# Test if in bounds
# ==============================================================================
function inBounds(width, height, x,y)
        return y < height && y > 0 && x < width && x > 0
end
# ==============================================================================
# interpolate: this is temprrary
# ==============================================================================
function interpolate(img, x,y )
    W, H = size(img)
    !inBounds(W, H, x,y) && return RGB(0,0,0) # FAIL!

    (x < 2)  ? ra = 1 : ra = x-1
    (x >= W) ? rc = W : rc = x+1
    (y < 2)  ? ca = 1 : ca = y-1
    (y >= H) ? cc = H : cc = y+1

    return  (float32(img[x,y]) + img[x,ca] + img[x,cc] + img[ra,y] + img[rc,y])/5

end
# ==============================================================================
# function warp(x,y, ox,oy, degree)
# ==============================================================================
function warp(x,y, body) # TODO: later make this work with slices (that is to say vector fields)
    ox, oy = body.x, body.y
        dx, dy = (ox - x), (oy - y) # Get 1D, 1D distance
        D = sqrt( (dx * dx) + (dy * dy)  ) # Get 2D distance
        (D==0) && return (0,0) # No point in doing anything if it's zero

        d = body.curve[round(Int64,D)];
        X,Y   =  round(Int64,x+(dx*d)), round(Int64,y+(dy*d))
    return (X,Y)
end
# ==============================================================================
# Draw a small images to "image"
# ==============================================================================
function paintToFlat(image, bodies, bounds) # it may be possible to do this with view()
    imagewidth, imageheight = size(image)


    for body in bodies # for each body
        buffer = load(currentPath * "/lens/images/" * body.class)
        sz = round(Int64, ((bounds-body.z)*0.1)+1) # body.value # round(Int64, ((bounds-body.z)*0.1)+1)
        buffer = imresize(buffer, (sz,sz) )
        width, height = size(buffer)
        halfWidth, halfHeight = round(Int64, width*.5), round(Int64, height*.5)
        rx, ry = rand(1:imagewidth), rand(1:imagewidth)

            for x in 1:width, y in 1:height
                # This is the correct formula but...
                # X,Y = round(Int64, body.x)-halfWidth+x, round(Int64, body.y)-halfHeight+y
                # For now we are going to paint to random locations
                X,Y = rx-halfWidth+x, ry-halfHeight+y
                if inBounds(imagewidth, imageheight, X,Y) # OLD: Y < imageheight && Y > 0 && X < imagewidth && X > 0
                    back = image[X,Y]
                    front = buffer[x,y]
                    image[X,Y] = RGB(red(back)+red(front), green(back)+green(front), blue(back)+blue(front))
                    #buffer[x,y]
                    #interpolate(sourceImage, x,y )
                    # TODO maybe use: P = bilinear_interpolation(img, r, c)
                end
            end
    end
    return image
end
# ==============================================================================
# Apply function warp() to all pixels:
# ==============================================================================
function generator(space, index)
    size = round(Int64, space.limit)
    flat = fill(RGB{N0f8}(0,0,0),(size, size))
    flat = paintToFlat(flat, space.bodies, space.limit)
    warped = fill(RGB{N0f8}(0,0,0),(size, size))
    width, height = size, size
    halfWidth, halfHeight = round(Int64, size*.5), round(Int64, size*.5)



    for x in 1:width, y in 1:height
        X, Y = x,y
        black = false
        for plane in space.bodies

            X, Y = warp(X, Y, plane)

            if Y > height || Y < 1 || X > width || X < 1 #     || Z > space.limit || Z < 1
                black = true
                break
            end
        end

        # TODO: test for intersection of ray with body, paint pixel and break.
        if  black == false
            warped[x,y] =  interpolate(flat, X,Y ) #flat[X,Y] # Simple way  interpolate(flat, X,Y ) #
        else
            warped[x,y] = RGB(0,0,0) # plot black pixel because the value falls outside the bounds of our universe
        end

    end
    save(space.dir * "warp_$(index).jpg", warped)
    save(space.dir * "flat_$(index).jpg", flat)

end
# ==============================================================================
# Generate x number of image sets along with a description
# ==============================================================================
function generateImages(directory, quantity::Int64, lensLimit, expanse::Int64)

report = "\"images\":[\n"


    for index in 1:quantity # many images
        space = Space(directory, expanse)
        if index>1; report *= ", \n"; end
        report *= createRandomBodies(space, rand(1:lensLimit), expanse)
        generator(space, index)
    end
    report *= "]\r"
    println("Ok, finished generating $(quantity) pairs of images!")
    # print(report)
    open( directory * "report.json", "w") do f
            write(f, report)
    end
end
# ==============================================================================


    generateImages(
            currentPath * "/lens/output/", # destination path fro generated files
            10,                             # number of image sets to generate (sets because 1 = warp_1.jpg, flat_1.jpg)
            16,                             # maximum number of lenses
            500                            # a value for height, width, depth of space
        )



end # module
