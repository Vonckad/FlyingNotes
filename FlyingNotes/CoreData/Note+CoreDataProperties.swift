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
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension Note {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

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
