//
//  receipt.swift
//  Seisan
//
//  Created by 野口 勇気 on 2020/09/12.
//  Copyright © 2020 Yuki Noguchi. All rights reserved.
//

import Foundation
import RealmSwift

class Receipt: Object {
    @objc dynamic var id: String = String(time(nil))
    @objc dynamic var title: String = ""
    @objc dynamic var type: Bool = false
    let items = List<Item>()
    private static var realm = try! Realm()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func all() -> [Receipt] {
        Array(realm.objects(Receipt.self).sorted(byKeyPath: "id"))
    }
    
    static func create(title: String, type: Bool) {
        let receipt = Receipt()
        receipt.title = title
        receipt.type = type
        try! realm.write {
            realm.add(receipt, update: .modified)
        }
    }
    
    static func remove(receipt: Receipt) {
        try! realm.write {
            realm.delete(receipt)
        }
    }
    
    func getItems() -> [Item] {
        Array(self.items)
    }
    
    func getTotalCost() -> Int {
        var totalCost = 0
        if items.count > 0 {
            items.forEach { (item: Item) in
                totalCost += item.getCost()
            }
        }
        return totalCost
    }
}
