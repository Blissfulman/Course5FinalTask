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
    
    @IBOutlet private weak var filtersCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    var viewModel: FiltersViewModelProtocol
    
    /// Изображение, отображаемое на всю ширину экрана.
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initializers
    
    init(viewModel: FiltersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifeсycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupViewModelBindings()
        
        filtersCollectionView.register(FilterCell.nib(),
                                       forCellWithReuseIdentifier: FilterCell.identifier)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Filters"
        
        let nextButton = UIBarButtonItem(
            title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped)
        )
        navigationItem.rightBarButtonItem = nextButton
        
        view.addSubview(imageView)
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func nextButtonTapped() {
        let sharingVC = SharingViewController(viewModel: viewModel.getSharingViewModel())
        navigationController?.pushViewController(sharingVC, animated: true)
    }
    
    // MARK: - Private methods
    
    private func setupViewModelBindings() {
        viewModel.image.bind { [unowned self] image in
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: image)
            }
        }
        
        viewModel.thumbnailDidFilter = { [unowned self] index in
            DispatchQueue.main.async {
                self.filtersCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = filtersCollectionView.dequeueReusableCell(
            withReuseIdentifier: FilterCell.identifier, for: indexPath
        ) as! FilterCell
        
        let cellData = viewModel.getCellData(at: indexPath)
        
        cell.configure(imageData: cellData.thumbnail, filterName: cellData.filterName)
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.applyFilter(at: indexPath)
    }
}

// MARK: - Collection view layout

extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    
    private var widthForItem: CGFloat { 130 }
    private var heightForItem: CGFloat { 80 }
    private var minimumLineSpacing: CGFloat { 16 }
    private var minimumInteritemSpacing: CGFloat { 0 }
    
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
