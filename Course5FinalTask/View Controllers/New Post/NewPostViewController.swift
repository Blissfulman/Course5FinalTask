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
    
    /// Массив новых изображений.
    private var newImages = [UIImage]()
    
    /// Коллекция изображений для использования в новых публикациях.
    private lazy var newPostImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let numberOfColumns: CGFloat = 3
        let size = self.view.bounds.width / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            NewPostCollectionViewCell.nib(),
            forCellWithReuseIdentifier: NewPostCollectionViewCell.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    /// Количество колонок в представлении изображений.
    private let numberOfColumns: CGFloat = 3
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newImages = NewImagesProvider.shared.getNewImages()
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoadingView.show()
        newPostImagesCollectionView.reloadData()
        LoadingView.hide()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(newPostImagesCollectionView)
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            newPostImagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            newPostImagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newPostImagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newPostImagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Сollection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        newImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = newPostImagesCollectionView.dequeueReusableCell(
            withReuseIdentifier: NewPostCollectionViewCell.identifier, for: indexPath
        ) as! NewPostCollectionViewCell
        
        cell.configure(newImages[indexPath.item])
        return cell
    }
    
    // MARK: - Сollection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filtersVC = FiltersViewController(selectedImage: newImages[indexPath.item])
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}

// MARK: - Collection view layout

extension NewPostViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = newPostImagesCollectionView.bounds.width / numberOfColumns
        return CGSize(width: size, height: size)
    }
}
