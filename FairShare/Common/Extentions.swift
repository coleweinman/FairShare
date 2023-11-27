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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Decimal {
    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
