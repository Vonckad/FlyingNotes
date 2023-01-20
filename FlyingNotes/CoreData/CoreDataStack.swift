//
//  CoreDataStack.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 16.01.2023.
//

import CoreData

class CoreDataStack {
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext

    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func createNote(note: String) -> Note {
        let newNote = Note(context: managedContext)
        newNote.id = UUID()
        newNote.notes = note
        newNote.createDate = Date()
        return newNote
    }
    
    func createImage(imageData: Data, note: Note) {
        let image = Image(context: managedContext)
        image.imageData = imageData
        image.note = note
        note.addToImages(image)
    }
    
    func getNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: false)]
        var fetchedNotes: [Note] = []
        
        do {
            fetchedNotes = try managedContext.fetch(request)
        } catch let error {
            print("Error fetching notes \(error)")
        }
        return fetchedNotes
    }
    
    func getImages(note: Note) -> [Image] {
        let request: NSFetchRequest<Image> = Image.fetchRequest()
        request.predicate = NSPredicate(format: "note = %@", note)
        var fetchedImages: [Image] = []
        
        do {
            fetchedImages = try managedContext.fetch(request)
        } catch let error {
            print("Error fetching images \(error)")
        }
        return fetchedImages
    }
    
    func deleteImage(image: Image) {
        managedContext.delete(image)
        saveContext()
    }
    
    func deleteNote(note: Note) {
        managedContext.delete(note)
        saveContext()
    }
}
