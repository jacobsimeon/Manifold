//
//  AssetDetailsViewController.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/24/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import UIKit

class AssetDetailsViewController : UIViewController {
  let asset: Asset

  let imageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    return view
  }()

  let filenameLabel = UILabel()

  init(asset: Asset) {
    self.asset = asset
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func loadView() {
    let rootView = UIView()
    rootView.backgroundColor = .white

    rootView.addSubview(imageView)
    rootView.addSubview(filenameLabel)

    view = rootView
    applyLayout()
  }

  private func applyLayout() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    filenameLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(
        equalTo: view.layoutMarginsGuide.leadingAnchor
      ),
      imageView.trailingAnchor.constraint(
        equalTo: view.layoutMarginsGuide.trailingAnchor
      ),
      imageView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: 16
      ),
      imageView.heightAnchor.constraint(
        equalToConstant: UIScreen.main.bounds.height * 0.5
      ),
      filenameLabel.topAnchor.constraint(
        equalTo: imageView.bottomAnchor,
        constant: 16
      ),
      filenameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    filenameLabel.text = asset.uri
    DispatchQueue.global(qos: .background).async { [weak self] in
      self?.loadImage()
    }
  }

  func loadImage() {
    guard let data = try? Data(contentsOf: asset.url),
      let image = UIImage(data: data) else { return }

    DispatchQueue.main.async { [weak self] in
      self?.imageView.image = image
    }
  }
}
