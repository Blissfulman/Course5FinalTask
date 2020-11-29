//
//  NewPostViewController.swift
//  Course3FinalTask
//
//  Created by User on 01.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {
    
    // MARK: - Properties
    /// Блокирующее вью, отображаемое во время ожидания получения данных.
    private lazy var blockView = BlockView(parentView: self.tabBarController?.view ?? self.view)
        
    /// Количество колонок в представлении фотографий.
    private let numberOfColumnsOfPhotos: CGFloat = 3
    
    /// Массив новых фотографий.
    private var newPhotos = [UIImage]()
    
    /// Массив миниатюр новых фотографий.
    private var thumbnailsOfPhotos = [UIImage]()
    
    /// Коллекция изображений для использования в новых публикациях.
    private lazy var photosForNewPostCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let numberOfColumns: CGFloat = 3
        let size = self.view.bounds.width / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewPostCollectionViewCell.nib(),
                                forCellWithReuseIdentifier: NewPostCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        blockView.show()
        getNewPhotos()
        photosForNewPostCollectionView.reloadData()
        blockView.hide()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(photosForNewPostCollectionView)
    }
    
    // MARK: - Setup layout
    private func setupLayout() {
        let constraints = [
            photosForNewPostCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            photosForNewPostCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosForNewPostCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photosForNewPostCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - СollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosForNewPostCollectionView.dequeueReusableCell(withReuseIdentifier: NewPostCollectionViewCell.identifier, for: indexPath) as! NewPostCollectionViewCell
        cell.configure(newPhotos[indexPath.item])
        return cell
    }
    
    // MARK: - СollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filtersVC = FiltersViewController(selectedImage: newPhotos[indexPath.item],
                                              thumbnail: thumbnailsOfPhotos[indexPath.item])
        navigationController?.pushViewController(filtersVC, animated: true)
    }
}

// MARK: - CollectionViewLayout
extension NewPostViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = photosForNewPostCollectionView.bounds.width / numberOfColumnsOfPhotos
        return CGSize(width: size, height: size)
    }
}

// MARK: - Data recieving methods
extension NewPostViewController {
    
    /// Получение изображений для использования в новых публикациях.
    func getNewPhotos() {
//        newPhotos = DataProviders.shared.photoProvider.photos()
//        thumbnailsOfPhotos = DataProviders.shared.photoProvider.thumbnailPhotos()
    }
}
