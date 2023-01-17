//
//  Note+CoreDataProperties.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 16.01.2023.
//
//

import Foundation
import CoreData
import UIKit

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var notes: String
    @NSManaged public var createDate: Date
    @NSManaged public var id: UUID
}

extension Note : Identifiable {

}

extension Array where Element == Note {
    func indexOfNote(with id: Note.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError()
        }
        return index
    }
}
