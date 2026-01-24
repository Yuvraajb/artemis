//
//  VehicleModel.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import Foundation

/// Represents a vehicle that can be viewed in 3D or AR
enum VehicleModel: String, Identifiable {
    case sls = "SLS Rocket"
    case orion = "Orion Capsule"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// USDZ model filename
    var modelFileName: String {
        switch self {
        case .sls:
            return "sls.usdz"
        case .orion:
            return "sls.usdz" // Placeholder - use SLS model for now
        }
    }

    /// Thumbnail image name (placeholder - can use SF Symbols or bundled images)
    var thumbnailName: String {
        switch self {
        case .sls:
            return "airplane.departure"
        case .orion:
            return "capsule.fill"
        }
    }
}

