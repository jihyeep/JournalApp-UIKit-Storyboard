//
//  GlobeView.swift
//  JRNL
//
//  Created by 박지혜 on 5/30/24.
//

import SwiftUI
import RealityKit

struct GlobeView: View {
    var body: some View {
        #if os(xrOS)
        VStack{
            Model3D(named: "globe") { model in model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        }
        #endif
    }
}

#Preview {
    GlobeView()
}
