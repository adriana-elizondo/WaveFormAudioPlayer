//
//  WaveFormAudioPLayer.swift
//  WaveFormAudioPLayer
//
//  Created by Adriana Elizondo on 2019/2/13.
//  Copyright © 2019 adriana. All rights reserved.
//

import Foundation
import UIKit
import AVKit

let kWidth :CGFloat = 3
let kPadding : CGFloat = 8
let kDefaultBars  = 3

public class WaveFormView: UIView{
    private var bars = [CALayer]()
    private var displayLink: CADisplayLink?
    private var currentAmplitude: Float = 0
    private var audioPlayer : AVAudioPlayer?
    private var padding = kPadding
    
    var barColor = UIColor.white
    
    override public func awakeFromNib() {
        displayLink = CADisplayLink(target: self, selector: #selector(animateBars))
        displayLink?.add(to: RunLoop.main, forMode: .default)
    }
    
    private func setUp(withBars numberOfBars: Int){
        let pointY = frame.size.height / 2
        padding = ((bounds.size.width / CGFloat(numberOfBars)) - kWidth)
        
        for i in 1...numberOfBars{
            let bar = CALayer()
            let positionX = (CGFloat(i) * kWidth) + (CGFloat(i) * padding)
            
            bar.frame = CGRect(x: positionX, y: pointY, width: kWidth, height: 1)
            
            bar.backgroundColor = barColor.cgColor
            layer.addSublayer(bar)
            bars.append(bar)
        }
        
        center = superview?.center ?? .zero
    }
    
    public func setUpPlayer(withAudioFile urlToFile: URL, playAutomatically: Bool, numberOfBars: Int = 0) throws{
        audioPlayer = try AVAudioPlayer(contentsOf: urlToFile)
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.prepareToPlay()
        
        let defaultBars = numberOfBars > 0 ? numberOfBars : Int(bounds.size.width / kPadding)
        setUp(withBars: defaultBars)
        
        guard playAutomatically else {return}
        audioPlayer?.play()
    }
    
    public func play(){
        audioPlayer?.play()
    }
    
    public func stop(){
        audioPlayer?.stop()
    }
    
    @objc private func animateBars(){
        calculateCurrentPeakLevel()
        currentAmplitude = currentAmplitude > -1 ? currentAmplitude : 0
        
        let maxHeight = bounds.size.height
        
        for bar in bars{
            var previousBounds = bar.bounds
            let barHeight = (currentAmplitude * Float(arc4random() % UInt32(bounds.size.height)))
            let newHeight = min(barHeight, (Float(maxHeight)))
            previousBounds.size.height = CGFloat(newHeight / 2)
            bar.bounds = previousBounds
        }
        
    }
    
    private func calculateCurrentPeakLevel(){
        audioPlayer?.updateMeters()
        let peak = audioPlayer?.peakPower(forChannel: 0)
        let amplitude = pow(10, (peak! / 20)) * 12
        currentAmplitude = amplitude
    }
    
}
