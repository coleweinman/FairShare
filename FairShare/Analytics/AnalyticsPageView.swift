//
//  AnalyticsPageView.swift
//  FairShare
//
//  Created by Cole Weinman on 11/7/23.
//

import SwiftUI
import Charts

struct AnalyticsPageView: View {
    @StateObject private var viewModel: AnalyticsViewModel = AnalyticsViewModel()
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if let totalOwed = viewModel.totalOwed {
                    if totalOwed.isEmpty {
                        Spacer()
                        Image("duck3")
                        Text("No analytics data for users with no expenses.")
                        Spacer()
                    } else {
                        Text("Balance from expenses over the last year")
                        Chart {
                            ForEach(Array(totalOwed)) { userAmount in
                                BarMark (
                                    x: .value("Name", userAmount.name),
                                    y: .value("Amount", userAmount.amount)
                                )
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }.padding()
        }
        .onAppear {
            if let userId = userViewModel.user?.id {
                Task {
                    await viewModel.getData(uid: userId)
                }
            }
        }
        
    }
}

#Preview {
    AnalyticsPageView()
}
