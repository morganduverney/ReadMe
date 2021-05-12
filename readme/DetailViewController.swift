//
//  DetailViewController.swift
//  readme
//
//  Created by Morgan Edmonds on 5/8/21.
//

import UIKit

class DetailViewController: UITableViewController {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var authorLabel: UILabel!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var reviewTextView: UITextView!
  @IBOutlet var readMeButton: UIButton!
  
  var book: Book
  
  @IBAction func updateImage() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
      ? .camera
      : .photoLibrary
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true)
  }
  
  @IBAction func toggleReadMe() {
    book.readMe.toggle()
    let image = book.readMe ? LibrarySymbol.bookmarkFill.image : LibrarySymbol.bookmark.image
    readMeButton.setImage(image, for: .normal)
  }
  
  @IBAction func saveBook() {
    Library.update(book: book)
    navigationController?.popViewController(animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleLabel.text = book.title
    authorLabel.text = book.author
    imageView.image = book.image ?? LibrarySymbol.letterSquare(letter: book.title.first).image
    imageView.layer.cornerRadius = 16
    
    if let review = book.review {
      reviewTextView.text = review
    }
    reviewTextView.addDoneButton()
    
    let image = book.readMe ? LibrarySymbol.bookmarkFill.image : LibrarySymbol.bookmark.image
    readMeButton.setImage(image, for: .normal)
  }
  
  init?(coder: NSCoder, book: Book) {
    self.book = book
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let selectedImage = info[.editedImage] as? UIImage else { return }
    imageView.image = selectedImage
    book.image = selectedImage
    dismiss(animated: true)
  }
}

extension DetailViewController: UITextViewDelegate {
  func textViewDidEndEditing(_ textView: UITextView) {
    book.review = reviewTextView.text
    textView.resignFirstResponder()
  }
}

extension UITextView {
  func addDoneButton() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
    toolbar.items = [flexSpace, doneButton]
    self.inputAccessoryView = toolbar
  }
}
