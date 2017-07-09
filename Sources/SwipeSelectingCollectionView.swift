//
//  SwipeSelectingCollectionView.swift
//  TileTime
//
//  Created by Shane Qi on 7/2/17.
//  Copyright © 2017 Shane Qi. All rights reserved.
//

import UIKit

public class SwipeSelectingCollectionView: UICollectionView {

	private var beginIndexPath: IndexPath?
	private var selectingRange: ClosedRange<IndexPath>?
	private var selectingMode: SelectingMode = .selecting
	private var selectingIndexPaths = Set<IndexPath>()

	private enum SelectingMode {
		case selecting, deselecting
	}

	lazy private var panSelectingGestureRecognizer: UIPanGestureRecognizer = {
		let gestureRecognizer = SwipeSelectingGestureRecognizer(
			target: self,
			action: #selector(SwipeSelectingCollectionView.didPanSelectingGestureRecognizerChange(gestureRecognizer:)))
		return gestureRecognizer
	} ()

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		gestureRecognizers?.append(panSelectingGestureRecognizer)
		allowsMultipleSelection = true
	}

	override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		gestureRecognizers?.append(panSelectingGestureRecognizer)
		allowsMultipleSelection = true
	}

	@objc private func didPanSelectingGestureRecognizerChange(gestureRecognizer: UIPanGestureRecognizer) {
		let point = gestureRecognizer.location(in: self)
		switch gestureRecognizer.state {
		case .began:
			self.beginIndexPath = indexPathForItem(at: point)
			if let indexPath = beginIndexPath,
				let isSelected = cellForItem(at: indexPath)?.isSelected {
				selectingMode = (isSelected ? .deselecting : .selecting)
				if isSelected {
					delegate?.collectionView?(self, didDeselectItemAt: indexPath)
					deselectItem(at: indexPath, animated: false)
				} else {
					delegate?.collectionView?(self, didSelectItemAt: indexPath)
					selectItem(at: indexPath, animated: false, scrollPosition: [])
				}
			} else { selectingMode = .selecting }
		case .changed:
			handleChangeOf(gestureRecognizer: gestureRecognizer)
		default:
			beginIndexPath = nil
			selectingRange = nil
			selectingIndexPaths.removeAll()
		}
	}

	private func handleChangeOf(gestureRecognizer: UIPanGestureRecognizer) {
		let point = gestureRecognizer.location(in: self)
		guard var beginIndexPath = self.beginIndexPath,
			var endIndexPath = indexPathForItem(at: point) else { return }
		if endIndexPath < beginIndexPath {
			swap(&beginIndexPath, &endIndexPath)
		}
		let range = ClosedRange(uncheckedBounds: (beginIndexPath, endIndexPath))
		guard range != selectingRange else { return }
		if let selectingRange = selectingRange {
			var positiveIndexPaths = [IndexPath]()
			var negativeIndexPaths = [IndexPath]()
			if range.lowerBound == selectingRange.lowerBound {
				if range.upperBound < selectingRange.upperBound {
					negativeIndexPaths = indexPaths(in:
						ClosedRange(uncheckedBounds: (range.upperBound, selectingRange.upperBound)))
					negativeIndexPaths.removeFirst()
				} else {
					positiveIndexPaths = indexPaths(in: ClosedRange(uncheckedBounds: (selectingRange.upperBound, range.upperBound)))
				}
			} else if range.upperBound == selectingRange.upperBound {
				if range.lowerBound > selectingRange.lowerBound {
					negativeIndexPaths = indexPaths(in:
						ClosedRange(uncheckedBounds: (selectingRange.lowerBound, range.lowerBound)))
					negativeIndexPaths.removeLast()
				} else {
					positiveIndexPaths = indexPaths(in: ClosedRange(uncheckedBounds: (range.lowerBound, selectingRange.lowerBound)))
				}
			} else {
				negativeIndexPaths = indexPaths(in: selectingRange)
				if let beginIndexPathIndex = negativeIndexPaths.index(of: beginIndexPath) {
					negativeIndexPaths.remove(at: beginIndexPathIndex)
				}
				positiveIndexPaths = indexPaths(in: range)
			}
			for indexPath in negativeIndexPaths {
				doSelection(at: indexPath, isPositive: false)
			}
			for indexPath in positiveIndexPaths {
				doSelection(at: indexPath, isPositive: true)
			}
			self.selectingRange = range
		} else {
			selectingRange = range
			for indexPath in indexPaths(in: range) {
				doSelection(at: indexPath, isPositive: true)
			}
		}

	}

	private func doSelection(at indexPath: IndexPath, isPositive: Bool) {
		guard indexPath != beginIndexPath else { return }
		guard let isSelected = cellForItem(at: indexPath)?.isSelected else { return }
		switch selectingMode {
		case .selecting:
			if isSelected != isPositive {
				if isPositive {
					selectingIndexPaths.insert(indexPath)
					delegate?.collectionView?(self, didSelectItemAt: indexPath)
					selectItem(at: indexPath, animated: false, scrollPosition: [])
				} else if selectingIndexPaths.contains(indexPath) {
					delegate?.collectionView?(self, didDeselectItemAt: indexPath)
					deselectItem(at: indexPath, animated: false)
				}
			}
		case .deselecting:
			if isSelected != !isPositive {
				if isPositive {
					selectingIndexPaths.insert(indexPath)
					delegate?.collectionView?(self, didDeselectItemAt: indexPath)
					deselectItem(at: indexPath, animated: false)
				} else if selectingIndexPaths.contains(indexPath) {
					delegate?.collectionView?(self, didSelectItemAt: indexPath)
					selectItem(at: indexPath, animated: false, scrollPosition: [])
				}
			}
		}
	}

	private func indexPaths(in range: ClosedRange<IndexPath>) -> [IndexPath] {
		var indexPaths = [IndexPath]()
		let beginSection = range.lowerBound.section
		let endSection = range.upperBound.section
		guard beginSection != endSection else {
			for row in range.lowerBound.row...range.upperBound.row {
				indexPaths.append(IndexPath(row: row, section: beginSection))
			}
			return indexPaths
		}
		for row in range.lowerBound.row..<dataSource!.collectionView(self, numberOfItemsInSection: beginSection) {
			indexPaths.append(IndexPath(row: row, section: beginSection))
		}
		for row in 0...range.upperBound.row {
			indexPaths.append(IndexPath(row: row, section: endSection))
		}

		for section in (range.lowerBound.section + 1)..<range.upperBound.section {
			for row in 0..<dataSource!.collectionView(self, numberOfItemsInSection: section) {
				indexPaths.append(IndexPath(row: row, section: section))
			}
		}
		return indexPaths
	}

}
