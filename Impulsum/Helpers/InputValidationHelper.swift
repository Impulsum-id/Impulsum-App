//
//  InputValidationHelper.swift
//  Impulsum
//
//  Created by Lucky on 15/10/24.
//

import Foundation

struct InputValidationHelper {
    
    static func validateDecimalInput(_ input: String) -> String {
        let decimalCharacters = CharacterSet(charactersIn: "0123456789,.")
        let filtered = input.unicodeScalars.filter { decimalCharacters.contains($0) }
        let filteredString = String(String.UnicodeScalarView(filtered))
        
        let decimalCount = filteredString.filter { $0 == "." || $0 == "," }.count
        if decimalCount > 1 {
            return String(filteredString.dropLast())
        }
        
        if let range = filteredString.range(of: ",") {
            var normalizedString = filteredString.replacingCharacters(in: range, with: ".")
            return normalizedString
        }
        
        return filteredString
    }
}
