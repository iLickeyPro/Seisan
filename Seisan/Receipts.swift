//
//  Receipts.swift
//  Seisan
//
//  Created by 野口 勇気 on 2020/09/19.
//  Copyright © 2020 Yuki Noguchi. All rights reserved.
//

import SwiftUI
 
class Receipts : ObservableObject {
    @Published var receipts: [Receipt] = Receipt.all()
    
    static func all() -> [Receipt] {
        Receipt.all()
    }
}
