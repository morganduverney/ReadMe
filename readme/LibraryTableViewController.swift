//
//  LibraryTableViewController.swift
//  readme
//
//  Created by Morgan Edmonds on 5/8/21.
//

import UIKit

enum SortStyle {
  case title
  case author
  case readMe
}

enum Section: String, CaseIterable {
  case addNew
  case readMe = "Read Me"
  case finished = "Finished"
}

class LibraryHeaderView: UITableViewHeaderFooterView {
  static let reuseIdentifier = "\(LibraryHeaderView.self)"
  @IBOutlet var headerTitleLabel: UILabel!
}

class LibraryTableViewController: UITableViewController {
    
  @IBOutlet var sortButtons: [UIBarButtonItem]!
  
  @IBAction func sortByTitle(_ sender: UIBarButtonItem) {
    dataSource.update(sortStyle: .title)
    updateTintColor(tappedButton: sender)
  }
  
  @IBAction func sortByAuthor(_ sender: UIBarButtonItem) {
    dataSource.update(sortStyle: .author)
    updateTintColor(tappedButton: sender)
  }
  
  @IBAction func sortByReadMe(_ sender: UIBarButtonItem) {
    dataSource.update(sortStyle: .readMe)
    updateTintColor(tappedButton: sender)
  }
  
  @IBSegueAction func showDetailView(_ coder: NSCoder) -> DetailViewController? {
    guard let indexPath = tableView.indexPathForSelectedRow, let book = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
    return DetailViewController(coder: coder, book: book)
  }
  
  func updateTintColor(tappedButton: UIBarButtonItem) {
    sortButtons.forEach { button in
      button.tintColor = button == tappedButton ? button.customView?.tintColor : .secondaryLabel
    }
  }
  var dataSource: LibraryDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = editButtonItem
    
    tableView.register(UINib(nibName: "\(LibraryHeaderView.self)", bundle: nil), forHeaderFooterViewReuseIdentifier: LibraryHeaderView.reuseIdentifier)
    configureDataSource()
    dataSource.update(sortStyle: .readMe)
    print(FileManager.documentDirectoryURL)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dataSource.update(sortStyle: dataSource.currentSortSyle)
  }
  
  // MARK:- Delegate
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 1 ? "Read Me" : nil
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 { return nil }
    
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: LibraryHeaderView.reuseIdentifier) as? LibraryHeaderView else { return nil }
    headerView.headerTitleLabel.text = Section.allCases[section].rawValue
    return headerView
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section != 0 ? 60 : 0
  }
  
  // MARK:- Data Source
  func configureDataSource() {
    dataSource = LibraryDataSource(tableView: tableView) { tableView, indexPath, book -> UITableViewCell? in
      if indexPath == IndexPath(row: 0, section: 0) {
        return tableView.dequeueReusableCell(withIdentifier: "NewBookCell", for: indexPath
        )
      } else {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BookCell.self)", for: indexPath) as? BookCell else { fatalError() }
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        cell.bookThumbnail.image = book.image ?? LibrarySymbol.letterSquare(letter: book.title.first).image
        cell.bookThumbnail.layer.cornerRadius = 12
        if let review = book.review {
          cell.reviewLabel.text = review
        }
        cell.bookmark.isHidden = !book.readMe
        return cell
      }
    }
  }
}

class LibraryDataSource: UITableViewDiffableDataSource<Section, Book> {
  var currentSortSyle: SortStyle = .title
  
  func update(animatingDifferences: Bool = true, sortStyle: SortStyle) {
    currentSortSyle = sortStyle
    
    var newSnapshot = NSDiffableDataSourceSnapshot<Section, Book>()
    newSnapshot.appendSections(Section.allCases)
    let booksByReadMe: [Bool: [Book]] = Dictionary(grouping: Library.books, by: \.readMe)
    for (readMe, books) in booksByReadMe {
      var sortedBooks: [Book]
      switch sortStyle {
      case .title:
        sortedBooks = books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending}
      case .author:
        sortedBooks = books.sorted { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending}
      case .readMe:
        sortedBooks = books
      }
      newSnapshot.appendItems(sortedBooks, toSection: readMe ? .readMe : .finished)
    }
    newSnapshot.appendItems([Book.mockBook], toSection: .addNew)
    apply(newSnapshot, animatingDifferences: animatingDifferences)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    indexPath.section == snapshot().indexOfSection(.addNew) ? false : true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let book = self.itemIdentifier(for: indexPath) else {return}
      Library.delete(book: book)
      update(sortStyle: currentSortSyle)
    }
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section != snapshot().indexOfSection(.readMe) && currentSortSyle == .readMe {
      return false
    } else {
      return true
    }
  }

  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    guard
      sourceIndexPath != destinationIndexPath,
      sourceIndexPath.section == destinationIndexPath.section,
      let bookToMove = itemIdentifier(for: sourceIndexPath),
      let bookAtDestination = itemIdentifier(for: destinationIndexPath)
    else {
      apply(snapshot(), animatingDifferences: false)
      return
    }
    Library.reorderBooks(bookToMove: bookToMove, bookAtDestination: bookAtDestination)
    update(animatingDifferences: false, sortStyle: self.currentSortSyle)
  }
}
