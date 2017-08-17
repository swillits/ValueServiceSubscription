//
//  Drawing.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa


struct Drawing {
	var rectangles: [Rectangle]
}



struct Rectangle {
	var x: Int
	var y: Int
	var w: Int
	var h: Int
	var color: NSColor
	
	
	var bounds: CGRect {
		return CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(w), height: CGFloat(h))
	}
}




// Need better naming for 
//    DrawingChanges.Change
//    DrawingChanges.ChangeKind
// so that 
//    DrawingChanges.apply(drawing: d, kind: change.change)
// actually makes sense
// 

struct DrawingChanges {
	
	
	struct Change {
		var change: ChangeKind
		var undoChange: ChangeKind
		
		var changeName: String?
		var undoChangeName: String?
		
		var inverted: Change {
			return Change(change: undoChange, undoChange: change, changeName: undoChangeName, undoChangeName: changeName)
		}
	}
	
	
	//struct GroupChange : ChangeProto
	//changes, undoChanges, changeName, undoChangeName

	
	
	enum ChangeKind {
		case insert(ChangeInsert)
		case remove(ChangeRemove)
		case position(ChangePosition)
		case size(ChangeSize)
		case color(ChangeColor)
		
		var localizableName: String {
			switch self {
			case .insert:   return "Insert"
			case .remove:   return "Remove"
			case .position: return "Position"
			case .size:     return "Size"
			case .color:    return "Color"
			}
		}
	}
	
	
	struct ChangeInsert {
		var index: Int
		var rect: Rectangle
	}
	
	
	struct ChangeRemove {
		var index: Int
	}
	
	
	struct ChangePosition {
		var index: Int
		var x: Int
		var y: Int
	}
	
	
	struct ChangeSize {
		var index: Int
		var w: Int
		var h: Int
	}
	
	
	struct ChangeColor {
		var index: Int
		var color: NSColor
	}
	
	
	
	
	static func apply(drawing: Drawing, kind: ChangeKind) -> Drawing {
		switch kind {
		case .insert(let change):   return apply_insert(drawing: drawing, change: change)
		case .remove(let change):   return apply_remove(drawing: drawing, change: change)
		case .position(let change): return apply_position(drawing: drawing, change: change)
		case .size(let change):     return apply_size(drawing: drawing, change: change)
		case .color(let change):    return apply_color(drawing: drawing, change: change)
		}
	}
	
	
	static func apply_insert(drawing: Drawing, change: ChangeInsert) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles.insert(change.rect, at: change.index)
		return newDrawing
	}
	
	
	static func apply_remove(drawing: Drawing, change: ChangeRemove) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles.remove(at: change.index)
		return newDrawing
	}
	
	
	static func apply_position(drawing: Drawing, change: ChangePosition) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles[change.index].x = change.x
		newDrawing.rectangles[change.index].y = change.y
		return newDrawing
	}
	
	
	static func apply_size(drawing: Drawing, change: ChangeSize) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles[change.index].w = change.w
		newDrawing.rectangles[change.index].h = change.h
		return newDrawing
	}
	
	
	static func apply_color(drawing: Drawing, change: ChangeColor) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles[change.index].color = change.color
		return newDrawing
	}
	
}
