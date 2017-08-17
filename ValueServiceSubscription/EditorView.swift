//
//  EditorView.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa


protocol EditorViewDelegate: class {
	func editorViewSelectedIndexDidChange()
}



class EditorView: NSView, DrawingServiceSubscriber {
	
	var _drawingSubscription: Any?
	var _drawingService: DrawingService?
	
	
	func drawingServiceDidChange() {
		needsDisplay = true
	}
	
	
	func drawing(_ drawing: Drawing, didChange change: DrawingChanges.Change, continuous: Bool) {
		if selectedIndex > drawing.rectangles.count {
			selectedIndex = -1
		}
		needsDisplay = true
	}
	
	
	
	
	weak var delegate: EditorViewDelegate?
	
	
	
	
	override func mouseDown(with event: NSEvent) {
		guard let drawing = drawingService?.drawing else {
			return
		}
		
		let point = convert(event.locationInWindow, from: nil)
		
		for (index, rect) in drawing.rectangles.reversed().enumerated() {
			if rect.bounds.contains(point) {
				selectedIndex = drawing.rectangles.count - 1 - index
				return
			}  
		}
		
		selectedIndex = -1
	}
	
	
	
	
	var selectedIndex: Int = -1 {
		didSet {
			if oldValue != selectedIndex {
				needsDisplay = true
				delegate?.editorViewSelectedIndexDidChange()
			}
		}
	}
	
	
	
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.set()
		bounds.fill()
		
		guard let drawing = drawingService?.drawing else {
			return
		}
		
		for (index, rect) in drawing.rectangles.enumerated() {
			let bounds = NSRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
			
			let path = NSBezierPath(rect: bounds)
			rect.color.set()
			path.fill()
			
			if index == selectedIndex {
				NSColor.black.set()
				path.lineWidth = 2
				path.stroke()
			}
		}
	}
	
}
