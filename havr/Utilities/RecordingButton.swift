//
//  RecordingButton.swift
//  havr
//
//  Created by Personal on 8/25/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
protocol RecordingButtonDelegate: class {
    func recordingButton(sender: RecordingButton,touches: Set<UITouch>, with event: UIEvent?)
}

class RecordingButton: UIButton {
    
    weak var delegate: RecordingButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setup() {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.recordingButton(sender: self, touches: touches, with: event)
    }
}
