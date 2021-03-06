//
//  GraphView.swift
//  Calculator

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var yForX: (( _ x: Double) -> Double?)? { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    var originRelativeToCenter = CGPoint.zero  { didSet { setNeedsDisplay() } }
 
    private var graphCenter: CGPoint {
        return convert(center, from: superview)
    }
   private  var origin: CGPoint  {
        get {
            var origin = originRelativeToCenter
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        }
        set {
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originRelativeToCenter = origin
        }
    }

    private let axesDrawer = AxesDrawer(color: UIColor.blue)
    
    private var lightCurve:Bool = false // рисуем график

    
    override func draw(_ rect: CGRect) {
        axesDrawer.contentScaleFactor = contentScaleFactor
        axesDrawer.drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
         if !lightCurve {
            drawCurveInRect(bounds, origin: origin, scale: scale)}
    }
    
    func drawCurveInRect(_ bounds: CGRect, origin: CGPoint, scale: CGFloat){
        color.set()
        var xGraph, yGraph :CGFloat
        
        var x: Double {return Double ((xGraph - origin.x) / scale)}
        
        // ---Разрывные точки----
        var oldPoint = OldPoint (yGraph: 0.0, normal: false)
        var disContinuity:Bool {
            return abs( yGraph - oldPoint.yGraph) >
                                           max(bounds.width, bounds.height) * 1.5}
        //-----------------------
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        
        for i in 0...Int(bounds.size.width * contentScaleFactor){
            
            xGraph = CGFloat(i) / contentScaleFactor
            
            guard let y = (yForX)?(x), y.isFinite
                                          else { oldPoint.normal = false;  continue}
            yGraph = origin.y - CGFloat(y) * scale
            
            if !oldPoint.normal{
                path.move(to: CGPoint(x: xGraph, y: yGraph))
            } else {
                guard !disContinuity else {
                                oldPoint =  OldPoint ( yGraph: yGraph, normal: false)
                                continue }
                path.addLine(to: CGPoint(x: xGraph, y: yGraph))
            }
            oldPoint =  OldPoint (yGraph: yGraph, normal: true)
        }
        path.stroke()
    }
    
    private struct OldPoint {
        var yGraph: CGFloat
        var normal: Bool
    }
    
    private var snapshot:UIView?
/*
//     Оригинальный вариант без "замороженного" снимка
    func scale(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }*/
    
//     Вариант с "замороженным" снимком
   
    func scale(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            
            snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
            
        case .changed:
            let touch = CGPoint (x:graphCenter.x + originRelativeToCenter.x,
                                 y:graphCenter.y + originRelativeToCenter.y)
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale +
                (1 - gesture.scale) * touch.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale +
                (1 - gesture.scale) * touch.y
            gesture.scale = 1.0
            
        case .ended:
            let changedScale = snapshot!.frame.height / self.frame.height
            scale *= changedScale
            
            snapshot!.removeFromSuperview()
            snapshot = nil
            setNeedsDisplay()
            
        default: break
        }
    }

/*
//     Оригинальный вариант без "замороженного" снимка
     
    func originMove(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended: fallthrough
        case .changed:
            let translation = gesture.translation(in: self)
            if translation != CGPoint.zero {
                origin.x += translation.x
                origin.y += translation.y
                gesture.setTranslation(CGPoint.zero, in: self)
            }
        default: break
        }
    }
 
 */
     //     Вариант с "замороженным" снимком

    func originMove(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            lightCurve = true
            snapshot = self.snapshotView(afterScreenUpdates: false)
            snapshot!.alpha = 0.6
            
            self.addSubview(snapshot!)
        case .changed:
            let translation = gesture.translation(in: self)
            if translation != CGPoint.zero {
                   snapshot!.center.x += translation.x   // можно двигать
                   snapshot!.center.y += translation.y   // только снимок
              //  origin.x += translation.x
              //  origin.y += translation.y
                gesture.setTranslation(CGPoint.zero, in: self)
            }
        case .ended:
            origin.x += snapshot!.frame.origin.x
            origin.y += snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil
            lightCurve = false
            setNeedsDisplay()
        default: break
        }
    }

    func origin(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            origin = gesture.location(in: self)
        }
    }

}
