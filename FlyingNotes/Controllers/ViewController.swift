//
//  ViewController.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 15.01.2023.
//

import UIKit

class ViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Note>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Note>
    
    private lazy var dataSource: DataSource = self.makeDataSource()
    private var notes = Note.sampleData
    
    private lazy var notesCollectionView: UICollectionView = {
        let listLayout = listLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: listLayout)
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Заметки"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        
        DataManager.shared.addItem(note: Note.sampleData[0])
        
        updateSnapshot()
        view.addSubview(notesCollectionView)
    }
    
    @objc
    private func didPressAddButton(_ sender: UIButton) {
        DataManager.shared.addItem(note: Note.sampleData[1])
        updateSnapshot()
        let detail = UIViewController()
        detail.view.backgroundColor = .red
        detail.title = "new"
        navigationController?.pushViewController(detail, animated: true)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(DataManager.shared.loadItems())
        dataSource.apply(snapshot)
    }
    
    private func noteCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note> {
        return .init { cell, _, item in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            configuration.secondaryText = item.dueDate.dayAndTimeText
            configuration.textProperties.color = .darkGray
            cell.contentConfiguration = configuration
            
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.cornerRadius = 8
            cell.backgroundConfiguration = backgroundConfig
        }
    }
    
    private func makeDataSource() -> DataSource {
        let cellRegistration = self.noteCellRegistration()
        return DataSource(collectionView: notesCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        notesCollectionView.deselectItem(at: indexPath, animated: true)
        
        let detail = UIViewController()
        detail.view.backgroundColor = .green
        detail.title = notes[indexPath.item].title
        navigationController?.pushViewController(detail, animated: true)
    }
}
