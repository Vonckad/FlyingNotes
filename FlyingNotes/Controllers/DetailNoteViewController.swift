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
        textView.font = .systemFont(ofSize: 24, weight: .bold)
        textView.keyboardDismissMode = .onDrag
        textView.delegate = self
        textView.clipsToBounds = true
        textView.alwaysBounceVertical = true
        return textView
    }()
    
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
        view.addSubview(noteTextView)
        if style == .new {
            noteTextView.becomeFirstResponder()
        }
        
        noteTextView.text = style == .detail ? note?.notes : ""
        title = style == .detail ? note?.title : "New"
        
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            noteTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if style == .new {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let newNote = Note(context: managedContext)
            newNote.id = UUID()
            newNote.notes = "noteTextView.text noteTextView.text noteTextView.text noteTextView.text noteTextView.text noteTextView.text"
            newNote.title = noteTextView.text
            newNote.createDate = Date()
            
            if let comptelion = self.comptelion {
                comptelion(newNote)
            }            

            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        }
    }
}

extension DetailNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        var lineNumber = 0
        
        if textView.text!.contains(where: \.isNewline) && lineNumber == 0 {
            textView.font = .systemFont(ofSize: 24, weight: .regular)
            lineNumber = 1
        } else {
            textView.font = .systemFont(ofSize: 24, weight: .bold)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        resignFirstResponder()
    }
}
