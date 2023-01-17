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
//        textView.delegate = self
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
//        title = style == .detail ? note?.title : "New"
        
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
            newNote.id = note?.id ?? UUID()
//            newNote.notes = "noteTextView.text noteTextView.text noteTextView.text noteTextView.text noteTextView.text noteTextView.text"
            newNote.notes = noteTextView.text//note?.title ?? ""//noteTextView.text
            newNote.createDate = Date()
            
            if let comptelion = self.comptelion {
                comptelion(newNote)
            }            

            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        }
    }
}
/*
extension DetailNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        var lineNumber = 0

        if textView.text!.contains(where: \.isNewline) && lineNumber == 0 {
            if let titleText = textView.text {
//                textView.attributedText = setupText(bolt: titleText, normal: "")
            }
            lineNumber = 1
        } else {
            if let noteText = textView.text {
//                textView.attributedText = setupText(bolt: "", normal: noteText)
            }
        }
//        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
//        note = Note(context: managedContext)
//        note?.id = UUID()
        
//        if !textView.text.isEmpty {
//
//            if let range = textView.text.range(of: "\n") {
//
//                let firstLine = textView.text[range]
//                textView.textStorage.setAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .bold)], range: NSRangeFromString(firstLine.base) )
////                self.note?.title = firstLine.base
//            }
//            else {
//                let length = textView.text.count
//                if length > 30 {
//                    let firstLine = textView.text.dropFirst(30)
//
////                    self.note?.notes = firstLine.base
//                } else {
//                    let firstLine = textView.text.dropFirst(length)
////                    self.note?.title = firstLine.base
//                }
//            }
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !textView.text.isEmpty {
            let attributedText = NSMutableAttributedString(attributedString: textView.attributedText!)

                   // Use NSString so the result of rangeOfString is an NSRange.
                   let text = textView.text! as NSString

            if let myRange = textView.text.range(of: "\n") {

                let firstLine = textView.text[myRange]
                
                // Find the range of each element to modify.
                let boldRange = text.range(of: firstLine.base)
               
                let boldFont = UIFont(name: "Helvetica-bold", size: 20.0) as Any
               
                // Handle bold
                attributedText.addAttribute(NSAttributedString.Key.font, value: boldFont, range: boldRange)
                
//                textView.textStorage.setAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 24, weight: .bold)], range: NSRangeFromString(firstLine.base) )
//                self.note?.title = firstLine.base
            }
            else {
                let length = textView.text.count
                if length > 30 {
                    let firstLine = textView.text.dropFirst(30)
                    // Handle small.
                    let smallRange = text.range(of: firstLine.base)
                    let smallFont = UIFont(name: "Helvetica", size: 11.0) as Any

                    attributedText.addAttribute(NSAttributedString.Key.font, value: smallFont, range: smallRange)
//                    textView.textStorage.setAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)], range: NSRangeFromString(firstLine.base) )
//                    self.note?.notes = firstLine.base
                } else {
                    let firstLine = textView.text.dropFirst(length)
//                    self.note?.title = firstLine.base
                }
            }
            textView.attributedText = attributedText
        }
        return true
    }
    
    private func setupText(bolt: String, normal: String) -> NSMutableAttributedString {
        
        let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
        let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
        let attributedString = NSMutableAttributedString(string: bolt, attributes: attributsBold)
        let normalStringPart = NSMutableAttributedString(string: normal, attributes: attributsNormal)
        attributedString.append(normalStringPart)
        
        return attributedString
    }
}
*/
