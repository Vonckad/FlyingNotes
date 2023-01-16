////
////  DataManager.swift
////  FlyingNotes
////
////  Created by Vlad Ralovich on 16.01.2023.
////
//
//import Foundation
//import UIKit
//import CoreData
//
//class DataManager {
//    
//    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    
//    static let shared = DataManager()
//    
//    init() {
//    
//    }
//    
//    func removeAllNotes() {
//        let item = NSBatchDeleteRequest(fetchRequest: .init(entityName: "Item"))
//        do {
//            try context.execute(item)
//        } catch {
//            print("Error")
//        }
//    }
//    
//    func removeNote(_ note: Note) {
//        context.delete(note)
//    }
//    
//    func addItem(note: Note) {
//        let item = Item(context: self.context)
//        item.title = note.title
//        item.notes = note.notes
//        item.dueDate = note.dueDate
//        self.saveItems()
//    }
//    
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) -> [Note] {
//        var result: [Note] = []
//        var tempRes: [Item] = []
//        do {
//            tempRes = try context.fetch(request)
//        }catch{
//            print("Error fetching data from context \(error)")
//        }
//        
//        for temp in tempRes {
//            result.append(Note(title: temp.title ?? "", dueDate: temp.dueDate ?? Date(), notes: temp.notes ?? ""))
//        }
//        
//        return result
//    }
//    
//    private func saveItems(){
//        do{
//            try context.save()
//        }catch {
//            print("Error saving context with \(error)")
//        }
//    }
//}
