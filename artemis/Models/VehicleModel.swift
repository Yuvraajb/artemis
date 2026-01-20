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

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// USDZ model filename
    var modelFileName: String {
        return "sls.usdz"
    }

    /// Thumbnail image name (placeholder - can use SF Symbols or bundled images)
    var thumbnailName: String {
        return "airplane.departure"
    }
}

