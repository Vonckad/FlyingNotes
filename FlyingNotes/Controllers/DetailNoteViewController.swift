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
        textView.font = .systemFont(ofSize: 20, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        textView.keyboardDismissMode = .onDrag
        textView.backgroundColor = .white
        textView.textColor = .darkGray
        textView.clipsToBounds = true
        textView.alwaysBounceVertical = true
        textView.delegate = self
        
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        let flexibleSpace = UIBarButtonItem(systemItem: UIBarButtonItem.SystemItem.flexibleSpace)
        let photoItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(showPickerImage))
        photoItem.tintColor = .darkGray
        bar.setItems([flexibleSpace, photoItem], animated: true)
        bar.sizeToFit()
        textView.inputAccessoryView = bar
        return textView
    }()
    
    let bacgroundColor = UIColor.init(red: 243/255, green: 242/255, blue: 247/255, alpha: 1.0)
    
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
        view.backgroundColor = bacgroundColor
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        if style == .detail {
            if let note = note {
                noteTextView.text = note.notes
                getImageFromNote(note: note)
            }
        }
        
        setupLayout()
        noteTextView.layoutManager.allowsNonContiguousLayout = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        noteTextView.layer.cornerRadius = 8
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if style == .new {
            noteTextView.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.isMovingFromParent || self.isBeingDismissed) {
            if style == .new && !noteTextView.text.isEmpty {
               createNewNote()
            } else if style == .detail {
                updateNote()
            }
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
        let coreDataStack = AppDelegate.sharedAppDelegate.coreDataStack
        
        let newNote = coreDataStack.createNote(note: noteTextView.text)//Note(context: managedContext)

        if !getImagesFromTextView().isEmpty {
            for image in getImagesFromTextView() {
                if let imageData = image.pngData() {
                    coreDataStack.createImage(imageData: imageData, note: newNote)
                }
            }
        }

        if let comptelion = self.comptelion {
            comptelion(newNote)
        }

        coreDataStack.saveContext()
    }
    
    private func updateNote() {
        guard let note = note else { return }
        note.notes = noteTextView.text
        let coreDataStack = AppDelegate.sharedAppDelegate.coreDataStack
        
        // нужно подумать над сравнением и удалением/добавлением отдельных image
        let oldNoteImages = coreDataStack.getImages(note: note)
        oldNoteImages.forEach { coreDataStack.deleteImage(image: $0)}
        
        if !getImagesFromTextView().isEmpty {
            for image in getImagesFromTextView() {
                if let imageData = image.pngData() {
                    coreDataStack.createImage(imageData: imageData, note: note)
                }
            }
        }
        
        if let comptelion = self.comptelion {
            comptelion(note)
        }
        coreDataStack.saveContext()
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

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
        noteTextView.font = .systemFont(ofSize: 20, weight: .regular)
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
    
    private func getImageFromNote(note: Note) {
        DispatchQueue.global().async {
            let imagesArray = AppDelegate.sharedAppDelegate.coreDataStack.getImages(note: note)
             for image in imagesArray {
                 if let imageData = image.imageData {
                     DispatchQueue.main.async {
                         if let im = UIImage(data: imageData) {
                             self.addImageInTextView(image: im)
                         }
                     }
                 }
             }
        }
    }
}

//MARK: - UITextViewDelegate
extension DetailNoteViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        textView.setContentOffset(CGPoint(x: 0, y: textView.center.y / 2), animated: true)
//        viewDidLayoutSubviews()
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        textView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        viewDidLayoutSubviews()
//    }
}
