//
//  EditorWindowController.swift
//  ValueServiceSubscription
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa



class EditorWindowController: NSWindowController, DrawingServiceSubscriber, EditorViewDelegate {
	
	
	@IBOutlet weak var editorView: EditorView!
	
	@IBOutlet weak var xField: NSTextField!
	@IBOutlet weak var yField: NSTextField!
	@IBOutlet weak var wField: NSTextField!
	@IBOutlet weak var hField: NSTextField!
	
	@IBOutlet weak var xSlider: NSSlider!
	@IBOutlet weak var ySlider: NSSlider!
	@IBOutlet weak var wSlider: NSSlider!
	@IBOutlet weak var hSlider: NSSlider!
	
	@IBOutlet weak var colorButtonR: NSButton!
	@IBOutlet weak var colorButtonG: NSButton!
	@IBOutlet weak var colorButtonB: NSButton!
	@IBOutlet weak var colorWell: NSColorWell!
	
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("EditorWindowController")
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		editorView.delegate = self
		drawingServiceDidChange()
    }
    
	
	var _drawingSubscription: Any?
	var _drawingService: DrawingService?
	
	
	func drawingServiceDidChange() {
		guard isWindowLoaded else { return }
		editorView.drawingService = self.drawingService
		updateUIForSelectedRect()
	}
	
	
	func drawing(_ drawing: Drawing, didChange change: DrawingChanges.Change, continuous: Bool) {
		guard isWindowLoaded else { return }
		
		// Inspect the change to see if it affects us before updating
		updateUIForSelectedRect()
	}
	
	
	func editorViewSelectedIndexDidChange() {
		updateUIForSelectedRect()
	}
	
	
	
	func updateUIForSelectedRect() {
		guard let drawingService = drawingService, editorView.selectedIndex != -1 else {
			xField.isEnabled = false
			yField.isEnabled = false
			wField.isEnabled = false
			hField.isEnabled = false
			xSlider.isEnabled = false
			ySlider.isEnabled = false
			wSlider.isEnabled = false
			hSlider.isEnabled = false
			
			xField.integerValue = 0
			yField.integerValue = 0
			wField.integerValue = 0
			hField.integerValue = 0
			xSlider.integerValue = 0
			ySlider.integerValue = 0
			wSlider.integerValue = 0
			hSlider.integerValue = 0
			return
		}
		
		
		let rect = drawingService.drawing.rectangles[editorView.selectedIndex]
		
		xField.isEnabled = true
		yField.isEnabled = true
		wField.isEnabled = true
		hField.isEnabled = true
		xSlider.isEnabled = true
		ySlider.isEnabled = true
		wSlider.isEnabled = true
		hSlider.isEnabled = true
		
		xField.integerValue = rect.x
		yField.integerValue = rect.y
		wField.integerValue = rect.w
		hField.integerValue = rect.h
		xSlider.integerValue = rect.x
		ySlider.integerValue = rect.y
		wSlider.integerValue = rect.w
		hSlider.integerValue = rect.h
	}
	
	
	
	@IBAction func addNewRect(_ sender: Any?) {
		let color = NSColor(srgbRed: CGFloat(Double.random()), green: CGFloat(Double.random()), blue: CGFloat(Double.random()), alpha: 1.0)
		let rect = Rectangle(x: Int(Double.random() * 400), y: Int(Double.random() * 300), w: 100, h: 100, color: color)
		let index = drawingService!.drawing.rectangles.count
		
		let change = DrawingChanges.Change(
			change: .insert(DrawingChanges.ChangeInsert(index: index, rect: rect)),
		    undoChange: .remove(DrawingChanges.ChangeRemove(index: index)),
		    changeName: nil,
		    undoChangeName: nil
		)
		
		drawingService!.applyChange(change)
	}
	
	
	
	
	private var drawingBeforeContinuousChanges: Drawing? = nil
	
	@IBAction func changeXYWH(_ sender: Any?) {
		guard let control = sender as? NSControl else { return }
		let drawingService = self.drawingService!
		let continuous = control.isSendingContinuousAction()
		
		if continuous && drawingBeforeContinuousChanges == nil {
			drawingBeforeContinuousChanges = drawingService.drawing
		}
		
		if control == xField || control == yField || control == xSlider || control == ySlider {
			let index = editorView.selectedIndex
			let rect = (drawingBeforeContinuousChanges ?? drawingService.drawing).rectangles[index]
			let undoChangeInfo = DrawingChanges.ChangePosition(index: index, x: rect.x, y: rect.y) 
			var changeInfo = DrawingChanges.ChangePosition(index: index, x: rect.x, y: rect.y)
			
			if control == xField || control == xSlider {
				changeInfo.x = control.integerValue
			} else if control == yField || control == ySlider {
				changeInfo.y = control.integerValue
			}
			
			let change = DrawingChanges.Change(
				change: .position(changeInfo),
				undoChange: .position(undoChangeInfo),
				changeName: nil,
				undoChangeName: nil
			)
			
			if !continuous {
				print("Non continuous")
			}
			
			drawingService.applyChange(change, continuous: continuous)
		}
		
		if !continuous {
			drawingBeforeContinuousChanges = nil
		}
	}
	
	
	
	@IBAction func changeColorRGB(_ sender: Any?) {
		
	}
}


extension NSControl {
	func isSendingContinuousAction() -> Bool {
		guard isContinuous else { return false }
		guard let event = window?.currentEvent else { return false }
		return event.type == .leftMouseDown || event.type == .leftMouseDragged || event.type == .keyDown || event.type == .pressure
	}
}


