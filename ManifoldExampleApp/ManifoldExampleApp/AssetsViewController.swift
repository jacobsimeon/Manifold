//
//  AssetsViewController.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/21/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import AVKit

class AssetsViewController : UIViewController {
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.register(
      AssetCollectionViewCell.self,
      forCellWithReuseIdentifier: "\(AssetCollectionViewCell.self)"
    )

    view.backgroundColor = .white
    return view
  }()

  var assets: [Asset]?

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    navigationItem.title = "Assets"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addAsset)
    )

    collectionView.dataSource = self
    collectionView.delegate = self
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    refreshAssets()
  }

  func refreshAssets() {
    let filesURLString = baseURLString.appendingPathComponent("/files")
    let filesURL = URL(string: filesURLString)!
    URLSession.shared.dataTask(with: filesURL) { (data, response, error) in
      let decoder = JSONDecoder()
      self.assets = try? decoder.decode([Asset].self, from: data!)
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }.resume()
  }

  @objc
  func addAsset() {
    if(PHPhotoLibrary.authorizationStatus() == .notDetermined) {
      PHPhotoLibrary.requestAuthorization { (status) in
        switch(status) {
        case .authorized:
          self.addAsset()
        default:
          break
        }
      }

      return
    }

    let picker = UIImagePickerController()
    picker.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)]
    picker.videoQuality = .typeHigh
    picker.delegate = self
    present(picker, animated: true)
  }
}

extension AssetsViewController : UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return assets?.count ?? 0
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "\(AssetCollectionViewCell.self)",
      for: indexPath
    )

    if let cell = cell as? AssetCollectionViewCell {
      let asset = assets?[indexPath.item]
      cell.label.text = asset?.uri
    }

    return cell
  }

  func show(video: Asset) {
    let viewController = AVPlayerViewController()
    viewController.player = AVPlayer(url: video.url)

    navigationController?.pushViewController(viewController, animated: true)
  }

  func show(image: Asset) {
    let assetViewController = AssetDetailsViewController(asset: image)
    navigationController?.pushViewController(
      assetViewController, animated: true
    )
  }
}

extension AssetsViewController : UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard let asset = assets?[indexPath.item] else { return }
    let basename = (asset.uri as NSString).lastPathComponent
    let ext = (basename as NSString).pathExtension

    switch(ext) {
    case "mp4":
      show(video: asset)
    case "jpeg":
      show(image: asset)
    default:
      break
    }
  }

}

extension AssetsViewController :
  UINavigationControllerDelegate,
  UIImagePickerControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any]
  ) {
    guard let asset = info[UIImagePickerControllerPHAsset] as? PHAsset else {
      return
    }

    let uploadViewController = UploadViewController(asset: asset)
    uploadViewController.delegate = self
    dismiss(animated: true) {
      self.navigationController?.pushViewController(
        uploadViewController,
        animated: true
      )
    }
  }
}

extension AssetsViewController: UploadViewControllerDelegate {
  func uploadViewControllerDelegateDidUploadSuccessfully(
    _ uploadViewController: UploadViewController
    ) {
    navigationController?.popViewController(animated: true)
    refreshAssets()
  }
}
