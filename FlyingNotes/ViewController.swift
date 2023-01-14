//
//  ViewController.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 15.01.2023.
//

import UIKit

class ViewController: UIViewController {

    private lazy var notesCollectionView: UICollectionView = {
        
        let configurator = UICollectionViewCompositionalLayoutConfiguration()
        let size = NSCollectionLayoutSize(widthDimension: .estimated(1.0), heightDimension: .estimated(1.0))
        let group = NSCollectionLayoutGroup(layoutSize: size)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configurator)
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(notesCollectionView)
    }


}

