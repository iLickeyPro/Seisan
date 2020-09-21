//
//  ContentView.swift
//  Seisan
//
//  Created by 野口 勇気 on 2020/09/15.
//  Copyright © 2020 Yuki Noguchi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var receipts = Receipts()
    @State private var isPresented: Bool = false
    @State private var inputTitle: String = ""
    @State private var inputType: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(receipts.receipts, id: \.id) { receipt in
                        NavigationLink(destination: SubContentView(
                                        receipt: receipt,
                                        receipts: receipts
                        ).environmentObject(receipts)) {
                            HStack(alignment: .bottom) {
                                Text(receipt.title)
                                Spacer()
                                Text("¥\(receipt.getTotalCost())")
                                    .font(.subheadline)
                            }
                            .padding(5.0)
                        }
                    }
                    .onDelete(perform: rowRemove)
                    Button(action: {self.isPresented.toggle()}) {
                        Text("＋レシートを追加").foregroundColor(Color.blue)
                    }
                }
                .navigationBarTitle("レシート")
                .navigationBarItems(trailing: EditButton())
                HStack {
                    Text("合計　¥\(totalCosts(receipts: receipts.receipts))")
                }
                Spacer()
            }
            .sheet(isPresented: $isPresented) {
                NavigationView {
                    Form {
                        TextField("タイトル", text: self.$inputTitle)
                        Toggle(isOn: self.$inputType) {
                            Text("税込み")
                        }
                    }
                    .navigationBarTitle("レシートを追加", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button(action: { self.isPresented.toggle() }) {
                            Text("Cancel").foregroundColor(Color.red)
                        },
                        trailing: Button(action: {
                            // Saveしたときの処理
                            Receipt.create(
                                title: self.inputTitle, type: self.inputType
                            )
                            self.inputTitle = ""
                            self.isPresented.toggle()
                            receipts.receipts = Receipt.all()
                        }) {
                            Text("Save").foregroundColor(Color.blue)
                        }
                    )
                }
            }
        }
    }
    
    func rowRemove(offsets: IndexSet) {
        let index: Int = offsets.map({Int($0)}).first!
        let receipt = receipts.receipts[index]
        receipts.receipts.remove(atOffsets: offsets)
        // 実データを削除するのは画面の表示が終わってから
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Receipt.remove(receipt: receipt)
        }
    }
    
    func totalCosts(receipts: [Receipt]) -> Int {
        var totalCosts = 0
        receipts.forEach { (receipt: Receipt) in
            totalCosts += receipt.getTotalCost()
        }
        return totalCosts
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// アイテムリスト画面
struct SubContentView: View {
    var receipt: Receipt
    
    @ObservedObject var receipts: Receipts
    @State private var items: [Item] = []
    @State private var cost_str: String = ""
    @State private var item_is_ten: Bool = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(items, id: \.id) { item in
                    HStack {
                        Text(String(item.getCost()))
                        Text(String(item.cost))
                            .font(.subheadline)
                            .padding(.leading, 3.0)
                        Spacer()
                        Button(action: {
                            item.isTen.toggle()
                            self.item_is_ten = item.isTen
                        }) {
                            item.isTen ? Text("10%") : Text("8%")
                        }
                    }
                }
                .onDelete(perform: rowRemove)
                TextField("＋金額を追加", text: $cost_str, onCommit: {
                    Item.create(
                        receipt: receipt,
                        cost: Int(self.cost_str) ?? 0,
                        isTen: false,
                        isSolo: false
                    )
                    items = receipt.getItems()
                    self.cost_str = ""
                })
                .keyboardType(.numbersAndPunctuation)
            }
            .navigationBarTitle(Text(receipt.title), displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
        }
        .onAppear {
            items = receipt.getItems()
        }
        .onDisappear {
            receipts.receipts = Receipt.all()
        }
    }
    
    func rowRemove(offsets: IndexSet) {
        let index: Int = offsets.map({Int($0)}).first!
        let item = items[index]
        items.remove(atOffsets: offsets)
        // 実データを削除するのは画面の表示が終わってから
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Item.remove(item: item)
        }
    }
}
