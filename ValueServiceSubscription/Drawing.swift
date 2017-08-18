//
//  Drawing.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Cocoa


struct Drawing {
	var rectangles: [UUID: Rectangle]
	var rectangleOrder: [UUID]
	
	// Should be an enumerated sequence for performance
	var rectanglesInOrder: [Rectangle] {
		return rectangleOrder.map { rectangles[$0]! }
	}
}



struct Rectangle {
	var id: UUID
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

	
	
	struct ChangeCategory: OptionSet {
		let rawValue: Int
		
		static let rectangles           = ChangeCategory(rawValue: 1 << 0)
		static let rectangleAppearance  = ChangeCategory(rawValue: 1 << 1)
	}
	
	
	
	enum ChangeKind {
		case insert(ChangeInsert)
		case remove(ChangeRemove)
		case position(ChangePosition)
		case size(ChangeSize)
		case color(ChangeColor)
		
		var category: ChangeCategory {
			switch self {
			case .insert, .remove: return [.rectangles]
			case .position, .size, .color: return [.rectangleAppearance]
			}
		}
		
		var localizableName: String {
			switch self {
			case .insert:   return "Insert"
			case .remove:   return "Remove"
			case .position: return "Position"
			case .size:     return "Size"
			case .color:    return "Color"
			}
		}
		
		
		// Convenience accessors for common properties of changes
		// -----------------------------------------------------------
		var rectID: UUID? {
			switch self {
			case .insert(let info):   return info.rect.id
			case .remove(let info):   return info.rectID
			case .position(let info): return info.rectID
			case .size(let info):     return info.rectID
			case .color(let info):    return info.rectID
			} 
		}
		
		
		
		// Convenience for determining change relevancy
		// -----------------------------------------------------------
		func affectsAppearanceOfRectangle(id: UUID) -> Bool {
			if category.contains(.rectangleAppearance) {
				return rectID! == id
			}
			return false
		}
		
	}
	
	
	struct ChangeInsert {
		var index: Int
		var rect: Rectangle
	}
	
	
	struct ChangeRemove {
		var rectID: UUID
	}
	
	
	struct ChangePosition {
		var rectID: UUID
		var x: Int
		var y: Int
	}
	
	
	struct ChangeSize {
		var rectID: UUID
		var w: Int
		var h: Int
	}
	
	
	struct ChangeColor {
		var rectID: UUID
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
		newDrawing.rectangles[change.rect.id] = change.rect
		newDrawing.rectangleOrder.insert(change.rect.id, at: change.index)
		return newDrawing
	}
	
	
	static func apply_remove(drawing: Drawing, change: ChangeRemove) -> Drawing {
		var newDrawing = drawing
		newDrawing.rectangles[change.rectID] = nil
		newDrawing.rectangleOrder.remove(at: newDrawing.rectangleOrder.index(of: change.rectID)!)
		return newDrawing
	}
	
	
	static func apply_position(drawing: Drawing, change: ChangePosition) -> Drawing {
		var newDrawing = drawing
		var rect = newDrawing.rectangles[change.rectID]! 
		rect.x = change.x
		rect.y = change.y
		newDrawing.rectangles[change.rectID] = rect
		return newDrawing
	}
	
	
	static func apply_size(drawing: Drawing, change: ChangeSize) -> Drawing {
		var newDrawing = drawing
		var rect = newDrawing.rectangles[change.rectID]! 
		rect.w = change.h
		rect.h = change.h
		newDrawing.rectangles[change.rectID] = rect
		return newDrawing
	}
	
	
	static func apply_color(drawing: Drawing, change: ChangeColor) -> Drawing {
		var newDrawing = drawing
		var rect = newDrawing.rectangles[change.rectID]!
		rect.color = change.color
		newDrawing.rectangles[change.rectID] = rect
		return newDrawing
	}
	
}
