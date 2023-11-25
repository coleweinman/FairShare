//
//  HelpPopup.swift
//  FairShare
//
//  Created by Melody Yin on 11/24/23.
//

class HelpDescription: Identifiable {
    var pageName: String
    var generalDescription: String
    var creationDescription: String
    var icon: Image
    
    init(pageName: String, generalDescription: String, creationDescription: String, icon: Image) {
        self.pageName = pageName
        self.generalDescription = generalDescription
        self.creationDescription = creationDescription
        self.icon = icon
    }
}
let dashboardDescription = HelpDescription(pageName: "Dashboard", generalDescription: "View a list of your past payments and expenses as well as a summary of your cumulative net balance.", creationDescription: "", icon: Image(systemName: "house"))

let groupDescription = HelpDescription(pageName: "Groups", generalDescription: "Create and join groups to make expense creation simpler\nPair with other users through groups by sending out a join request\nUnder the groups page, you will see active groups that you have previously joined or created and pending groups for which you have a pending invite.", creationDescription: "To create a new group, click on the plus icon in the top right corner. Give your new group a name and add users to the group by email.", icon: Image(systemName:"person.3"))

let expenseDescription = HelpDescription(pageName: "Expenses", generalDescription: "View, sort, and search exclusively through shared expenses that have been logged in the past. This includes all expenses created by you as well as expenses created by other users that have tagged you on their expense.", creationDescription: "", icon: Image(systemName: "scroll"))

let paymentDescription = HelpDescription(pageName: "Payments", generalDescription: "View, sort, and search through incoming and outgoing payments with other users. ", creationDescription: "", icon: Image(systemName: "creditcard"))

let analyticsDescription = HelpDescription(pageName: "Analytics", generalDescription: "", creationDescription: "", icon: Image(systemName: "chart.bar"))

let listDescription = HelpDescription(pageName: "Shopping Lists", generalDescription: "Create personal and shared shopping lists to plan future shared expenses within your groups.", creationDescription: "", icon: Image(systemName:"checklist"))

let descriptionList: [HelpDescription] = [dashboardDescription, groupDescription, expenseDescription, paymentDescription, listDescription, analyticsDescription]


import SwiftUI

struct HelpPopup: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    icon
                    title
                }
                VStack (alignment: .leading) {
                    ForEach(descriptionList) { item in
                        SectionDescription(component: item)
                        Divider()
                    }
                }
            }.multilineTextAlignment(.leading)
        }
    }
}


struct SectionDescription: View {
    var component: HelpDescription
    var body: some View {
        VStack {
                HStack {
                    component.icon.resizable().scaledToFit().frame(width: 45, height: 45)
                    Text(component.pageName).font(.system(size: 18, design: .rounded))
                }
                Divider()
                Text(component.generalDescription)
                if (component.creationDescription != "") {
                    Text("Creation: \(component.creationDescription)")
                }
        }.scenePadding().border(.black)
    }
}

// https://www.youtube.com/watch?v=OaIn7HBlCSk
private extension HelpPopup {
    var icon: some View {
        Image("question-duck").resizable().scaledToFit().frame(width: 128, height: 128)
    }
    
    var title: some View {
        Text("Tutorial").font(.system(size: 42, weight: .bold, design: .rounded))
    }
    
    var content: some View {
        Text("Body")
    }
}

#Preview {
    HelpPopup()
}
