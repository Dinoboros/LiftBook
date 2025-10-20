//
//  User.swift
//  LiftBook
//
//  Created by Méryl VALIER on 01/10/2025.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var password: String

    init(name: String, email: String, password: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.password = password
    }
}