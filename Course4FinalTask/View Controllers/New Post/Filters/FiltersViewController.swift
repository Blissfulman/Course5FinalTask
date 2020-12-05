//
//  FiltersViewController.swift
//  Course4FinalTask
//
//  Created by User on 04.10.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - IB Outlets
    /// Коллекция выбора фильтров с примерами их применения для обработки большого изображения.
    @IBOutlet weak var filtersCollectionView: UICollectionView!

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
    private let filters = ["CISpotLight", "CIPixellate", "CIUnsharpMask",
        "CISepiaTone", "CICircularScreen", "CICMYKHalftone", "CIVignetteEffect"]
    
    // Константы размеров элементов коллекции фильтров.
    private let widthForItem: CGFloat = 130
    private let heightForItem: CGFloat = 79
    private let minimumLineSpacing: CGFloat = 16
    private let minimumInteritemSpacing: CGFloat = 0
    
    // MARK: - Initializers
    convenience init(selectedImage: UIImage, thumbnail: UIImage) {
        self.init()
        bigImage.image = selectedImage
        originalBigImage = selectedImage
        thumbnailImage = thumbnail
        filteredThumbnails = .init(repeating: thumbnailImage,
                                   count: filters.count)
    }
    
    // MARK: - Lifeсycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        setupUI()
        setupLayout()

        filtersCollectionView.dataSource = self
        filtersCollectionView.delegate = self
        filtersCollectionView.register(FiltersCollectionViewCell.nib(),
                                       forCellWithReuseIdentifier: FiltersCollectionViewCell.identifier)
        filteringThumbnailImages()
    }
    
    // MARK: - Setup UI
    func setupUI() {
        let nextButton = UIBarButtonItem(title: "Next",
                                         style: .plain,
                                         target: self,
                                         action: #selector(pressedNextButton))
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(bigImage)
    }
    
    // MARK: - Setup layout
    private func setupLayout() {
        let constraints = [
            bigImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bigImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bigImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bigImage.heightAnchor.constraint(equalTo: bigImage.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Applying filters to thumbnails
    func filteringThumbnailImages() {
        
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
    
    // MARK: - Actions
    @objc func pressedNextButton() {
        guard let image = bigImage.image else { return }
        let shareVC = ShareViewController(transmittedImage: image)
        navigationController?.pushViewController(shareVC, animated: true)
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollectionView.dequeueReusableCell(withReuseIdentifier: FiltersCollectionViewCell.identifier, for: indexPath) as! FiltersCollectionViewCell
        cell.configure(photo: filteredThumbnails[indexPath.item],
                       filterName: filters[indexPath.item])
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        LoadingView.show()
        
        // Применение выбранного фильтра к большому изображению
        let queue = OperationQueue()
        let filterOperation = FilterImageOperation(inputImage: originalBigImage,
                                                   filter: filters[indexPath.item])
        filterOperation.completionBlock = { [weak self] in
            
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                
                guard let outputImage = filterOperation.outputImage else { return }
                
                self.bigImage.image = outputImage
                LoadingView.hide()
            }
        }
        queue.addOperation(filterOperation)
    }
}

// MARK: - CollectionViewLayout
extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthForItem, height: heightForItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
}
