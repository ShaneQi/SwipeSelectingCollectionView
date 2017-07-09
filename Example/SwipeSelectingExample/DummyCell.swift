//
//  DummyCell.swift
//  SwipeSelectingExample
//
//  Created by Shane Qi on 7/9/17.
//  Copyright © 2017 Shane Qi. All rights reserved.
//

import UIKit

class DummyCell: UICollectionViewCell {

	static var identifier: String { return String(describing: DummyCell.self) }

	override var isSelected: Bool { didSet {
		backgroundColor = isSelected ? .red : .green
		} }

}
