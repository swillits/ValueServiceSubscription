//
//  Document.swift
//  ValueServiceSubscription
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa

class Document: NSDocument {
	
	let drawingService: DrawingService
	
	
	override init() {
		let rect = Rectangle(id: UUID(), x: 20, y: 30, w: 100, h: 100, color: NSColor.magenta)
		let drawing = Drawing(rectangles: [rect.id: rect], rectangleOrder: [rect.id])
		drawingService = DrawingService(drawing: drawing)
		
		super.init()
		
		hasUndoManager = true
		drawingService.undoManager = undoManager
	}

	
	
	
	let editorWindowController = EditorWindowController()
	let previewWindowController = PreviewWindowController()
	
	
	override func makeWindowControllers() {
		addWindowController(editorWindowController)
		addWindowController(previewWindowController)
		
		editorWindowController.drawingService = drawingService
		previewWindowController.drawingService = drawingService
	}
	
	
	override func showWindows() {
		previewWindowController.showWindow(nil)
		editorWindowController.showWindow(nil)
	}
	
	
	
	
	
	override class var autosavesInPlace: Bool {
		return true
	}
	
	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from data: Data, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}


}

