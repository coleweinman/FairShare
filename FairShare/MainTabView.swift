//
//  TabView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct MainTabView: View {
    @State var selection = Tab.dashboard
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ForEach(Tab.allCases, id: \.self) {
                    (tab) in
                    tab.config.content
                        .tabItem {
                            Label(tab.config.title, systemImage: tab.config.image)
                        }
                        .tag(tab)
                    
                }
            }
            .navigationTitle(selection.config.title)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if let createView = selection.config.createView {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            createView
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        SettingsPageView()
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }
        }
    }
}
    
enum Tab: Int, CaseIterable {
    case dashboard = 1
    case expenses = 2
    case payments = 3
    case lists = 4
    case analytics = 5
    var config: TabConfiguation {
        switch self {
        case .dashboard:
            return TabConfiguation(
                title: "Dashboard",
                image: "house",
                content: AnyView(DashboardPageView())
            )
        case .expenses:
            return TabConfiguation(
                title: "Expenses",
                image: "scroll",
                content: AnyView(ContentView()),
                createView: AnyView(ExpenseCreationView())
            )
        case .payments:
            return TabConfiguation(
                title: "Payments",
                image: "creditcard",
                content: AnyView(ContentView()),
                createView: AnyView(PaymentCreationView())
            )
        case .lists:
            return TabConfiguation(
                title: "Lists",
                image: "checklist",
                content: AnyView(ListsPageView())
            )
        case .analytics:
            return TabConfiguation(
                title: "Analytics",
                image: "chart.bar",
                content: AnyView(ContentView())
            )
        }
    }
}

class TabConfiguation {
    var title: String
    var image: String
    var content: AnyView
    var createView: AnyView?
    
    init(title: String, image: String, content: AnyView, createView: AnyView? = nil) {
        self.title = title
        self.image = image
        self.content = content
        self.createView = createView
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
