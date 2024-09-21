//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Konstantin Lyashenko on 21.09.2024.
//

import Testing

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        vc.loadViewIfNeeded()
        
        assertSnapshot(of: vc, as: .image)
    }
    
}
