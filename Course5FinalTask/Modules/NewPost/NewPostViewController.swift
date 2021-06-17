//
//  NewPostViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 01.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: NewPostViewModelProtocol = NewPostViewModel()
    
    private let numberOfColumns: CGFloat = 3
    
    /// Коллекция изображений для использования в новых публикациях.
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let size = UIScreen.main.bounds.width / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewPhotoCell.nib(), forCellWithReuseIdentifier: NewPhotoCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        setupUI()
        setupLayout()
    }
    
    // MARK: - Actions
    
    @objc private func openGalleryButtonTapped() {
        present(imagePickerController, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        addOpenGalleryButton()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        view.addSubview(imagesCollectionView)
    }
    
    private func addOpenGalleryButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "photo.on.rectangle.angled"),
            style: .plain,
            target: self,
            action: #selector(openGalleryButtonTapped)
        )
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            imagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Сollection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = imagesCollectionView.dequeueReusableCell(
            withReuseIdentifier: NewPhotoCell.identifier, for: indexPath
        ) as! NewPhotoCell
        
        cell.configure(viewModel.getCellData(at: indexPath))
        return cell
    }
    
    // MARK: - Сollection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filtersVC = FiltersViewController(viewModel: viewModel.getFiltersViewModel(at: indexPath))
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}

// MARK: - Image picker controller delegate

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        defer { imagePickerController.dismiss(animated: true) }
        guard let image = info[.editedImage] as? UIImage,
              let imageData = image.pngData() else { return }
        let filtersVC = FiltersViewController(viewModel: viewModel.getFiltersViewModel(withImageData: imageData))
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}
