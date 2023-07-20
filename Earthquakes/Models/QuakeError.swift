//
//  QuakeError.swift
//  Earthquakes-iOS
//
//  Created by Aleksandr on 20.07.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

enum QuakeError: Error {
    case missingData
    case networkError
    case unexpectedError(Error)
}

extension QuakeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingData:
            return NSLocalizedString("Found and will discard a quake missing a valid code, magnitude, place, or time.",
                                     comment: "")
        case .networkError:
            return NSLocalizedString("Error occurred while getting the data over the network",
                                     comment: "")
        case .unexpectedError(let error):
            return NSLocalizedString(error.localizedDescription,
                                     comment: "")
        }
    }
}
