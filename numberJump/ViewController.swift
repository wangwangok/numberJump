//
//  ViewController.swift
//  numberJump
//
//  Created by 王望 on 15/9/18.
//  Copyright (c) 2015年 王望. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var label: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func start(sender: AnyObject) {
    label.jumpNumberWithDuration(60.0, from: 60, to: 0)
  }
  
}

extension UILabel {
  
  func jumpNumberWithDuration(duration: Double, from startNumber: Double, to endNumber:Double) {
    text = String(format: "%.2f", startNumber)
    
    struct BezierPoint {
      var x = 0.0
      var y = 0.0
    }
    
    /*t 为参数值，0 <= t <= 1 */
    func pointOnCubicBezier(t: Double) -> BezierPoint {
      
      /* bezierCurvePoints 在此是四个元素的数组:
      bezierCurvePoints[0] 为起点，或上图中的 P0
      bezierCurvePoints[1] 为第一控制点，或上图中的 P1
      bezierCurvePoints[2] 为第二控制点，或上图中的 P2
      bezierCurvePoints[3] 为结束点，或上图中的 P3 */
      let bezierPoints = [BezierPoint(x: 0, y: 0), BezierPoint(x: 0, y: 0), BezierPoint(x: 1, y: 1), BezierPoint(x: 1, y: 1)] //liner
      var ax, bx, cx: Double
      var ay, by, cy: Double
      var tSquared, tCubed: Double
      var result = BezierPoint()
      
      cx = 3.0 * (bezierPoints[1].x - bezierPoints[0].x)
      bx = 3.0 * (bezierPoints[2].x - bezierPoints[1].x) - cx
      ax = bezierPoints[3].x - bezierPoints[0].x - cx - bx
      
      cy = 3.0 * (bezierPoints[1].y - bezierPoints[0].y)
      by = 3.0 * (bezierPoints[2].y - bezierPoints[1].y) - cy
      ay = bezierPoints[3].y - bezierPoints[0].y - cy - by
      
      tSquared = t * t
      tCubed   = tSquared * t
      
      result.x = (ax * tCubed) + (bx * tSquared) + (cx * t) + bezierPoints[0].x
      result.y = (ay * tCubed) + (by * tSquared) + (cy * t) + bezierPoints[0].y
      
      return result;
    }
    
    dispatch_async(dispatch_queue_create("com.hexintong.public.lableExtension", nil)) { [unowned self] () -> Void in
      let kPointsNumber = Int(duration * 20)     // 平均每秒跳20次
      var lastTime      = 0.0
      var indexNumber   = 0
      var timeDuration  = 0.0
      
      //记录每次UIlabel更改值的间隔时间及输出值。
      var numberPoints: [[Double]] = {
        var tempPoints = [[Double]]()
        let dt = 1.0 / Double(kPointsNumber - 1)
        for i in 0..<kPointsNumber {
          let point = pointOnCubicBezier(Double(i) * dt)
          let durationTime = point.x * duration
          let value = point.y * (endNumber - startNumber) + startNumber
          tempPoints += [[durationTime, value]]
        }
        return tempPoints
      }()
      
      while indexNumber < kPointsNumber {
        let pointValues = numberPoints[indexNumber]
        indexNumber++
        let value = pointValues[1]
        let currentTime = pointValues[0]
        timeDuration = currentTime - lastTime
        lastTime = currentTime
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          self.text = String(format: "%.0f秒", value)
        }
        NSThread.sleepForTimeInterval(timeDuration)
      }
      
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        self.text = String(format: "%.0f秒", endNumber)
      }
    }
  }
}

