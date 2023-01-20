//
//  Images+CoreDataProperties.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 20.01.2023.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var note: Note?

}

extension Image : Identifiable {

}
