//
//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    var topColor = UIColor.white {
        didSet {
            self.updateColors()
        }
    }
    var bottomColor = UIColor.white.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
//    private let duration: TimeInterval
    private var hasDoneLayout = false // hacky way to prevent layouting again
    private var currentAnimationIndex = 0
    
    func setup(posts: [EventPost]) {
        self.segments.removeAll()
        for s in self.subviews {
            s.removeFromSuperview()
        }
        
        for p in posts {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            segment.duration = p.duration
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        
        self.updateColors()
        
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout || segments.count == 0 {
            return
        }
        
        hasDoneLayout = true
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        if segments.count == 0 { return }
        
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        let duration: TimeInterval = nextSegment.duration
        
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        }) { (finished) in
            if !finished {
                return
            }
            self.next()
        }
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            self.animate(animationIndex: newIndex)
        } else {
            self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    func skip() {
        if segments.count == 0 { return }
        
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        self.animate(animationIndex: newIndex)
    }
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    var duration: TimeInterval = 5
    init() {
    }
}