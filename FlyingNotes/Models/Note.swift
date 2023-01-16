////
////  Note.swift
////  FlyingNotes
////
////  Created by Vlad Ralovich on 15.01.2023.
////
//
//import Foundation
//
//struct Note: Equatable, Hashable {
////    var id: String = UUID().uuidString
//    var title: String
//    var dueDate: Date
//    var notes: String? = nil
//}
//
////extension Array where Element == Note {
////    func indexOfRNote(with id: Note.ID) -> Self.Index {
////        guard let index = firstIndex(where: { $0.id == id }) else {
////            fatalError()
////        }
////        return index
////    }
////}
//
//#if DEBUG
//extension Note {
//    static var sampleData = [
//        Note(title: "Первая заметка", dueDate: Date().addingTimeInterval(800.0), notes: "Первая заметкаПервая заметкаПервая заметкаПервая заметкаПервая заметкаПервая заметкаПервая заметкаПервая заметкаПервая заметка"),
//        Note(title: "Втарая заметка", dueDate: Date().addingTimeInterval(14000.0), notes: "Втарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметкаВтарая заметка"),
//        Note(title: "Третья заметка", dueDate: Date().addingTimeInterval(24000.0), notes: "Третья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметкаТретья заметка"),
//        Note(title: "Четвертая заметка", dueDate: Date().addingTimeInterval(3200.0), notes: "Четвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметкаЧетвертая заметка"),
//    ]
//}
//#endif
//
