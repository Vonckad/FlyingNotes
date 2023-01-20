//
//  ViewController.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 15.01.2023.
//

import UIKit
//import CoreData

class ViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Note.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Note.ID>
    
    private lazy var dataSource: DataSource = self.makeDataSource()
    private var notes: [Note] = {
        var notesArray: [Note] = []
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "First Launch") {
            defaults.set(true, forKey: "First Launch")
            
            let coreDataStack = AppDelegate.sharedAppDelegate.coreDataStack
            let startString =
"""
Начало работы в приложении «FlyingNotes»

В приложении «FlyingNotes»  можно быстро записать свои мысли.
"""
            let startNote = coreDataStack.createNote(note: startString)
            notesArray.append(startNote)
            coreDataStack.saveContext()
        }
        return notesArray
    }()
    
    private lazy var notesCollectionView: UICollectionView = {
        let listLayout = listLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: listLayout)
        collectionView.delegate = self
        return collectionView
    }()
    
    let bacgroundColor = UIColor.init(red: 243/255, green: 242/255, blue: 247/255, alpha: 1.0)
    
//MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bacgroundColor
        title = "Заметки"
        addRightBarButtonItem()
        getNotes()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = bacgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor : UIColor.black]
        navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.shadowImage = nil
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
        notes = AppDelegate.sharedAppDelegate.coreDataStack.getNotes()
        updateSnapshot()
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
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = bacgroundColor
        listConfiguration.separatorConfiguration.color = .gray
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func updateSnapshot(reloading ids: [Note.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(notes.map { $0.id })
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot)
    }
    
    private func noteCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note.ID> {
        return .init { cell, _, item in
            let note = self.notes[self.notes.indexOfNote(with: item)]
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = note.notes
            configuration.secondaryText = note.createDate.dayAndTimeText
            configuration.secondaryTextProperties.color = .gray
            configuration.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
            configuration.textProperties.font = UIFont.systemFont(ofSize: 20)
            configuration.textProperties.color = .black
            configuration.textProperties.numberOfLines = 1
            cell.contentConfiguration = configuration
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
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
            let deleteNote = self.notes[indexPath.item]
            AppDelegate.sharedAppDelegate.coreDataStack.deleteNote(note: deleteNote)
            self.notes.remove(at: indexPath.item)
            self.updateSnapshot()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        notesCollectionView.deselectItem(at: indexPath, animated: true)
        let detail = DetailNoteViewController(style: .detail, note: notes[indexPath.item])
        { [weak self] updatedNote in
            guard let self = self else { return }
            let index = self.notes.indexOfNote(with: updatedNote.id)
            self.notes[index] = updatedNote
            self.updateSnapshot(reloading: [updatedNote.id])
        }
        navigationController?.pushViewController(detail, animated: true)
    }
}
