//
//  ImageTool.swift
//  ImageTest
//
//  Created by Gavin Xiang on 2024/4/25.
//

import UIKit

public extension UIImage {
    
    @objc func createGradientRounded(tintColor: UIColor) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, size.width, size.height)
        gradientLayer.colors = [tintColor.withAlphaComponent(0.5).cgColor, tintColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.contentsCenter = CGRect(x: 0.5, y: 0.5, width: 0, height: 0)
        
        let contentsCenterLayer = CALayer()
        contentsCenterLayer.contents = cgImage
        contentsCenterLayer.frame = CGRectMake(0, 0, size.width, size.height)
        contentsCenterLayer.contentsGravity = .resizeAspectFill
        contentsCenterLayer.mask = gradientLayer
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            contentsCenterLayer.render(in: context)
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return roundedImage
        }
        return nil
    }
    
    
    /// Returns a new image with the specified shadow properties.
    /// This will increase the size of the image to fit the shadow and the original image.
    @objc func withShadow(blur: CGFloat = 6, offset: CGSize = .zero, color: UIColor = UIColor(white: 0, alpha: 0.8)) -> UIImage {
        
        let shadowRect = CGRect(
            x: offset.width - blur,
            y: offset.height - blur,
            width: size.width + blur * 2,
            height: size.height + blur * 2
        )
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0),
                height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
            ),
            false, 0
        )
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setShadow(
            offset: offset,
            blur: blur,
            color: color.cgColor
        )
        
        draw(
            in: CGRect(
                x: max(0, -shadowRect.origin.x),
                y: max(0, -shadowRect.origin.y),
                width: size.width,
                height: size.height
            )
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Returns a new image with the specified shadow properties.
    /// This will increase the size of the image to fit the shadow and the original image.
    @objc func shapeBezierPath(blur: CGFloat = 6, offset: CGFloat = 10, scale: CGFloat) -> UIBezierPath? {
        // create path from non-transparent points
//        let points = nonTransparentPoints()
        let pointsV3 = nonTransparentPointsV3()//[leftPoints, rightPoints, topPoints, bottomPoints]
        let count = edgePointsNum()
//        let topMostPoints = topMostPoints(points: points, count: count, blur: blur)
        let rightMostPoints = rightMostPoints(points: pointsV3.1, count: count, blur: blur)
        let bottomMostPoints = bottomMostPoints(points: pointsV3.3, count: count, blur: blur)
//        let leftMostPoints = leftMostPoints(points: points, count: count, blur: blur)
        
        var outerPoints = [CGPoint]()
        let outerRightMostPoints = rightMostPoints.dropFirst().map { return CGPoint(x: $0.x / scale, y: $0.y / scale - blur) }
        outerPoints.append(contentsOf: outerRightMostPoints)
        let outerBottomMostPoints = bottomMostPoints.dropLast().map { return CGPoint(x: $0.x / scale - blur, y: $0.y / scale) }
        outerPoints.append(contentsOf: outerBottomMostPoints)
        
        let outerBottomLeastPoints = outerBottomMostPoints.reversed().map { return CGPoint(x: $0.x, y: $0.y - offset) }
        outerPoints.append(contentsOf: outerBottomLeastPoints)
        let outerRightLeastPoints = outerRightMostPoints.reversed().map { return CGPoint(x: $0.x - offset, y: $0.y) }
        outerPoints.append(contentsOf: outerRightLeastPoints)
        
        let path = createBezierPath(from: outerPoints)
        path.lineWidth = 5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.close()
//        path.stroke()
        return path
    }
    
    @objc func shadowSlazzerPhoto(blur: CGFloat = 6, offset: CGSize = .zero, color: UIColor = UIColor(white: 0, alpha: 0.4)) -> UIImage {
        let shadowRect = CGRect(
            x: offset.width - blur,
            y: offset.height - blur,
            width: size.width + blur * 2,
            height: size.height + blur * 2
        )

        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: shadowRect.width + blur + abs(offset.width),
                height: shadowRect.height + blur + abs(offset.height)
            ),
            false, 0
        )

        let context = UIGraphicsGetCurrentContext()!

        context.setShadow(
            offset: offset,
            blur: blur,
            color: color.cgColor
        )

        // create path from non-transparent points
//        let points = nonTransparentPoints()
//        let count = edgePointsNum()
//        let topMostPoints = topMostPoints(points: points, count: count, blur: blur)
//        let rightMostPoints = rightMostPoints(points: points, count: count, blur: blur)
//        let bottomMostPoints = bottomMostPoints(points: points, count: count, blur: blur)
//        let leftMostPoints = leftMostPoints(points: points, count: count, blur: blur)
//        var allPoints = [CGPoint]()
//        allPoints.append(contentsOf: topMostPoints)
//        allPoints.append(contentsOf: rightMostPoints)
//        allPoints.append(contentsOf: bottomMostPoints)
//        allPoints.append(contentsOf: leftMostPoints)

        let pointsV2 = nonTransparentPointsV2(blur: blur)

        var points = [CGPoint]()
        points.append(contentsOf: pointsV2.1)
        let leftPoints: [CGPoint] = pointsV2.0
        let reversed = leftPoints.reversed()
        points.append(contentsOf: reversed)

        let path = createBezierPath(from: points)
        path.lineWidth = 5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        context.setFillColor(UIColor.white.cgColor)
//        context.setStrokeColor(color.cgColor)
        path.close()
//        path.stroke()
        path.fill()
        
        draw(
            in: CGRect(
                x: blur,
                y: blur,
                width: size.width,
                height: size.height
            )
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
    
    /// Returns a new image with the specified shadow properties.
    /// This will increase the size of the image to fit the shadow and the original image.
    @objc func withOnlyShadow(blur: CGFloat = 6, offset: CGSize = .zero, color: UIColor = UIColor(white: 0, alpha: 0.4)) -> UIImage {
        
        let blur = blur * CGFloat(pixelScale())
        
        let shadowRect = CGRect(
            x: offset.width - blur,
            y: offset.height - blur,
            width: size.width + blur * 2,
            height: size.height + blur * 2
        )
        
//        UIGraphicsBeginImageContextWithOptions(
//            CGSize(
//                width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0),
//                height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
//            ),
//            false, 0
//        )
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: shadowRect.width + blur + abs(offset.width),
                height: shadowRect.height + blur + abs(offset.height)
            ),
            false, 0
        )
        
        let context = UIGraphicsGetCurrentContext()!
        
        //test
//        context.setShadow(
//            offset: offset,
//            blur: blur,
//            color: color.cgColor
//        )
        
//        draw(
//            in: CGRect(
//                x: max(0, -shadowRect.origin.x),
//                y: max(0, -shadowRect.origin.y),
//                width: size.width,
//                height: size.height
//            )
//        )
        
//        let replaced = replaceColor(.red, with: .purple, tolerance: 0.5)
//        let edgeImage = self.detectEdges()
//        let replaced = edgeImage?.withTintColor(.orange, renderingMode: .alwaysTemplate)
//        let transparentBorderImage = self.transparentBorderImage(5)
//        replaced?.draw(
//            in: CGRect(
//                x: max(0, -shadowRect.origin.x),
//                y: max(0, -shadowRect.origin.y),
//                width: size.width,
//                height: size.height
//            )
//        )
        
        // Paint the View Blue before drawing the Semi-Circle
        //        context.setFillColor(UIColor.blue.cgColor)  // Set fill color
        //        CGContextFillRect(context, rect) // Fill rectangle using the context data
        
        // Imagine the setting Sun. Please go a bit further in your imagination so that the Sun looks like a perfect circle which is perfectly sliced in the middle by the perfectly horizontal horizon. 🙂
        // This can be drawn by having two parameters
        // Bottom Left = (x: 0, y: Container Height)
        // Bottom Right = (x: Container Width, y: Container Height)
        
        // Create path for drawing a triangle
        /*
        let path = UIBezierPath()
        path.lineWidth = 5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        // Add Semi-Circle Arc from Bottom Left to Bottom Right
        //        path.addArc(withCenter: CGPointMake(size.width / 2, size.height), radius: size.width / 2, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
        path.addArc(withCenter: CGPointMake(size.width / 2.0, size.width / 3), radius: size.width / 3, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3, clockwise: true)
        
        //        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 50)
        //        path.lineWidth = 2
        
        // Notice that the angle is measured counter-clockwise from right.
        // You might think that since the path is not complete, this might not work.
        // But the fill method does this for you 🙂
        // Set the fill color
        context.setFillColor(UIColor.green.cgColor)
        context.setStrokeColor(UIColor.orange.cgColor)
        //        path.close()
        // Fill the triangle path
        path.stroke()
        path.fill()
         */
        
        // create path from non-transparent points
//        let points = nonTransparentPoints()
//        let pointsV3 = nonTransparentPointsV3() //[leftPoints, rightPoints, topPoints, bottomPoints]
        let points = nonTransparentEdgePoints()
        let count = edgePointsNum()
        let topMostPoints = topMostPoints(points: points, count: count, blur: blur).sorted { p1, p2 in
            return p1.x < p2.x
        }
        let rightMostPoints = rightMostPoints(points: points, count: count, blur: blur).sorted { p1, p2 in
            return p1.y < p2.y
        }
        let bottomMostPoints = bottomMostPoints(points: points, count: count, blur: blur).sorted { p1, p2 in
            return p1.x > p2.x
        }
        let leftMostPoints = leftMostPoints(points: points, count: count, blur: blur).sorted { p1, p2 in
            return p1.y > p2.y
        }
        var allPoints = [CGPoint]()
        allPoints.append(contentsOf: topMostPoints)
        allPoints.append(contentsOf: rightMostPoints)
        allPoints.append(contentsOf: bottomMostPoints)
        allPoints.append(contentsOf: leftMostPoints)
        
        let path = createBezierPath(from: allPoints)
        path.lineWidth = 5
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        context.setFillColor(UIColor.white.cgColor)
//        context.setStrokeColor(UIColor.orange.cgColor)
        path.close()
//        path.stroke()
        path.fill()
        
        draw(
            in: CGRect(
                x: blur,
                y: blur,
                width: size.width,
                height: size.height
            )
        )
        
        var image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: image.size.width + blur * 2,
                height: image.size.height + blur * 2
            ),
            false, 0
        )
        
        let context2 = UIGraphicsGetCurrentContext()!
        
        context2.setShadow(
            offset: offset,
            blur: blur,
            color: UIColor(white: 0, alpha: 0.8).cgColor
        )
        
        var outerPoints = [CGPoint]()
        let outerTopMostPoints = topMostPoints.map { return CGPoint(x: $0.x + blur, y: $0.y + blur - blur) }
        outerPoints.append(contentsOf: outerTopMostPoints)
        let outerRightMostPoints = rightMostPoints.map { return CGPoint(x: $0.x + blur + blur, y: $0.y + blur) }
        outerPoints.append(contentsOf: outerRightMostPoints)
        let outerBottomMostPoints = bottomMostPoints.map { return CGPoint(x: $0.x + blur, y: $0.y + blur + blur) }
        outerPoints.append(contentsOf: outerBottomMostPoints)
        let outerLeftMostPoints = leftMostPoints.map { return CGPoint(x: $0.x + blur - blur, y: $0.y + blur) }
        outerPoints.append(contentsOf: outerLeftMostPoints)
        
        let path2 = createBezierPath(from: outerPoints)
        path2.lineWidth = 0
        path2.lineCapStyle = .round
        path2.lineJoinStyle = .round
//        context2.setStrokeColor(UIColor.blue.cgColor)
        context2.setFillColor(UIColor.white.cgColor)
        path2.close()
//        path2.stroke()
        path2.fill()
        
        image.draw(
            in: CGRect(
                x: blur,
                y: blur,
                width: image.size.width,
                height: image.size.height
            )
        )
        
        let shadowOffsetRB: CGFloat = CGFloat(blur * CGFloat(pixelScale()))
        let shadowOffsetTL: CGFloat = shadowOffsetRB / 2.0
        let shadowDiff = shadowOffsetRB - shadowOffsetTL
        var shadowPoints = [CGPoint]()
        let shadowRightMostPoints = outerRightMostPoints.dropFirst()
        shadowPoints.append(contentsOf: shadowRightMostPoints)
        let shadowBottomMostPoints = outerBottomMostPoints.dropLast()
        shadowPoints.append(contentsOf: shadowBottomMostPoints)
        if let outerLeftPoint = outerLeftMostPoints.first {
            shadowPoints.append(outerLeftPoint)
            shadowPoints.append(CGPoint(x: outerLeftPoint.x + shadowDiff, y: outerLeftPoint.y))
        }
        let shadowBottomLeastPoints = outerBottomMostPoints.reversed().dropFirst().map { return CGPoint(x: $0.x, y: $0.y - shadowOffsetRB) }
        shadowPoints.append(contentsOf: shadowBottomLeastPoints)
        let shadowRightLeastPoints = outerRightMostPoints.reversed().dropLast().map { return CGPoint(x: $0.x - shadowOffsetRB, y: $0.y) }
        shadowPoints.append(contentsOf: shadowRightLeastPoints)
        if let outerTopPoint = outerTopMostPoints.last {
            shadowPoints.append(CGPoint(x: outerTopPoint.x, y: outerTopPoint.y + shadowDiff))
            shadowPoints.append(outerTopPoint)
        }
        
        let customShadowColor = color//UIColor.white//test //color
        
        let shadowPath = createBezierPath(from: shadowPoints)
        shadowPath.lineWidth = 2
        shadowPath.lineCapStyle = .round
        shadowPath.lineJoinStyle = .round
        shadowPath.close()
        context2.setFillColor(customShadowColor.cgColor)
        shadowPath.fill()
        
//        let cgColors = [UIColor(white: 0, alpha: 0), UIColor(white: 0, alpha: 0.5)].map { $0.cgColor }
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let locations:[CGFloat] = [0.0, 1.0]
//        if let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) {
//            context.saveGState()
//            shadowPath.addClip() // Clipping the path for the gradient to apply within
//            
//            for index in 0..<shadowPoints.count-1 {
//                let start = shadowPoints[index]
//                let end = shadowPoints[index+1]
//                context2.drawLinearGradient(gradient, start: start, end: end, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
//            }
//            
//            context.restoreGState()
//        }
        
//        context2.setStrokeColor(UIColor.yellow.cgColor)
//        shadowPath.stroke()
        
        var shadowPoints2 = [CGPoint]()
//        if let rightMostPoint = outerRightMostPoints.first {
//            shadowPoints2.append(rightMostPoint)
//        }
        let shadowTopMostPoints = outerTopMostPoints.reversed()
        shadowPoints2.append(contentsOf: shadowTopMostPoints)
        //avoid overlapping points
//        let maxY: CGFloat = shadowTopMostPoints.max { p1, p2 in
//            p1.y < p2.y
//        }?.y ?? 0
        let shadowLeftMostPoints = outerLeftMostPoints.reversed()/*.filter {
            $0.y > maxY
        }*/
        shadowPoints2.append(contentsOf: shadowLeftMostPoints)
        
//        if let bottomMostPoint = outerBottomMostPoints.last {
//            shadowPoints2.append(bottomMostPoint)
//            shadowPoints2.append(CGPointMake(bottomMostPoint.x, bottomMostPoint.y - shadowOffsetTL))
//        }
        let shadowLeftLeastPoints = shadowLeftMostPoints.reversed().map { return CGPoint(x: $0.x + shadowOffsetTL, y: $0.y) }
        shadowPoints2.append(contentsOf: shadowLeftLeastPoints)
        //avoid overlapping points
//        let maxX: CGFloat = shadowLeftLeastPoints.max { p1, p2 in
//            p1.x < p2.x
//        }?.x ?? 0
        let shadowTopLeastPoints = shadowTopMostPoints.reversed().map { return CGPoint(x: $0.x, y: $0.y + shadowOffsetTL) }/*.filter { p in
            p.x > maxX
        }*/
        shadowPoints2.append(contentsOf: shadowTopLeastPoints)
//        if let rightMostPoint = outerRightMostPoints.first {
//            shadowPoints2.append(CGPointMake(rightMostPoint.x, rightMostPoint.y + shadowOffsetTL))
//        }
//        let originTL = blur - shadowOffsetTL
//        shadowPoints2 = shadowPoints2.map({ pt in
//            CGPoint(x: pt.x + originTL / 2, y: pt.y + originTL / 2)
//        })
        let shadowPath2 = createBezierPath(from: shadowPoints2)
        shadowPath2.lineWidth = 2
        shadowPath2.lineCapStyle = .round
        shadowPath2.lineJoinStyle = .round
//        shadowPath2.close()
        context2.setFillColor(customShadowColor.cgColor)
        shadowPath2.fill()
//        context2.setStrokeColor(UIColor.systemPink.cgColor)
//        shadowPath2.stroke()
        
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func pixelScale() -> Int {
        return Int(ceil(size.width / 1000.0))
    }
    
    private func pixelMappingStep() -> Int {
        return 1 * pixelScale()
    }
    
    private func nonTransparentPoints() -> [CGPoint] {
        guard let cgImage = self.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height
        var nonTransparentPoints: [CGPoint] = []
        
        guard let dataProvider = cgImage.dataProvider else { return [] }
        guard let data = dataProvider.data else { return [] }
        let pixelData = CFDataGetBytePtr(data)
        let step = pixelMappingStep()
        for x in stride(from: 0, to: width, by: step) {
            autoreleasepool {
                var edgePoints: [CGPoint] = []
                for y in stride(from: 0, to: height, by: step) {
                    autoreleasepool {
                        let pixelInfo: Int = ((width * y) + x) * 4
                        
                        let alpha = pixelData?[pixelInfo + 3] ?? 0
                        if alpha != 0 { // Non-transparent pixel
                            edgePoints.append(CGPoint(x: x, y: y))
                        }
                    }
                }
                if edgePoints.count > 1 {
                    nonTransparentPoints.append(edgePoints.first!)
                    nonTransparentPoints.append(edgePoints.last!)
                }
            }
        }
        
        return nonTransparentPoints
    }
    
    private func nonTransparentPointsV2(blur: CGFloat) -> ([CGPoint], [CGPoint]) {
        guard let cgImage = cgImage else { return ([], []) }
        let width = cgImage.width
        let height = cgImage.height
        var nonTransparentPointsL: [CGPoint] = []
        var nonTransparentPointsR: [CGPoint] = []

        guard let dataProvider = cgImage.dataProvider else { return ([], []) }
        guard let data = dataProvider.data else { return ([], []) }
        let pixelData = CFDataGetBytePtr(data)
        let step = pixelMappingStep()
        for y in stride(from: 0, to: height, by: step) {
            autoreleasepool {
                var edgePoints: [CGPoint] = []
                for x in stride(from: 0, to: width, by: step) {
                    autoreleasepool {
                        let pixelInfo: Int = ((width * y) + x) * 4
                        let alpha = pixelData?[pixelInfo + 3] ?? 0
                        let r = pixelData?[pixelInfo + 0] ?? 0
                        let g = pixelData?[pixelInfo + 1] ?? 0
                        let b = pixelData?[pixelInfo + 2] ?? 0
                        if alpha > 0,
                           r > 0,
                           g > 0,
                           b > 0
                        {
                            edgePoints.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
                        }
                    }
                }
                if edgePoints.count > 1 {
                    var leftEdgePoint = edgePoints.first!
                    //origin
                    leftEdgePoint.x += blur
                    leftEdgePoint.y += blur
                    nonTransparentPointsL.append(leftEdgePoint)
                    
                    var rightEdgePoint = edgePoints.last!
                    //origin
                    rightEdgePoint.x += blur
                    rightEdgePoint.y += blur
                    nonTransparentPointsR.append(rightEdgePoint)
                }
            }
        }

        return (nonTransparentPointsL, nonTransparentPointsR)
    }
    
    /// return [leftPoints, rightPoints, topPoints, bottomPoints]
    private func nonTransparentPointsV3() -> ([CGPoint], [CGPoint], [CGPoint], [CGPoint]) {
        guard let cgImage = cgImage else { return ([], [], [], []) }
        let width = cgImage.width
        let height = cgImage.height
    
        guard let dataProvider = cgImage.dataProvider else { return ([], [], [], []) }
        guard let data = dataProvider.data else { return ([], [], [], []) }
        
        var nonTransparentPointsL: [CGPoint] = []
        var nonTransparentPointsR: [CGPoint] = []
        
        let pixelData = CFDataGetBytePtr(data)
        let step = pixelMappingStep()
        
        for y in stride(from: 0, to: height, by: step) {
            autoreleasepool {
                var edgePoints: [CGPoint] = []
                for x in stride(from: 0, to: width, by: step) {
                    autoreleasepool {
                        let pixelInfo: Int = ((width * y) + x) * 4
                        let alpha = pixelData?[pixelInfo + 3] ?? 0
                        let r = pixelData?[pixelInfo + 0] ?? 0
                        let g = pixelData?[pixelInfo + 1] ?? 0
                        let b = pixelData?[pixelInfo + 2] ?? 0
                        if alpha > 0,
                           r > 0,
                           g > 0,
                           b > 0
                        {
                            edgePoints.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
                        }
                    }
                }
                if edgePoints.count > 1 {
                    let leftEdgePoint = edgePoints.first!
                    nonTransparentPointsL.append(leftEdgePoint)
                    
                    let rightEdgePoint = edgePoints.last!
                    nonTransparentPointsR.append(rightEdgePoint)
                }
            }
        }
        
        var nonTransparentPointsT: [CGPoint] = []
        var nonTransparentPointsB: [CGPoint] = []
        
        for x in stride(from: 0, to: width, by: step) {
            autoreleasepool {
                var edgePoints: [CGPoint] = []
                for y in stride(from: 0, to: height, by: step) {
                    autoreleasepool {
                        let pixelInfo: Int = ((width * y) + x) * 4
                        let alpha = pixelData?[pixelInfo + 3] ?? 0
                        let r = pixelData?[pixelInfo + 0] ?? 0
                        let g = pixelData?[pixelInfo + 1] ?? 0
                        let b = pixelData?[pixelInfo + 2] ?? 0
                        if alpha > 0,
                           r > 0,
                           g > 0,
                           b > 0
                        {
                            edgePoints.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
                        }
                    }
                }
                if edgePoints.count > 1 {
                    let topEdgePoint = edgePoints.first!
                    nonTransparentPointsT.append(topEdgePoint)
                    
                    let bottomEdgePoint = edgePoints.last!
                    nonTransparentPointsB.append(bottomEdgePoint)
                }
            }
        }

        return (nonTransparentPointsL, nonTransparentPointsR, nonTransparentPointsT, nonTransparentPointsB)
    }
    
    private func nonTransparentEdgePoints() -> [CGPoint] {
        let points = nonTransparentPointsV3()
        var edgePoints = [CGPoint]()
        edgePoints.append(contentsOf: points.0)
        edgePoints.append(contentsOf: points.1)
        edgePoints.append(contentsOf: points.2)
        edgePoints.append(contentsOf: points.3)
        return edgePoints
    }
    
    // The smaller, the smoother, but left more blank; too bigger may cause overlapping points
    private func antiAliasing() -> CGFloat {
        return 10//10//test
    }
    
    // The bigger, the smoother, but cost more times
    private func edgePointsNum() -> Int {
        return 100//test
    }
    
    private func topMostPoints(points: [CGPoint], count: Int, blur: CGFloat) -> [CGPoint] {
        var finalPoints = [CGPoint]()
        let pixelStep = pixelMappingStep()
        let step = pixelStep
        var last: CGPoint?// ensure smooth curve
        for i in 0..<count {
            autoreleasepool {
                let origin = CGPoint(x: size.width / CGFloat(count) * CGFloat(i), y: 0)
                var fileter: [CGPoint]
                if let last {
                    fileter = points.filter {
                        abs($0.x - origin.x) < CGFloat(step) && abs($0.y - last.y) < CGFloat(pixelStep) * antiAliasing()
                    }
                } else {
                    fileter = points.filter {
                        abs($0.x - origin.x) < CGFloat(step)
                    }
                }
                if fileter.count == 0 {//fallback
                    fileter = points
                }
                var pt = fileter.min { p1, p2 in
                    let d1 = distanceBetweenPoints(point1: origin, point2: p1)
                    let d2 = distanceBetweenPoints(point1: origin, point2: p2)
                    return d1 < d2
                } ?? .zero
                let same = finalPoints.first { $0.x - blur == pt.x }
                if same == nil {// filter to have only 1 points
                    last = CGPoint(x: pt.x, y: pt.y)
                    pt.y -= blur
                    //origin
                    pt.x += blur
                    pt.y += blur
                    finalPoints.append(pt)
                }
            }
        }
        return finalPoints
    }
    
    private func rightMostPoints(points: [CGPoint], count: Int, blur: CGFloat) -> [CGPoint] {
        var finalPoints = [CGPoint]()
        let pixelStep = pixelMappingStep()
        let step = pixelStep
        var last: CGPoint?// ensure smooth curve
        for i in 0..<count {
            autoreleasepool {
                let origin = CGPoint(x: size.width, y: size.height / CGFloat(count) * CGFloat(i))
                var fileter: [CGPoint]
                if let last {
                    fileter = points.filter {
                        abs($0.y - origin.y) < CGFloat(step) && abs($0.x - last.x) < CGFloat(pixelStep) * antiAliasing()
                    }
                } else {
                    fileter = points.filter {
                        abs($0.y - origin.y) < CGFloat(step)
                    }
                }
                if fileter.count == 0 {//fallback
                    fileter = points
                }
                var pt: CGPoint = fileter.min { p1, p2 in
                    let d1 = distanceBetweenPoints(point1: origin, point2: p1)
                    let d2 = distanceBetweenPoints(point1: origin, point2: p2)
                    return d1 < d2
                } ?? .zero
                let same = finalPoints.first { $0.x - 2 * blur == pt.x }
                if same == nil {// filter to have only 1 points
                    last = CGPoint(x: pt.x, y: pt.y)
                    pt.x += blur
                    //origin
                    pt.x += blur
                    pt.y += blur
                    finalPoints.append(pt)
                }
            }
        }
        return finalPoints
    }
    
    private func bottomMostPoints(points: [CGPoint], count: Int, blur: CGFloat) -> [CGPoint] {
        var finalPoints = [CGPoint]()
        let pixelStep = pixelMappingStep()
        let step = pixelStep
        var last: CGPoint?// ensure smooth curve
        for i in 0..<count {
            autoreleasepool {
                let origin = CGPoint(x: size.width / CGFloat(count) * CGFloat(count - i), y: size.height)
                var fileter: [CGPoint]
                if let last {
                    fileter = points.filter {
                        abs($0.x - origin.x) < CGFloat(step) && abs($0.y - last.y) < CGFloat(pixelStep) * antiAliasing()
                    }
                } else {
                    fileter = points.filter {
                        abs($0.x - origin.x) < CGFloat(step)
                    }
                }
                if fileter.count == 0 {//fallback
                    fileter = points
                }
                var pt = fileter.min { p1, p2 in
                    let d1 = distanceBetweenPoints(point1: origin, point2: p1)
                    let d2 = distanceBetweenPoints(point1: origin, point2: p2)
                    return d1 < d2
                } ?? .zero
                let same = finalPoints.first { $0.x - blur == pt.x }
                if same == nil {// filter to have only 1 points
                    last = CGPoint(x: pt.x, y: pt.y)
                    pt.y += blur
                    //origin
                    pt.x += blur
                    pt.y += blur
                    finalPoints.append(pt)
                }
            }
        }
        return finalPoints
    }
    
    private func leftMostPoints(points: [CGPoint], count: Int, blur: CGFloat) -> [CGPoint] {
        var finalPoints = [CGPoint]()
        let pixelStep = pixelMappingStep()
        let step = pixelStep
        var last: CGPoint?// ensure smooth curve
        for i in 0..<count {
            autoreleasepool {
                let origin = CGPoint(x: 0, y: size.height / CGFloat(count) * CGFloat(count - i))
                var fileter: [CGPoint]
                if let last {
                    fileter = points.filter {
                        abs($0.y - origin.y) < CGFloat(step) && abs($0.x - last.x) < CGFloat(pixelStep) * antiAliasing()
                    }
                } else {
                    fileter = points.filter {
                        abs($0.y - origin.y) < CGFloat(step)
                    }
                }
                if fileter.count == 0 {//fallback
                    fileter = points
                }
                var pt = fileter.min { p1, p2 in
                    let d1 = distanceBetweenPoints(point1: origin, point2: p1)
                    let d2 = distanceBetweenPoints(point1: origin, point2: p2)
                    return d1 < d2
                } ?? .zero
                let same = finalPoints.first { $0.x - 2 * blur == pt.x }
                if same == nil {// filter to have only 1 points
                    last = CGPoint(x: pt.x, y: pt.y)
                    pt.x -= blur
                    //origin
                    pt.x += blur
                    pt.y += blur
                    finalPoints.append(pt)
                }
            }
        }
        return finalPoints
    }
    
    private func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx*dx + dy*dy)
    }
    
    private func createBezierPath(from points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard let firstPoint = points.first else { return path }
        
        path.move(to: firstPoint)
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

extension UIImage {
    
    // https://www.kodeco.com/25658084-core-image-tutorial-for-ios-custom-filters
    // https://developer.apple.com/documentation/coreimage/cifilter/3228321-edgesfilter
    // https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html

    func detectEdges() -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        //CIEdges/CIEdgeWork
        if let filter = CIFilter(name: "CIEdges") { // You can experiment with different filters for better results
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(NSNumber(value: 20.0), forKey: "inputIntensity") // Adjust this value based on your needs
//            filter.setValue(NSNumber(value: 20.0), forKey: "inputRadius") // Adjust this value based on your needs
            let context = CIContext(options: nil)
            if let outputImage = filter.outputImage,
               let cgImageResult = context.createCGImage(outputImage, from: ciImage.extent) {
                return UIImage(cgImage: cgImageResult)
            }
        }
        return nil
    }
}

extension UIImage {
    func imageByApplyingClippingBezierPath(_ path: UIBezierPath) -> UIImage? {
        // Mask image using path
        guard let maskedImage = imageByApplyingMaskingBezierPath(path) else { return nil }
        
        // Crop image to frame of path
        let croppedImage = UIImage(cgImage: maskedImage.cgImage!.cropping(to: path.bounds)!)
        
        return croppedImage
    }
    
    func imageByApplyingMaskingBezierPath(_ path: UIBezierPath) -> UIImage? {
        // Define graphic context (canvas) to paint on
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        // Set the clipping mask
        path.addClip()
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        guard let maskedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    func clip(_ path: UIBezierPath) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        self.draw(in: frame)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// Helper functions.
extension UIImage {
    /**
     Replaces a color in the image with a different color.
     - Parameter color: color to be replaced.
     - Parameter with: the new color to be used.
     - Parameter tolerance: tolerance, between 0 and 1. 0 won't change any colors,
     1 will change all of them. 0.5 is default.
     - Returns: image with the replaced color.
     */
    @objc func replaceColor(_ color: UIColor, with: UIColor, tolerance: CGFloat = 0.5) -> UIImage {
        guard let imageRef = self.cgImage else {
            return self
        }
        // Get color components from replacement color
        let withColorComponents = with.cgColor.components
        let newRed = UInt8(withColorComponents![0] * 255)
        let newGreen = UInt8(withColorComponents![1] * 255)
        let newBlue = UInt8(withColorComponents![2] * 255)
        let newAlpha = UInt8(withColorComponents![3] * 255)
        
        let width = imageRef.width
        let height = imageRef.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitmapByteCount = bytesPerRow * height
        
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        defer {
            rawData.deallocate()
        }
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear) else {
            return self
        }
        
        guard let context = CGContext(
            data: rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return self
        }
        
        let rc = CGRect(x: 0, y: 0, width: width, height: height)
        // Draw source image on created context.
        context.draw(imageRef, in: rc)
        var byteIndex = 0
        // Iterate through pixels
        while byteIndex < bitmapByteCount {
            // Get color of current pixel
            let red = CGFloat(rawData[byteIndex + 0]) / 255
            let green = CGFloat(rawData[byteIndex + 1]) / 255
            let blue = CGFloat(rawData[byteIndex + 2]) / 255
            let alpha = CGFloat(rawData[byteIndex + 3]) / 255
            let currentColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            // Replace pixel if the color is close enough to the color being replaced.
            if compareColor(firstColor: color, secondColor: currentColor, tolerance: tolerance) {
                rawData[byteIndex + 0] = newRed
                rawData[byteIndex + 1] = newGreen
                rawData[byteIndex + 2] = newBlue
                rawData[byteIndex + 3] = newAlpha
            }
            byteIndex += 4
        }
        
        // Retrieve image from memory context.
        guard let image = context.makeImage() else {
            return self
        }
        let result = UIImage(cgImage: image)
        return result
    }
    
    /**
     Check if two colors are the same (or close enough given the tolerance).
     - Parameter firstColor: first color used in the comparisson.
     - Parameter secondColor: second color used in the comparisson.
     - Parameter tolerance: how much variation can there be for the function to return true.
     0 is less sensitive (will always return false),
     1 is more sensitive (will always return true).
     */
    private func compareColor(
        firstColor: UIColor,
        secondColor: UIColor,
        tolerance: CGFloat
    ) -> Bool {
        var r1: CGFloat = 0.0, g1: CGFloat = 0.0, b1: CGFloat = 0.0, a1: CGFloat = 0.0;
        var r2: CGFloat = 0.0, g2: CGFloat = 0.0, b2: CGFloat = 0.0, a2: CGFloat = 0.0;
        
        firstColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        secondColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return abs(r1 - r2) <= tolerance
        && abs(g1 - g2) <= tolerance
        && abs(b1 - b2) <= tolerance
        && abs(a1 - a2) <= tolerance
    }
    
}
