//
//  Misc.swift
//  ValueTypeChanges
//
//  Created by Seth Willits on 8/17/17.
//  Copyright © 2017 Araelium Group. All rights reserved.
//

import Foundation


extension Double {
	/// Random between 0.0 and 1.0
	static func random() -> Double {
		return Double(arc4random_uniform(4_000_000_001)) / Double(4_000_000_000)
	}
}

