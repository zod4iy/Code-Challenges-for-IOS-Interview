//
//  NoteDetailsViewController.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/14/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import UIKit

enum NoteDetailsPageMode {
    case view
    case add
    case edit
    
    var pageTitle: String {
        switch self {
        case .view: return "View Mode"
        case .add: return "Add Mode"
        case .edit: return "Edit Mode"
        }
    }
    
    var isShareButton: Bool {
        switch self {
        case .view: return true
        case .add, .edit: return false
        }
    }
    
    var isSaveButton: Bool {
        switch self {
        case .view: return false
        case .add, .edit: return true
        }
    }
}

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem! 
    
    // MARK: Dependencies
    private let coreDateService: CoreDataProtocol = CoreDataService.shared

    private var note: NoteMO?
    private var pageMode: NoteDetailsPageMode = .view {
        didSet {
            setupButtons()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch pageMode {
        case .add, .edit:
            textView.becomeFirstResponder()
        default:
            break
        }
    }
    
    static func viewControllerFromStoryboard() -> NoteDetailsViewController {
        let storyboard = UIStoryboard(name: NoteDetailsViewController.storyboardName, bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier:NoteDetailsViewController.identifier) as? NoteDetailsViewController
        else {
            fatalError("Can't load \(NoteDetailsViewController.identifier) from \(NoteDetailsViewController.storyboardName) storyboard")
        }
        
        return viewController
    }
    
    func config(with note: NoteMO?, pageMode: NoteDetailsPageMode) {
        self.note = note
        self.pageMode = pageMode
    }
    
    private func setupView() {
        title = pageMode.pageTitle
        textView.text = note?.text ?? ""
        shareButton.isEnabled = pageMode.isShareButton
        shareButton.tintColor = pageMode.isShareButton ? .defaultBlue : .clear
        saveButton.isEnabled = false
    }
    
    private func setupButtons() {
        shareButton.isEnabled = pageMode.isShareButton
        shareButton.tintColor = pageMode.isShareButton ? .defaultBlue : .clear
        saveButton.isEnabled = pageMode.isSaveButton
    }
    
    // MARK: ACtions
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        let context = coreDateService.managedObjectContext
        
        let note = self.note ?? NoteMO(entity: NoteMO.entity(), insertInto: context)
        note.text = textView.text
        note.date = Date() as NSDate
        
        coreDateService.saveContext()
        
        pageMode = .view
        textView.resignFirstResponder()
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        let textToShare = note?.text ?? ""
        let activityItems = textToShare.isEmpty ? [] : [textToShare]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
}

// MARK: - UITextViewDelegate

extension NoteDetailsViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        title = NoteDetailsPageMode.edit.pageTitle
        
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        pageMode = textView.text.count > 0 || !text.isEmpty ? .edit : .view

        return true
    }
}
