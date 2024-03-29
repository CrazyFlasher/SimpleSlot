// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package utils;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.geom.Matrix3D;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;

/** A utility class containing methods related to the Rectangle class. */
class RectangleUtil
{
    // helper objects
    private static var sPoint : Point = new Point();
    private static var sPoint3D : Vector3D = new Vector3D();
    private static var sPositions : Array<Point> = 
        [new Point(), new Point(), new Point(), new Point()];
    
    /** @private */
    public function new()
    {
        throw new Error();
    }
    
    /** Calculates the intersection between two Rectangles. If the rectangles do not intersect,
     *  this method returns an empty Rectangle object with its properties set to 0. */
    public static function intersect(rect1 : Rectangle, rect2 : Rectangle,
            out : Rectangle = null) : Rectangle
    {
        if (out == null)
        {
            out = new Rectangle();
        }
        
        var left : Float = (rect1.x > rect2.x) ? rect1.x : rect2.x;
        var right : Float = (rect1.right < rect2.right) ? rect1.right : rect2.right;
        var top : Float = (rect1.y > rect2.y) ? rect1.y : rect2.y;
        var bottom : Float = (rect1.bottom < rect2.bottom) ? rect1.bottom : rect2.bottom;
        
        if (left > right || top > bottom)
        {
            out.setEmpty();
        }
        else
        {
            out.setTo(left, top, right - left, bottom - top);
        }
        
        return out;
    }
    
    /** Calculates a rectangle with the same aspect ratio as the given 'rectangle',
     *  centered within 'into'.  
     * 
     *  <p>This method is useful for calculating the optimal viewPort for a certain display 
     *  size. You can use different scale modes to specify how the result should be calculated;
     *  furthermore, you can avoid pixel alignment errors by only allowing whole-number  
     *  multipliers/divisors (e.g. 3, 2, 1, 1/2, 1/3).</p>
     *  
     *  @see starling.utils.ScaleMode
     */
    public static function fit(rectangle : Rectangle, into : Rectangle,
            scaleMode : String = "showAll", pixelPerfect : Bool = false,
            out : Rectangle = null) : Rectangle
    {
        if (!ScaleMode.isValid(scaleMode))
        {
            throw new ArgumentError("Invalid scaleMode: " + scaleMode);
        }
        if (out == null)
        {
            out = new Rectangle();
        }
        
        var width : Float = rectangle.width;
        var height : Float = rectangle.height;
        var factorX : Float = into.width / width;
        var factorY : Float = into.height / height;
        var factor : Float = 1.0;
        
        if (scaleMode == ScaleMode.SHOW_ALL)
        {
            factor = (factorX < factorY) ? factorX : factorY;
            if (pixelPerfect)
            {
                factor = nextSuitableScaleFactor(factor, false);
            }
        }
        else if (scaleMode == ScaleMode.NO_BORDER)
        {
            factor = (factorX > factorY) ? factorX : factorY;
            if (pixelPerfect)
            {
                factor = nextSuitableScaleFactor(factor, true);
            }
        }
        
        width *= factor;
        height *= factor;
        
        out.setTo(
                into.x + (into.width - width) / 2, 
                into.y + (into.height - height) / 2, 
                width, height
        );
        
        return out;
    }
    
    /** Calculates the next whole-number multiplier or divisor, moving either up or down. */
    private static function nextSuitableScaleFactor(factor : Float, up : Bool) : Float
    {
        var divisor : Float = 1.0;
        
        if (up)
        {
            if (factor >= 0.5)
            {
                return Math.ceil(factor);
            }
            else
            {
                while (1.0 / (divisor + 1) > factor)
                {
                    ++divisor;
                }
            }
        }
        else if (factor >= 1.0)
        {
            return Math.floor(factor);
        }
        else
        {
            while (1.0 / divisor > factor)
            {
                ++divisor;
            }
        }
        
        return 1.0 / divisor;
    }
    
    /** If the rectangle contains negative values for width or height, all coordinates
     *  are adjusted so that the rectangle describes the same region with positive values. */
    public static function normalize(rect : Rectangle) : Void
    {
        if (rect.width < 0)
        {
            rect.width = -rect.width;
            rect.x -= rect.width;
        }
        
        if (rect.height < 0)
        {
            rect.height = -rect.height;
            rect.y -= rect.height;
        }
    }
    
    /** Extends the rectangle in all four directions. */
    public static function extend(rect : Rectangle, left : Float = 0, right : Float = 0,
            top : Float = 0, bottom : Float = 0) : Void
    {
        rect.x -= left;
        rect.y -= top;
        rect.width += left + right;
        rect.height += top + bottom;
    }
    
    /** Extends the rectangle in all four directions so that it is exactly on pixel bounds. */
    public static function extendToWholePixels(rect : Rectangle, scaleFactor : Float = 1) : Void
    {
        var left : Float = Math.floor(rect.x * scaleFactor) / scaleFactor;
        var top : Float = Math.floor(rect.y * scaleFactor) / scaleFactor;
        var right : Float = Math.ceil(rect.right * scaleFactor) / scaleFactor;
        var bottom : Float = Math.ceil(rect.bottom * scaleFactor) / scaleFactor;
        
        rect.setTo(left, top, right - left, bottom - top);
    }
    
    /** Calculates the bounds of a rectangle after transforming it by a matrix.
     *  If you pass an <code>out</code>-rectangle, the result will be stored in this rectangle
     *  instead of creating a new object. */
    public static function getBounds(rectangle : Rectangle, matrix : Matrix,
            out : Rectangle = null) : Rectangle
    {
        if (out == null)
        {
            out = new Rectangle();
        }
        
        var minX : Float = Math.POSITIVE_INFINITY;
        var maxX : Float = -Math.POSITIVE_INFINITY;
        var minY : Float = Math.POSITIVE_INFINITY;
        var maxY : Float = -Math.POSITIVE_INFINITY;
        var positions : Array<Point> = getPositions(rectangle, sPositions);
        
        for (i in 0...4)
        {
            MatrixUtil.transformCoords(matrix, positions[i].x, positions[i].y, sPoint);
            
            if (minX > sPoint.x)
            {
                minX = sPoint.x;
            }
            if (maxX < sPoint.x)
            {
                maxX = sPoint.x;
            }
            if (minY > sPoint.y)
            {
                minY = sPoint.y;
            }
            if (maxY < sPoint.y)
            {
                maxY = sPoint.y;
            }
        }
        
        out.setTo(minX, minY, maxX - minX, maxY - minY);
        return out;
    }
    
    /** Calculates the bounds of a rectangle projected into the XY-plane of a certain 3D space
     *  as they appear from the given camera position. Note that 'camPos' is expected in the
     *  target coordinate system (the same that the XY-plane lies in).
     *
     *  <p>If you pass an 'out' Rectangle, the result will be stored in this rectangle
     *  instead of creating a new object.</p> */
    public static function getBoundsProjected(rectangle : Rectangle, matrix : Matrix3D,
            camPos : Vector3D, out : Rectangle = null) : Rectangle
    {
        if (out == null)
        {
            out = new Rectangle();
        }
        if (camPos == null)
        {
            throw new ArgumentError("camPos must not be null");
        }
        
        var minX : Float = Math.POSITIVE_INFINITY;
        var maxX : Float = -Math.POSITIVE_INFINITY;
        var minY : Float = Math.POSITIVE_INFINITY;
        var maxY : Float = -Math.POSITIVE_INFINITY;
        var positions : Array<Point> = getPositions(rectangle, sPositions);
        
        for (i in 0...4)
        {
            var position : Point = positions[i];
            
            if (matrix != null)
            {
                MatrixUtil.transformCoords3D(matrix, position.x, position.y, 0, sPoint3D);
            }
            else
            {
                sPoint3D.setTo(position.x, position.y, 0);
            }
            
            MathUtil.intersectLineWithXYPlane(camPos, sPoint3D, sPoint);
            
            if (minX > sPoint.x)
            {
                minX = sPoint.x;
            }
            if (maxX < sPoint.x)
            {
                maxX = sPoint.x;
            }
            if (minY > sPoint.y)
            {
                minY = sPoint.y;
            }
            if (maxY < sPoint.y)
            {
                maxY = sPoint.y;
            }
        }
        
        out.setTo(minX, minY, maxX - minX, maxY - minY);
        return out;
    }
    
    /** Returns a vector containing the positions of the four edges of the given rectangle. */
    public static function getPositions(rectangle : Rectangle,
            out : Array<Point> = null) : Array<Point>
    {
        if (out == null)
        {
            out = new Array<Point>();
        }
        
        for (i in 0...4)
        {
            if (out[i] == null)
            {
                out[i] = new Point();
            }
        }
        
        out[0].x = rectangle.left;out[0].y = rectangle.top;
        out[1].x = rectangle.right;out[1].y = rectangle.top;
        out[2].x = rectangle.left;out[2].y = rectangle.bottom;
        out[3].x = rectangle.right;out[3].y = rectangle.bottom;
        return out;
    }
    
    /** Compares all properties of the given rectangle, returning true only if
     *  they are equal (with the given accuracy 'e'). */
    public static function compare(r1 : Rectangle, r2 : Rectangle, e : Float = 0.0001) : Bool
    {
        if (r1 == null)
        {
            return r2 == null;
        }
        else if (r2 == null)
        {
            return false;
        }
        else
        {
            return r1.x > r2.x - e && r1.x < r2.x + e &&
            r1.y > r2.y - e && r1.y < r2.y + e &&
            r1.width > r2.width - e && r1.width < r2.width + e &&
            r1.height > r2.height - e && r1.height < r2.height + e;
        }
    }
}
