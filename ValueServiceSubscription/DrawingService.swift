//
//  DrawingService.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Foundation


class DrawingService {
	
	private var subscriptionsQueue = DispatchQueue(label: "DrawingService.subscriptionsQueue")
	private var subscriptions: [Subscription] = []
	
	
	init(drawing: Drawing) {
		_drawing = drawing
	}
	
	
	
	// MARK: - Subscribing
	
	func subscribe(_ subscriber: DrawingServiceSubscriber) -> Any {
		let subscription = Subscription(subscriber)
		subscriptionsQueue.sync {
			subscriptions.append(subscription)
		}
		return subscription
	}
	
	
	func unsubscribe(_ subscription: Any) {
		let subscription = subscription as! Subscription
		subscriptionsQueue.sync {
			if let index = subscriptions.index(where: { $0 === subscription }) {
				subscriptions.remove(at: index)
			}
		}
	}
	
	
	private class Subscription {
		private(set) weak var subscriber: DrawingServiceSubscriber?
		
		init(_ value: DrawingServiceSubscriber) {
			self.subscriber = value
		}
	}
	
	
	
	
	// MARK: - Model Access
	
	private var _drawing: Drawing
	private var _drawingLock = DispatchQueue(label: "DrawingService.Drawing")
	var drawing: Drawing {
		get {
			return _drawingLock.sync { _drawing }
		}
	}
	
	
	
	
	// MARK: - Model Changing
	
	var undoManager: UndoManager? = nil
	
	
	func applyChange(_ change: DrawingChanges.Change, continuous: Bool = false) {
		
		// Is it impractical to allow changes from any thread?
		precondition(Thread.isMainThread)
		
		
		// ------------------------
		// Register Undo
		// ------------------------
		
		if let um = undoManager, !continuous {
			um.beginUndoGrouping()
			um.setActionName(change.changeName ?? change.change.localizableName)
			um.registerUndo(withTarget: self, handler: { (service) in
				service.applyChange(change.inverted, continuous: false)
			})
			um.endUndoGrouping()
		}
		
		
		// ------------------------
		// Update the model
		// ------------------------
		
		var drawing: Drawing!
		
		_drawingLock.sync {
			_drawing = DrawingChanges.apply(drawing: _drawing, kind: change.change)
			drawing = _drawing
		}
		
		
		// ------------------------
		// Notify Subscribers
		// ------------------------
		
		var subscriptions: [Subscription]! = nil
		
		subscriptionsQueue.sync {
			subscriptions = self.subscriptions
		}
		
		for subscription in subscriptions {
			if let subscriber = subscription.subscriber {
				subscriber.drawing(drawing, didChange: change, continuous: continuous)
			}
		}
	}
}




/// Notifications are sent on the main thread
protocol DrawingServiceSubscriber: class {
	var drawingService: DrawingService? { get set }
	func drawingServiceDidChange()
	func drawing(_ drawing: Drawing, didChange change: DrawingChanges.Change, continuous: Bool)
	
	var _drawingSubscription: Any? { get set }
	var _drawingService: DrawingService? { get set }
}




// This extension and the required _variables in the DrawingServiceSubscriber implementation are ourOur funky way of avoiding having to duplicate the subscribing code
extension DrawingServiceSubscriber {
	var drawingService: DrawingService? {
		set {
			if _drawingService !== newValue {
				_drawingSubscription = nil
				_drawingService = newValue
				
				DispatchQueue.main.async {
					self.drawingServiceDidChange()
				}
				
				if let service = _drawingService {
					_drawingSubscription = service.subscribe(self)
				}
			}
		}
		get {
			return _drawingService
		}
	}
}


