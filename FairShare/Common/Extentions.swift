//
//  Extentions.swift
//  FairShare
//
//  Created by Cole Weinman on 11/6/23.
//

import Foundation

extension Decimal {
    var moneyString: String {
        let formatter = NumberFormatter();
        formatter.maximumFractionDigits = 2;
        formatter.minimumFractionDigits = 2;
        formatter.currencyCode = "USD";
        formatter.numberStyle = .currency;
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "N/A"
    }
}
