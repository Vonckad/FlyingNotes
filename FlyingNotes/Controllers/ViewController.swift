//
//  ViewController.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 15.01.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Note.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Note.ID>
    
    private lazy var dataSource: DataSource = self.makeDataSource()
    private var notes: [Note] = []
    
    private lazy var notesCollectionView: UICollectionView = {
        let listLayout = listLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: listLayout)
        collectionView.delegate = self
        return collectionView
    }()
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Заметки"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        getNotes()
        
        view.addSubview(notesCollectionView)
    }
    
    func getNotes() {
        let noteFetch: NSFetchRequest<Note> = Note.fetchRequest()
        let sortByDate = NSSortDescriptor(key: #keyPath(Note.createDate), ascending: false)
        noteFetch.sortDescriptors = [sortByDate]
        do {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let results = try managedContext.fetch(noteFetch)
            notes = results
            self.updateSnapshot()
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
//MARK: - private
    @objc
    private func didPressAddButton(_ sender: UIButton) {
        let detail = DetailNoteViewController(style: .new) { newNote in
            self.notes.insert(newNote, at: 0)
            self.updateSnapshot()
        }
        navigationController?.pushViewController(detail, animated: true)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(notes.map { $0.id })
        snapshot.reloadItems(notes.map { $0.id })
        dataSource.apply(snapshot)
    }
    
    private func noteCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note.ID> {
        return .init { cell, _, item in
            let note = self.notes[self.notes.indexOfNote(with: item)]
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = note.title
            configuration.secondaryText = note.createDate.dayAndTimeText
            configuration.textProperties.color = .darkGray
            cell.contentConfiguration = configuration
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.cornerRadius = 8
            cell.backgroundConfiguration = backgroundConfig
        }
    }
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = self.noteCellRegistration()
        return DataSource(collectionView: notesCollectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Note.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        notesCollectionView.deselectItem(at: indexPath, animated: true)
        
        let detail = DetailNoteViewController(style: .detail, note: notes[indexPath.item])
        navigationController?.pushViewController(detail, animated: true)
    }
}
