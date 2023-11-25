//
//  TabView.swift
//  FairShare
//
//  Created by Cole Weinman on 10/10/23.
//

import SwiftUI

struct MainTabView: View {
    @State var selection = Tab.dashboard
    @StateObject var viewModel = UserViewModel()
    @StateObject var balanceDataViewModel = BalanceDataViewModel()
    @StateObject var groupListViewModel: GroupListViewModel = GroupListViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var showHelp = false
    
    var body: some View {
        NavigationStack {
            if viewModel.user != nil {
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
                    if let createView = selection.config.createView, let createViewTitle = selection.config.createViewTitle {
                        ToolbarItem(placement: .primaryAction) {
                            NavigationLink {
                                createView.navigationTitle(createViewTitle).toolbarBackground(.visible, for: .navigationBar)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            GroupPageView()
                        } label: {
                            Image(systemName: "person.3")
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            SettingsPageView()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showHelp.toggle()
                        }) {
                            Image(systemName: "questionmark.circle")
                        }.sheet(isPresented: $showHelp) {
                            HelpPopup()
                        }
                    }
                }
            } else {
                VStack {
                    ProgressView() // Displays a loading spinner
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue)) // Customize the spinner color if needed
                    
                    Text("Loading...")
                        .padding(.top, 8)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear() {
            if let uid = authViewModel.user?.uid {
                viewModel.fetchData(uid: uid)
                balanceDataViewModel.fetchData(uid: uid)
                groupListViewModel.fetchData(uid: uid)
            }
        }
        .environmentObject(viewModel)
        .environmentObject(groupListViewModel)
        .environmentObject(balanceDataViewModel)
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
                content: AnyView(ExpensesPageView()),
                createView: AnyView(ExpenseCreationView()),
                createViewTitle: "Create Expense"
            )
        case .payments:
            return TabConfiguation(
                title: "Payments",
                image: "creditcard",
                content: AnyView(PaymentsPageView()),
                createView: AnyView(PaymentCreationView()),
                createViewTitle: "Create Payment"
            )
        case .lists:
            return TabConfiguation(
                title: "Lists",
                image: "checklist",
                content: AnyView(ListsPageView()),
                createView: AnyView(ListCreationView()),
                createViewTitle: "Create List"
            )
        case .analytics:
            return TabConfiguation(
                title: "Analytics",
                image: "chart.bar",
                content: AnyView(AnalyticsPageView())
            )
        }
    }
}

class TabConfiguation {
    var title: String
    var image: String
    var content: AnyView
    var createView: AnyView?
    var createViewTitle: String?
    
    init(title: String, image: String, content: AnyView, createView: AnyView? = nil, createViewTitle: String? = "") {
        self.title = title
        self.image = image
        self.content = content
        self.createView = createView
        self.createViewTitle = createViewTitle
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
