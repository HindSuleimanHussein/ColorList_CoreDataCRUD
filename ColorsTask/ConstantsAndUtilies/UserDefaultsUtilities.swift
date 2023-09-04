//
//  UserDefaultsUtilities.swift
//  ColorsTask
//
//  Created by Foothill on 19/09/2023.
//

import Foundation

class UserDefaultsUtilities {
    
    static let shared = UserDefaultsUtilities() // Singleton instance
    
    private init() { } // Private initializer to ensure it's a singleton
    
    func saveReorderedColors(colors: [String]) {
        do {
            // Use JSONEncoder to encode the current order of color IDs to Data
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(colors)
            
            // Save the encoded data to UserDefaults
            UserDefaults.standard.set(encodedData, forKey: Constants.Conts.userDefaults.userDefaultsKey)
        } catch {
            print("Error encoding color order: \(error.localizedDescription)")
        }
    }
    
    func loadReorderedColors() -> [String]? {
        if let encodedData = UserDefaults.standard.data(forKey: Constants.Conts.userDefaults.userDefaultsKey) {
            do {
                // Use JSONDecoder to decode the ordered color IDs from Data
                let decoder = JSONDecoder()
                let orderedColorIDs = try decoder.decode([String].self, from: encodedData)
                return orderedColorIDs
            } catch {
                print("Error decoding color order: \(error.localizedDescription)")
            }
        }
        return nil
    }
}

