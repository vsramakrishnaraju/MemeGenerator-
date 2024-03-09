//
//  ViewController.swift
//  MemeGenerator
//
//  Created by Venkata on 3/8/24.
//

import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var images = [UIImage]()
    var text1 = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Meme Generator"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedImage = images[indexPath.item]
        shareTapped(tappedImage)
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        let alertController = UIAlertController(title: "Enter Top Text", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Type something here..."
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned alertController, weak self] _ in
            guard let responseText = alertController.textFields?[0].text, let self = self else { return }
            self.text1 = responseText
            let alertController2 = UIAlertController(title: "Enter Bottom Text", message: nil, preferredStyle: .alert)
            alertController2.addTextField { textField2 in
                textField2.placeholder = "Type something here..."
            }
            let submitAction2 = UIAlertAction(title: "Submit", style: .default) { [unowned alertController2, weak self] _ in
                guard let responseText2 = alertController2.textFields?[0].text, let self = self else { return }
                let newImage = self.drawImagesAndText(image: image, textTop: text1, texBottom: responseText2)
                self.images.insert(newImage, at: 0)
                self.collectionView.reloadData()
            }
            alertController2.addAction(submitAction2)
            present(alertController2, animated: true)
        }
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }
    
    func drawImagesAndText(image: UIImage, textTop: String, texBottom: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let img = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 200),
                .paragraphStyle: paragraphStyle
            ]
            
            let attributedString = NSAttributedString(string: textTop, attributes: attrs)
            attributedString.draw(with: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), options: .usesLineFragmentOrigin, context: nil)
            
            let attributedString2 = NSAttributedString(string: texBottom, attributes: attrs)
            attributedString2.draw(with: CGRect(x: 0, y: image.size.height-400, width: image.size.width, height: image.size.height), options: .usesLineFragmentOrigin, context: nil)
        }
        
        return img
    }
    
    @objc func shareTapped(_ img: UIImage) {
        guard let imageData = img.jpegData(compressionQuality: 0.75) else { return }
        let vc = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
}
