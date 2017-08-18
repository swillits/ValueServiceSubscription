//
//  PreviewWindowController.swift
//  ValueServiceSubscription
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa

class PreviewWindowController: NSWindowController, DrawingServiceSubscriber {
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("PreviewWindowController")
	}
	
	override func windowDidLoad() {
        super.windowDidLoad()
		drawingServiceDidChange()
    }
	
    
	@IBOutlet var previewView: PreviewView!
	
	var _drawingSubscription: Any?
	var _drawingService: DrawingService?
	
	
	func drawingServiceDidChange() {
		guard isWindowLoaded else { return }
		previewView.drawing = drawingService?.drawing
	}
	
	
	func drawing(_ drawing: Drawing, didChange change: DrawingChanges.ChangeKind, continuous: Bool) {
		guard isWindowLoaded else { return }
		if !continuous {
			previewView.drawing = drawing
		}
	}
}
