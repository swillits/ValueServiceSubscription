//
//  EditorView.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa


protocol EditorViewDelegate: class {
	func editorViewSelectedRectDidChange()
}



class EditorView: NSView, DrawingServiceSubscriber {
	
	var _drawingSubscription: Any?
	var _drawingService: DrawingService?
	
	
	func drawingServiceDidChange() {
		needsDisplay = true
	}
	
	
	func drawing(_ drawing: Drawing, didChange change: DrawingChanges.ChangeKind, continuous: Bool) {
		if let id = selectedRectID, drawing.rectangles[id] == nil {
			selectedRectID = nil
		}
		needsDisplay = true
	}
	
	
	
	
	weak var delegate: EditorViewDelegate?
	
	
	
	
	override func mouseDown(with event: NSEvent) {
		guard let drawing = drawingService?.drawing else {
			return
		}
		
		let point = convert(event.locationInWindow, from: nil)
		
		
		for rect in drawing.rectanglesInOrder.reversed() {
			if rect.bounds.contains(point) {
				selectedRectID = rect.id
				return
			}  
		}
		
		selectedRectID = nil
	}
	
	
	
	
	var selectedRectID: UUID? = nil {
		didSet {
			if oldValue != selectedRectID {
				needsDisplay = true
				delegate?.editorViewSelectedRectDidChange()
			}
		}
	}
	
	
	
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.set()
		bounds.fill()
		
		guard let drawing = drawingService?.drawing else {
			return
		}
		
		for rect in drawing.rectanglesInOrder {
			let bounds = NSRect(x: CGFloat(rect.x), y: CGFloat(rect.y), width: CGFloat(rect.w), height: CGFloat(rect.h))
			
			let path = NSBezierPath(rect: bounds)
			rect.color.set()
			path.fill()
			
			if let id = selectedRectID, rect.id == id {
				NSColor.black.set()
				path.lineWidth = 2
				path.stroke()
			}
		}
	}
	
}
