//
//  ModelSelectionView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Model Selection Screen: Direct access to SLS Rocket viewer
struct ModelSelectionView: View {
    var body: some View {
        NavigationStack {
            ModelViewerView(vehicle: .sls)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ModelSelectionView()
}

