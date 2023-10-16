//
//  DashboardView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct DashboardPageView: View {
    
    var body: some View {
        VStack {
            
                Divider()
                ScrollView {
                    Text("Dashboard Page")
                }
                .padding()
            }
        }
    }

struct DashboardPageView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardPageView()
    }
}
