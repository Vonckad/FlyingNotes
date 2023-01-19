//
//  DetailNoteViewController.swift
//  FlyingNotes
//
//  Created by Vlad Ralovich on 16.01.2023.
//

import Foundation
import UIKit

class DetailNoteViewController: UIViewController {
    
    enum DetailStyle {
        case new, detail
    }
    
    private var style: DetailStyle
    private var note: Note?
    private var comptelion: ((Note) -> ())? = nil
    
    private lazy var noteTextView: UITextView = {
        let textView = UITextView(frame: view.bounds)
        textView.font = .systemFont(ofSize: 24, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        textView.keyboardDismissMode = .onDrag
        textView.backgroundColor = .white
        textView.textColor = .darkGray
        textView.clipsToBounds = true
        textView.alwaysBounceVertical = true
        return textView
    }()
    
//MARK: - LifeCycle
    init(style: DetailStyle, note: Note? = nil, comptelion: ((Note) -> ())? = nil) {
        self.style = style
        self.comptelion = comptelion
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        noteTextView.text = style == .detail ? note?.notes : ""
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if style == .new {
            noteTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if style == .new && !noteTextView.text.isEmpty {
           createNewNote()
        } else {
            updateNote()
        }
    }
    
//MARK: - private
    private func setupLayout() {
        view.addSubview(noteTextView)
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noteTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func createNewNote() {
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        let newNote = Note(context: managedContext)
        newNote.id = note?.id ?? UUID()
        newNote.notes = noteTextView.text
        newNote.createDate = Date()
        
        if let comptelion = self.comptelion {
            comptelion(newNote)
        }

        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
    }
    
    private func updateNote() {
        guard let note = note else { return }
        note.notes = noteTextView.text
        
        if let comptelion = self.comptelion {
            comptelion(note)
        }
        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
    }
}
