//
//  FiltersViewController.swift
//  Course5FinalTask
//
//  Created by Evgeny Novgorodov on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Outlets
    
    /// Коллекция выбора фильтров с примерами их применения для обработки большого изображения.
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    /// Изображение, отображаемое на всю ширину экрана.
    private lazy var bigImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /// Исходное большое изображение.
    private lazy var originalBigImage = UIImage()
    
    /// Миниатюра выбранного изображения.
    private var thumbnailImage = UIImage()
    
    /// Массив для отфильтрованных миниатюр изображения
    private var filteredThumbnails = [UIImage]()
    
    /// Массив имён фильтров для обработки изображения.
    private let filters = [
        "CISpotLight", "CIPixellate", "CIUnsharpMask", "CISepiaTone",
        "CICircularScreen", "CICMYKHalftone", "CIVignetteEffect"
    ]
    
    // Константы размеров элементов коллекции фильтров.
    private let widthForItem: CGFloat = 130
    private let heightForItem: CGFloat = 79
    private let minimumLineSpacing: CGFloat = 16
    private let minimumInteritemSpacing: CGFloat = 0
    
    // MARK: - Initializers
    
    convenience init(selectedImage: UIImage) {
        self.init()
        bigImage.image = selectedImage
        originalBigImage = selectedImage
        thumbnailImage = originalBigImage.resizeImage()
        filteredThumbnails = .init(repeating: thumbnailImage, count: filters.count)
    }
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.register(FilterCell.nib(),
                                       forCellWithReuseIdentifier: FilterCell.identifier)
        filteringThumbnailImages()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Filters"
        let nextButton = UIBarButtonItem(
            title: "Next", style: .plain, target: self, action: #selector(pressedNextButton)
        )
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(bigImage)
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            bigImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bigImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bigImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bigImage.heightAnchor.constraint(equalTo: bigImage.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func pressedNextButton() {
        guard let image = bigImage.image,
              let imageData = image.pngData() else { return }
        
        let sharingVC = SharingViewController()
        sharingVC.viewModel = SharingViewModel(imageData: imageData)
        navigationController?.pushViewController(sharingVC, animated: true)
    }
    
    // MARK: - Applying filters to thumbnails
    
    private func filteringThumbnailImages() {
        
        let queue = OperationQueue()
        
        for item in 0..<filters.count {
            let filterOperation = FilterImageOperation(inputImage: thumbnailImage,
                                                       filter: filters[item])
            filterOperation.completionBlock = { [weak self] in
                
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    
                    guard let outputImage = filterOperation.outputImage else { return }
                    
                    self.filteredThumbnails[item] = outputImage
                    self.filtersCollectionView.reloadItems(at: [.init(item: item, section: 0)])
                }
            }
            queue.addOperation(filterOperation)
        }
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = filtersCollectionView.dequeueReusableCell(
            withReuseIdentifier: FilterCell.identifier, for: indexPath
        ) as! FilterCell
        
        cell.configure(photo: filteredThumbnails[indexPath.item],
                       filterName: filters[indexPath.item])
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        LoadingView.show()
        
        // Применение выбранного фильтра к большому изображению
        let queue = OperationQueue()
        let filterOperation = FilterImageOperation(inputImage: originalBigImage,
                                                   filter: filters[indexPath.item])
        filterOperation.completionBlock = { [weak self] in
                        
            DispatchQueue.main.async {
                guard let outputImage = filterOperation.outputImage else { return }
                
                self?.bigImage.image = outputImage
                LoadingView.hide()
            }
        }
        queue.addOperation(filterOperation)
    }
}

// MARK: - Collection view layout

extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: widthForItem, height: heightForItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacing
    }
}
