//
//  Item.swift
//  Seisan
//
//  Created by 野口 勇気 on 2020/09/12.
//  Copyright © 2020 Yuki Noguchi. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id: String = String(time(nil))
    // レシート
    let receipt = LinkingObjects(fromType: Receipt.self, property: "items")
    // 価格
    @objc dynamic var cost: Int = 0
    // 税率
    @objc dynamic var isTen: Bool = false
    // 1人か
    @objc dynamic var isSolo: Bool = false
    // 分母
    @objc dynamic var denominator: Int = 2
    // 分子
    @objc dynamic var molecule: Int = 1
    
    private static var realm = try! Realm()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(receipt: Receipt, cost: Int, isTen: Bool, isSolo: Bool, denominator: Int = 2, molecule: Int = 1) {
        let item = Item()
        item.cost = cost
        item.isTen = isTen
        item.isSolo = isSolo
        item.denominator = denominator
        item.molecule = molecule
        try! realm.write {
            receipt.items.append(item)
        }
    }
    
    static func remove(item: Item) {
        try! realm.write {
            realm.delete(item)
        }
    }
    
    func getCost() -> Int {
        let rate: Double = self.isTen ? 1.1 : 1.08
        if self.isSolo {
            return Int(Double(self.cost) * rate)
        }
        else {
            return Int(Double(self.cost) * rate * Double(self.molecule) / Double(self.denominator))
        }
    }
}
