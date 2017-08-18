//
//  PreviewView.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa

class PreviewView: NSView {
	
	var drawing: Drawing? {
		didSet {
			needsDisplay = true
		}
	}
	
	
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.set()
		bounds.fill()
		
		guard let drawing = self.drawing else {
			return
		}
		
		for rect in drawing.rectanglesInOrder {
			let bounds = NSRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
			let path = NSBezierPath(rect: bounds)
			rect.color.set()
			path.fill()
		}
	}
}
