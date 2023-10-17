//
//  ExpensesPageView.swift
//  FairShare
//
//  Created by Scott Lai on 10/17/23.
//

import SwiftUI

struct ExpensesPageView: View {
    @ObservedObject private var expenseViewModel = ExpenseListViewModel()
    @State private var searchText: String = ""
    
    var pageBackgroundColor: Color = Color(red: 0.933, green: 0.933, blue: 0.933, opacity: 1)
    var cardBackgroundColor: Color = Color(red: 1, green: 1, blue: 1, opacity: 1)
    var cardOuterCornerRadius: CGFloat = 24
    var cardPadding: CGFloat = 16
    var headerFontSize: CGFloat = 18
    
    var body: some View {
        ScrollView {
            ZStack {
                Rectangle()
                    .fill(pageBackgroundColor)
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Button(action: {
                            print("tanked")
                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(8)
                        .background(cardBackgroundColor)
                        .cornerRadius(cardOuterCornerRadius)
                        TextField("Search...", text: $searchText)
                            .padding(8)
                            .background(cardBackgroundColor)
                            .cornerRadius(cardOuterCornerRadius)
                            .autocapitalization(.none)
                        Button(action: {
                            print("tanked")
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                        .frame(maxHeight: .infinity)
                        .padding(8)
                        .background(cardBackgroundColor)
                        .cornerRadius(cardOuterCornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    VStack {
//                        ForEach(expenseViewModel.expenses) { expense in
//                            TableCellItemView(
//                                title: expense.title,
//                                date: expense.date,
//                                amount: "$\(String(describing: expense.totalAmount))",
//                                pfps: tanked,
//                                backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
//                                cornerRadius: 8)
//                        }
                        TableCellItemView(
                            title: "Dinner at Roadhouse",
                            date: Date(),
                            amount: "$\(String(describing: 105.39))",
                            pfps: ["Weinman", "Weinman", "Weinman", "Weinman"],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                        TableCellItemView(
                            title: "Dinner at North Italia",
                            date: Date(),
                            amount: "$\(String(describing: 217.11))",
                            pfps: ["Weinman", "Weinman", "Weinman"],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                        TableCellItemView(
                            title: "August Utilities",
                            date: Date(),
                            amount: "$\(String(describing: 72.24))",
                            pfps: ["Weinman", "Weinman", "Weinman", "Weinman"],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                        TableCellItemView(
                            title: "Tubing at San Marcos",
                            date: Date(),
                            amount: "$\(String(describing: 32.99))",
                            pfps: ["Weinman", "Weinman"],
                            backgroundColor: Color(red: 0.671, green: 0.827, blue: 0.996),
                            cornerRadius: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(cardPadding)
                    .background(cardBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: cardOuterCornerRadius))
                    .onAppear() {
                        expenseViewModel.fetchData(uid: "5xuwvjBzryoJsQ3VGLIX")
                    }
                }
                .frame(maxWidth: .infinity)
                .scenePadding()
            }
        }
    }
}

struct ExpensesPageView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesPageView()
    }
}
