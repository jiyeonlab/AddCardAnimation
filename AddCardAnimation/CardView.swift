//
//  CardView.swift
//  AddCardAnimation
//
//  Created by JiyeonKim on 30/09/2019.
//  Copyright © 2019 JiyeonKim. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var isFaceUp: Bool = false { didSet {setNeedsDisplay(); setNeedsLayout()}}
    var symbol = Card.Symbol.squiggle { didSet {setNeedsDisplay()} }
    var color = Card.Color.red { didSet {setNeedsDisplay()} }
    var count = Card.Count.one.rawValue { didSet {setNeedsDisplay()} }
    var opacity = Card.Opacity.solid { didSet {setNeedsDisplay()} }
    
    init(rect: CGRect) {
        super.init(frame: rect)
        
        // 카드의 처음은 뒷면으로 설정하기 위함.
        backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        alpha = 0.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // set white background
        // UIGraphicGetCurrentContext는 CGContext를 반환하는데, CGContext는 2D의 드로잉 환경을 말한다.
        guard let graphicsContext = UIGraphicsGetCurrentContext() else {
            print("unable to get graphics context in drawBackground()")
            return
        }

        if isFaceUp {
            Color.cardViewBGColor.setFill()
            graphicsContext.fill(bounds)

            let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            roundedRect.addClip()

            UIColor.white.setFill()
            roundedRect.fill()

            // 카드에 들어갈 각종 property를 매칭하고, 그려주기.
            drawSymbol()
        }
    }
    
    private func drawSymbol() {
        
        var path = UIBezierPath()
        
        switch symbol{
        case .squiggle:
            path = drawSquiggle(number: count)
        case .diamond:
            path = drawDiamond(number: count)
        case .oval:
            path = drawOval(number: count)
        }
        
        switch opacity {
        case .solid:
            drawSolid(draw: path, fill: color)
        case .unfilled:
            drawUnfilled(draw: path, line: color)
        case .striped:
            drawStriped(draw: path, stripe: color)
            
        }
        
    }
    
    private func drawSquiggle(number count: Int) -> UIBezierPath {
        
        let squigglePath = UIBezierPath()
        let allSquiggleWidth = ( symbolWidth * CGFloat(count + 1) )
        
        let drawingBoxOriginX = (bounds.width - allSquiggleWidth) / 2
        var startPoint = drawingBoxOriginX
        
        for i in 0..<count+1{
            
            squigglePath.move(to: CGPoint(x: startPoint, y: yOffset))
            squigglePath.addLine(to: CGPoint(x: startPoint+symbolWidth, y:yOffset))
            squigglePath.addCurve(to: CGPoint(x: startPoint+symbolWidth, y: bounds.midY), controlPoint1: CGPoint(x:startPoint+symbolWidth-(symbolWidth/3.0), y: yOffset + (yOffset/2.0)), controlPoint2: CGPoint(x:startPoint+symbolWidth-(symbolWidth/3.0), y: yOffset + (yOffset/2.0)))
            squigglePath.addCurve(to: CGPoint(x: startPoint+symbolWidth, y: bounds.maxY-yOffset), controlPoint1: CGPoint(x: startPoint + symbolWidth + (symbolWidth/3.0), y: bounds.maxY - yOffset - (yOffset/2)), controlPoint2: CGPoint(x: startPoint + symbolWidth + (symbolWidth/3.0), y: bounds.maxY - yOffset - (yOffset/2)))
            squigglePath.addLine(to: CGPoint(x: startPoint, y: bounds.maxY-yOffset))
            squigglePath.addCurve(to: CGPoint(x: startPoint, y: bounds.midY), controlPoint1: CGPoint(x: startPoint + (symbolWidth/3.0), y: bounds.midY + (yOffset/2)), controlPoint2: CGPoint(x: startPoint + (symbolWidth/3.0), y: bounds.midY + (yOffset/2)))
            squigglePath.addCurve(to: CGPoint(x:startPoint, y:yOffset), controlPoint1: CGPoint(x: startPoint - (symbolWidth/3.0), y: yOffset + (yOffset / 2.0)), controlPoint2: CGPoint(x: startPoint - (symbolWidth/3.0), y: yOffset + (yOffset / 2.0)))
            
            //startPoint = drawingBoxOriginX + ((symbolWidth + betweenMargin) * CGFloat(i) )
            
            if i == 0 {
                startPoint = drawingBoxOriginX + symbolWidth + betweenMargin
            }else if i == 1{
                startPoint = drawingBoxOriginX + symbolWidth + symbolWidth + betweenMargin + betweenMargin
            }
            
        }
        
        return squigglePath
    }
    
    private func drawDiamond(number count: Int) -> UIBezierPath {
        
        //print("count : \(count+1), color : \(color)")
        let diamondPath = UIBezierPath()
        let allDiamondWidth = ( symbolWidth * CGFloat(count + 1) )
        let drawingBoxOriginX = (bounds.width - allDiamondWidth) / 2
        
        let diamondRadius = allDiamondWidth / CGFloat((count+1) * 2)
        var startPoint = drawingBoxOriginX + diamondRadius
        
        for i in 0..<count+1{
            diamondPath.move(to: CGPoint(x: startPoint, y: yOffset))
            diamondPath.addLine(to: CGPoint(x: startPoint + diamondRadius, y: bounds.midY))
            diamondPath.addLine(to: CGPoint(x: startPoint, y: bounds.maxY - yOffset))
            diamondPath.addLine(to: CGPoint(x: startPoint - diamondRadius, y: bounds.midY))
            diamondPath.close()
            
            if i == 0 {
                startPoint = drawingBoxOriginX + (diamondRadius * 3.0)
            }else if i == 1{
                startPoint = drawingBoxOriginX + (diamondRadius * 5.0)
            }
        }
        return diamondPath
    }
    
    private func drawOval(number count: Int) -> UIBezierPath {
        
        //print("count : \(count+1), color : \(color)")
        
        let allOvalWidth = ( symbolWidth * CGFloat(count + 1) )
        let drawingBoxOriginX = (bounds.width - allOvalWidth) / 2
        var startPoint = drawingBoxOriginX
        
        var ovalPath = UIBezierPath()
        let nextOvalPath = UIBezierPath()
        
        for i in 0..<count+1{
            
            ovalPath = UIBezierPath(ovalIn: CGRect(x: startPoint, y: yOffset, width: symbolWidth*0.9, height: (bounds.height/2)))
            
            nextOvalPath.append(ovalPath)
            
            if i == 0 {
                startPoint = drawingBoxOriginX + (symbolWidth * 1.0) + (betweenMargin * 0.5)
            }else if i == 1 {
                startPoint = drawingBoxOriginX + (symbolWidth * 2.0) + betweenMargin
            }
        }
        
        return nextOvalPath
    }
    
    private func drawSolid(draw path:UIBezierPath, fill color:Card.Color) {
        switch color {
        case .red:
            Color.customRedColor.setFill()
            path.fill()
        case .green:
            Color.customGreenColor.setFill()
            path.fill()
        case .purple:
            Color.customPurpleColor.setFill()
            path.fill()
        }
    }
    private func drawUnfilled(draw path: UIBezierPath, line color:Card.Color){
        switch color {
        case .red:
            Color.customRedColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        case .green:
            Color.customGreenColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        case .purple:
            Color.customPurpleColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        }
    }
    private func drawStriped(draw path: UIBezierPath, stripe color:Card.Color){
        
        switch color {
        case .red:
            Color.customRedColor.setStroke()
            stripedDraw(draw: path)
            
        case .green:
            Color.customGreenColor.setStroke()
            stripedDraw(draw: path)
            
        case .purple:
            Color.customPurpleColor.setStroke()
            stripedDraw(draw: path)
            
        }
    }
    
    private func stripedDraw(draw path: UIBezierPath) {
        
        path.lineWidth = 1.0
        path.stroke()
        path.addClip()
        
        let stripePath = UIBezierPath()
        stripePath.lineWidth = 0.5
        
        var currentPoint:CGFloat = 0
        
        while currentPoint < bounds.size.width {
            stripePath.move(to: CGPoint(x: currentPoint, y:0))
            stripePath.addLine(to: CGPoint(x:currentPoint, y:bounds.maxY))
            
            currentPoint += 3.0
            stripePath.stroke()
        }
        
        stripePath.stroke()
    }
    
}

extension CardView {
    private struct Color {
        static let cardViewBGColor: UIColor = #colorLiteral(red: 0.8897153139, green: 0.8897153139, blue: 0.8897153139, alpha: 1)
        static let customRedColor: UIColor = #colorLiteral(red: 0.9973127246, green: 0.2724514008, blue: 0.2957524061, alpha: 1)
        static let customGreenColor: UIColor = #colorLiteral(red: 0.286074996, green: 0.6784440279, blue: 0.3235504627, alpha: 1)
        static let customPurpleColor: UIColor = #colorLiteral(red: 0.34546718, green: 0.1469219327, blue: 1, alpha: 1)
    }
    private var betweenMargin: CGFloat {
        return (bounds.size.width * 0.05)
    }
    
    private var drawingBoxWidth: CGFloat {
        return (bounds.size.width / 2)
    }
    private var drawingBoxHeight: CGFloat {
        return (bounds.size.height / 2)
    }
    private var symbolWidth: CGFloat {
        return ((bounds.size.width - (betweenMargin * 2)) / 5)
    }
    private var yOffset: CGFloat {
        return (bounds.height / 4.0)
    }
    
    private var cornerRadius: CGFloat {
        return (bounds.size.height * 0.17)
    }
    
}

