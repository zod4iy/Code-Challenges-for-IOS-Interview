//
//  ViewController.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/14/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import UIKit
import CoreData

private struct Constants {
    static let title = "Notes"
    static let cancel = "Cancel"
    static let paginationLimit = 20
}

private enum SortMode: String {
    case alphabet = "Alphabet"
    case dateAscending = "Date Ascending"
    case dateDescending = "Date Descending"
    
    var request: NSFetchRequest<NoteMO> {
        let request: NSFetchRequest<NoteMO> = NoteMO.fetchRequest()
        request.fetchLimit = Constants.paginationLimit
        
        switch self {
        case .alphabet:
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(NoteMO.text), ascending: true)]
        case .dateAscending:
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(NoteMO.date), ascending: true)]
        case .dateDescending:
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(NoteMO.date), ascending: false)]
        }
        
        return request
    }
}

class NotesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Dependencies
    private let coreDateService: CoreDataProtocol = CoreDataService.shared
    
    private var fetchedResultsController: NSFetchedResultsController<NoteMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let request = buildRequest()
        buildFetchResultController(with: request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    private func setupView() {
        title = Constants.title
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: NoteCell.nibName, bundle: Bundle.main), forCellReuseIdentifier: NoteCell.identifier)
    }
    
    private func buildAndReloadTableView(with text: String? = nil, request: NSFetchRequest<NoteMO>? = nil) {
        let fetchRequest = request ?? buildRequest(for: text)
        buildFetchResultController(with: fetchRequest)
        tableView.reloadData()
    }
    
    private func buildRequest(for text: String? = nil,
                              sortByDateAscending ascending: Bool = false,
                              fetchLimit: Int = Constants.paginationLimit) -> NSFetchRequest<NoteMO> {
        
        let request: NSFetchRequest<NoteMO> = NoteMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(NoteMO.date), ascending: ascending)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = fetchLimit
        
        if let text = text, !text.isEmpty {
            request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", text)
        }
        
        return request
    }
    
    private func buildFetchResultController(with request: NSFetchRequest<NoteMO>) {
        let context = coreDateService.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Can not fetch \(error.localizedDescription)")
        }
    }
    
    // MARK: Actions
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let noteDetailsViewController = NoteDetailsViewController.viewControllerFromStoryboard()
        noteDetailsViewController.config(with: nil, pageMode: .add)
        navigationController?.pushViewController(noteDetailsViewController, animated: true)
    }
    
    @IBAction func sortAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let alphabet = UIAlertAction(title: SortMode.alphabet.rawValue, style: .default) {  _ in
            self.buildAndReloadTableView(request: SortMode.alphabet.request)
        }
        
        let dateAscending = UIAlertAction(title: SortMode.dateAscending.rawValue, style: .default) { _ in
            self.buildAndReloadTableView(request: SortMode.dateAscending.request)
        }
        
        let dateDescending = UIAlertAction(title: SortMode.dateDescending.rawValue, style: .default) { _ in
            self.buildAndReloadTableView(request: SortMode.dateDescending.request)
        }
        
        let cancel = UIAlertAction(title: Constants.cancel, style: .cancel)
        
        [alphabet, dateAscending, dateDescending, cancel].forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let objects = fetchedResultsController.fetchedObjects
            else { fatalError("PerformFetch: hasn't been called") }
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell
        else {
            return UITableViewCell()
        }
        
        let noteMO = fetchedResultsController.object(at: indexPath)
        cell.config(with: noteMO.model)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let note = fetchedResultsController.object(at: indexPath)
        
        let noteDetail = NoteDetailsViewController.viewControllerFromStoryboard()
        noteDetail.config(with: note, pageMode: .view)
        
        navigationController?.pushViewController(noteDetail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title:  "", handler: { [weak self] (action, view, success) in
            guard let `self` = self else { return }
            
            let note = self.fetchedResultsController.object(at: indexPath)
            self.coreDateService.managedObjectContext.delete(note)
            self.coreDateService.saveContext()
            
            success(true)
        })
        
        deleteAction.image = #imageLiteral(resourceName: "delete")
        
        let editAction = UIContextualAction(style: .normal, title:  "", handler: { [weak self] (action, view, success) in
            let note = self?.fetchedResultsController.object(at: indexPath)
            let noteDetail = NoteDetailsViewController.viewControllerFromStoryboard()
            noteDetail.config(with: note, pageMode: .edit)
            
            self?.navigationController?.pushViewController(noteDetail, animated: true)
            
            success(true)
        })
        
        editAction.image = #imageLiteral(resourceName: "edit")
        editAction.backgroundColor = .blue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

// MARK: - Pagination

extension NotesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > (contentHeight - frameHeight) {

            if let notesCount = fetchedResultsController.fetchedObjects?.count {

                let request = fetchedResultsController.fetchRequest
                request.fetchLimit += Constants.paginationLimit

                buildFetchResultController(with: request)

                if let newNotesCount = fetchedResultsController.fetchedObjects?.count,
                    newNotesCount > notesCount {
                    let indexPaths = (notesCount..<newNotesCount).enumerated().map {_, row in IndexPath(row: row, section: 0)}

                    if let indexPath = indexPaths.first {
                        tableView.insertRows(at: indexPaths, with: .automatic)
                        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension NotesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text ?? ""
        buildAndReloadTableView(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        buildAndReloadTableView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        buildAndReloadTableView(with: searchText)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension NotesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteCell {
                let note = fetchedResultsController.object(at: indexPath)
                cell.config(with: note.model)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteCell  {
                let note = fetchedResultsController.object(at: indexPath)
                cell.config(with: note.model)
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
