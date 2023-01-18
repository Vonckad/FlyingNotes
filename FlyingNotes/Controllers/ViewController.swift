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
    private var notes: [Note] = {
        var notesArray: [Note] = []
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "First Launch") {
        
            defaults.set(true, forKey: "First Launch")
            
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let startNote = Note(context: managedContext)
            startNote.id = UUID()
            startNote.notes =
"""
Начало работы в приложении «FlyingNotes»

В приложении «FlyingNotes»  можно быстро записать свои мысли.
"""
            startNote.createDate = Date()
    
            notesArray.append(startNote)
    
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        }
        return notesArray
    }()
    
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
        addRightBarButtonItem()
        getNotes()
//        checkFirsLaunchApp()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.darkGray]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.darkGray]
        navigationController?.navigationBar.tintColor = .darkGray
    }
    
//MARK: - private
    private func addRightBarButtonItem() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        addButton.tintColor = .darkGray
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupLayout() {
        view.addSubview(notesCollectionView)
        notesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            notesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            notesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            notesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func getNotes() {
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
    
    @objc
    private func didPressAddButton(_ sender: UIButton) {
        let detail = DetailNoteViewController(style: .new) { [weak self] newNote in
            guard let self = self else { return }
            self.notes.insert(newNote, at: 0)
            self.updateSnapshot()
        }
        navigationController?.pushViewController(detail, animated: true)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func updateSnapshot(reloading ids: [Note.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(notes.map { $0.id })
        dataSource.apply(snapshot)
    }
    
    private func noteCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note.ID> {
        return .init { cell, _, item in
            let note = self.notes[self.notes.indexOfNote(with: item)]
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = note.notes
            configuration.secondaryText = note.createDate.dayAndTimeText
            configuration.secondaryTextProperties.color = .gray
            configuration.textProperties.color = .darkGray
            configuration.textProperties.numberOfLines = 3
            cell.contentConfiguration = configuration
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.cornerRadius = 8
            backgroundConfig.backgroundColor = .white
            cell.backgroundConfiguration = backgroundConfig
        }
    }
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = self.noteCellRegistration()
        return DataSource(collectionView: notesCollectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Note.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) { [weak self] _, _, _ in
            guard let self = self else { return }
            AppDelegate.sharedAppDelegate.coreDataStack.managedContext.delete(self.notes[indexPath.item])
            self.notes.remove(at: indexPath.item)
            self.updateSnapshot()
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
