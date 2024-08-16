//
//  ALImagePickerViewController.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

internal let ImageCellIdentifier = "ImageCell"

internal let defaultItemSpacing: CGFloat = 1

public typealias PhotoLibraryViewSelectionComplete = (PHAsset?) -> Void
public typealias closeCompleted = () -> Void

public class PhotoLibraryViewController: UIViewController {
    
    internal var assets: [PHAsset] = []

    public var onSelectionComplete: PhotoLibraryViewSelectionComplete?
    public var closeBlock: closeCompleted?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        let buttonImage = UIImage(named: "close_nav_white", in: CameraGlobals.shared.bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: buttonImage,
                                                           style: UIBarButtonItem.Style.plain,
                                                           target: self,
                                                           action: #selector(dismissLibrary))
        navigationItem.title = "Photo album"
        view.backgroundColor = .black
        view.addSubview(collectionView)
        configCollectionViewConstraint()
        ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }
    
    /**
     * If the device is portrait, pin the SwapButton on the
     * right side of the CameraButton.
     * If landscape, pin the SwapButton on the top of the
     * CameraButton.
     */
    func configCollectionViewConstraint() {
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints for topMaskView
        let leftConstraint = NSLayoutConstraint(
            item: collectionView,
            attribute: .left,
            relatedBy: .equal,
            toItem: view,
            attribute: .left,
            multiplier: 1.0,
            constant: 0
        )
        let trailingConstraint = NSLayoutConstraint(
            item: collectionView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )
        let topConstraint = NSLayoutConstraint(
            item: collectionView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view.safeAreaLayoutGuide,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )
        let bottomConstraint = NSLayoutConstraint(
            item: collectionView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view.safeAreaLayoutGuide,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0  // Fixed height of 116
        )
        view.addConstraints([topConstraint, trailingConstraint, leftConstraint, bottomConstraint])
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    public func present(_ inViewController: UIViewController, animated: Bool) {
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        inViewController.present(navigationController, animated: animated, completion: nil)
    }
    
    @objc public func dismissLibrary() {
        onSelectionComplete?(nil)
        if let block = self.closeBlock {
            block()
        }
    }
    
    private func onSuccess(_ photos: PHFetchResult<PHAsset>) {
        assets = photos.objects(at: IndexSet(integersIn: 0..<photos.count))
        configureCollectionView()
    }
    
    private func onFailure(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        permissionsView.titleLabel.text = localizedString("permissions.library.title")
        permissionsView.descriptionLabel.text = localizedString("permissions.library.description")
        view.addSubview(permissionsView)
    }
    
    private func configureCollectionView() {
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CameraGlobals.shared.photoLibraryThumbnailSize
        layout.minimumInteritemSpacing = defaultItemSpacing
        layout.minimumLineSpacing = defaultItemSpacing
        layout.sectionInset = UIEdgeInsets.zero
      
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    internal func itemAtIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        return assets[indexPath.row]
    }
    
    deinit {
        print("=== talkme \(PhotoLibraryViewController.self) dealloc");
    }
    
}

// MARK: - UICollectionViewDataSource -
extension PhotoLibraryViewController : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is ImageCell {
            if let model = itemAtIndexPath(indexPath) {
                (cell as! ImageCell).configureWithModel(model)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ImageCellIdentifier, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate -
extension PhotoLibraryViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectionComplete?(itemAtIndexPath(indexPath))
    }
}
