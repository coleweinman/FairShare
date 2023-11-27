//
//  LoadingOverlayView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/26/23.
//

import SwiftUI

struct LoadingOverlayView: View {
    @Binding var enabled: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if enabled {
                ZStack(alignment: .center) {
                    Color.gray.opacity(0.6).frame(width: geometry.size.width, height: geometry.size.height)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 200, height: 100)
                    VStack {
                        ProgressView()
                        Text("Processing Image")
                    }
                }
            }
        }
    }
}

//#Preview {
//    LoadingOverlayView()
//}
