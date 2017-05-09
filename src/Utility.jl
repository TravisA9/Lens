
 type Point
     x::Float32
     y::Float32
     # z::Float32
     Point(x,y) = new(x,y)
 end

function getAngle(x1,y1, x2,y2)
      deltaX = x2 - x1;
      deltaY = y2 - y1;
      rad = atan2(deltaY, deltaX); # In radians
     # Then convert radians to degrees
      return rad * (180 / pi)
end
# Rotate around the z-axis
# ==============================================================================
function rotateZ3D(theta, x::Float64, y::Float64)
      theta<0 && (theta = 0)
        sinTheta = sin(theta);
        cosTheta = cos(theta);

            X = x * cosTheta - y * sinTheta;
            Y = y * cosTheta + x * sinTheta;
        return (X,Y)
end
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
#=function  draw()
    background(backgroundColour);

    # Draw edges
    stroke(edgeColour);
    for ( e=0; e<edges.length; e++)
         n0 = edges[e][0];
         n1 = edges[e][1];
         node0 = nodes[n0];
         node1 = nodes[n1];
        line(node0[0], node0[1], node1[0], node1[1]);
    end

    # Draw nodes
    fill(nodeColour);
    noStroke();
    for ( n=0; n<nodes.length; n++)
         node = nodes[n];
        ellipse(node[0], node[1], nodeSize, nodeSize);
    end

end;=#

# ==============================================================================
function mouseDragged()
    rotateY3D(mouseX - pmouseX);
    rotateX3D(mouseY - pmouseY);
end
