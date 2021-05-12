//
//  AddBookTableViewController.swift
//  readme
//
//  Created by Morgan Edmonds on 5/9/21.
//

import UIKit

class AddBookTableViewController: UITableViewController {
  @IBOutlet var titleTextField: UITextField!
  @IBOutlet var authorTextField: UITextField!
  @IBOutlet var imageView: UIImageView!
  
  var newBookImage: UIImage?
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
      
  @IBAction func saveNewBook() {
    guard let title = titleTextField.text,
          let author = authorTextField.text,
          !title.isEmpty,
          !author.isEmpty else {return}
    let newBook = Book(title: title, author: author, readMe: true, image: newBookImage)
    Library.addNew(book: newBook)
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func addImage() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
      ? .camera
      : .photoLibrary
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true)
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.layer.cornerRadius = 16
  }
}

extension AddBookTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let selectedImage = info[.editedImage] as? UIImage else { return }
    imageView.image = selectedImage
    newBookImage = selectedImage
    dismiss(animated: true)
  }
}

extension AddBookTableViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == titleTextField {
      return authorTextField.becomeFirstResponder()
    } else {
      return textField.resignFirstResponder()
    }
  }
}
