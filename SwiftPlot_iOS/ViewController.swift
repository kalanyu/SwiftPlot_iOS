//
//  ViewController.swift
//  SwiftPlot_iOS
//
//  Created by Kalanyu Zintus-art on 1/5/16.
//  Copyright © 2016 Koikelab. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSSPlashViewDelegate, TPHEMGSensorDelegate {

    private var sensorModule = TPHEMGSensor()
    private var jointEstimator = KLJointAngleEstimator()
    
    private var jointStiffness : Double = 0
    private var jointAngle : Double = 0
    

    @IBOutlet weak var angleValueView: CountView! {
        didSet {
            angleValueView.title = "Joint Angle"
        }
    }
    @IBOutlet weak var stiffnessView: GuageView! {
        didSet {
            stiffnessView.threshold = 1
            stiffnessView.lowThreshold = 0.4
            stiffnessView.title = "Joint Stiffness"
        }
    }
    //TODO: make this setup able when used in code
    @IBOutlet weak var graphView: SRPlotView! {
        didSet {
            graphView.title = "Filtered EMG Signals"
            graphView.totalSecondsToDisplay = 10.0
            graphView.totalChannelsToDisplay = 6
            //axe padding
            graphView.samplingRate = 60
            
            graphView.yTicks[0] = "Flexor 1"
            graphView.yTicks[1] = "Flexor 2"
            graphView.yTicks[2] = "Flexor 3"
            graphView.yTicks[3] = "Extensor 1"
            graphView.yTicks[4] = "Extensor 2"
            graphView.yTicks[5] = "Extensor 3"
        }
    }
    
    var count = 0
    
    @IBOutlet weak var backgroundView: NSSpashBGView! {
        didSet {
            backgroundView.initLayers()
            backgroundView.delegate = self
        }
    }
    
    private var anotherDataTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        anotherDataTimer = NSTimer(timeInterval:1/60, target: self, selector: "addData2", userInfo: nil, repeats: true)
//        NSRunLoop.currentRunLoop().addTimer(anotherDataTimer!, forMode: NSRunLoopCommonModes)
        // Do any additional setup after loading the view, typically from a nib.
        self.view.layer.backgroundColor = UIColor.redColor().CGColor
        
        sensorModule.delegate = self
        sensorModule.scanForRemoteSensor()
    }

//    override func viewDidLayoutSubviews() {
//        print(self.view.frame, graphView.frame, graphView.bounds, graphView.layer.frame, graphView.layer.bounds)
//    }
    
    func addData2() {
        
        let cgCount = Double(++count) * 1/60 % 1
        
        graphView.addData([cgCount, cgCount, cgCount, cgCount, cgCount , cgCount])
        stiffnessView.add(cgCount)
        
    }
    //MARK: Implementations
//    func systemStartup() {
//        loadingView.fade(toAlpha: 0)
//    }
    
    //MARK: NSSPlashViewDelegate
    func splashAnimationEnded(startedFrom from: SplashDirection) {
        //        switch self.mode {
        //        case .TV:
        //            tvIconView.fade(toAlpha: 1)
        //        case .Robot:
        //            kumamonIconView.fade(toAlpha: 1)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func TPHEMGSensorDidReceiveDataFromRemoteSensor(data: TPHData!) {
        let emgData : [Double] = [data.emgValue[0].doubleValue, data.emgValue[1].doubleValue, data.emgValue[2].doubleValue, data.emgValue[3].doubleValue, data.emgValue[4].doubleValue, data.emgValue[5].doubleValue]
        
        graphView.addData(emgData)
        
        jointStiffness = jointEstimator.calcStiffness(data.emgValueForJointEstimation)
        jointAngle = jointEstimator.calcEqPoint(data.emgValueForJointEstimation)
        dispatch_async(dispatch_get_main_queue(), {
            self.stiffnessView.add(self.jointStiffness)
            self.angleValueView.countText = String(format: "%.4f", self.jointAngle)
        })
        
        NSLog("Joint Stiffness: %f Angle: %f\n", jointStiffness, jointAngle)

        
        
    }
    
    func TPHEMGSensorDidUpdateADCSetting(setting: NSData!) {
        
    }
    
    func TPHEMGSensorDidUpdateConnectionState(connected: Bool) {
        
    }
    
    func TPHEMGSensorDidUpdateState() {
        
    }
    
    func TPHEMGSensorDidUpdateStatusMessage(status: String!) {
        
    }


}

