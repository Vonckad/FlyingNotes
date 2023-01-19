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
        let bar = UIToolbar()
        
//        let action = UIBarButtonItem(systemItem: UIBarButtonItem.SystemItem.action)
//        let edit = UIBarButtonItem(systemItem: UIBarButtonItem.SystemItem.edit)
//        let bookmarks = UIBarButtonItem(systemItem: UIBarButtonItem.SystemItem.bookmarks)
        let addImageBarItem = UIBarButtonItem(title: "image", style: UIBarButtonItem.Style.plain, target: nil, action: #selector(showPickerImage))
        bar.items = [addImageBarItem]
        
        bar.sizeToFit()
        textView.inputAccessoryView = bar
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
        if style == .detail {
            if let note = note {
                noteTextView.text = note.notes
                if let image = UIImage(data: note.imageData) {
                    addImageInTextView(image: image)
                }
            }
        }
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
        if let image = getImagesFromTextView().first, let imageData = image.pngData() {
            newNote.imageData = imageData
        }
        
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
    
    @objc
    private func showPickerImage() {
     let pickerImage = UIImagePickerController()
        pickerImage.modalPresentationStyle = .currentContext
        pickerImage.allowsEditing = true
        pickerImage.mediaTypes = ["public.image"]
        pickerImage.sourceType = .photoLibrary
        pickerImage.delegate = self
        present(pickerImage, animated: true)
    }
}

extension DetailNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        addImageInTextView(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func addImageInTextView(image: UIImage) {
        let textAttachment = NSTextAttachment(image: image)
        let oldWidth = textAttachment.image!.size.width
        let scaleFactor = oldWidth / (noteTextView.frame.size.width - 50)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        noteTextView.textStorage.insert(attrStringWithImage, at: noteTextView.selectedRange.location)
        noteTextView.font = .systemFont(ofSize: 24, weight: .regular)
    }
    
    private func getImagesFromTextView() -> [UIImage] {
        var imagesArray = [UIImage]()

        noteTextView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: noteTextView.attributedText.length), options: [], using: {(value,range,stop) -> Void in
                    if (value is NSTextAttachment) {
                        let attachment: NSTextAttachment? = (value as? NSTextAttachment)
                        var image: UIImage? = nil

                        if ((attachment?.image) != nil) {
                            image = attachment?.image
                        } else {
                            image = attachment?.image(forBounds: (attachment?.bounds)!, textContainer: nil, characterIndex: range.location)
                        }

                        if let image = image {
                          imagesArray.append(image)
                        }
                    }
                })
        return imagesArray
    }
}
