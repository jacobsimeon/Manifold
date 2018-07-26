//
//  AssetCollectionViewCell.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/21/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import UIKit

class AssetCollectionViewCell : UICollectionViewCell {
  let label: UILabel = {
    let label = UILabel()
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(label)

    applyLayout()
  }

  private func applyLayout() {
    contentView.layoutMargins = UIEdgeInsets(
      top: 16,
      left: 16,
      bottom: 16,
      right: 16
    )

    contentView.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.leadingAnchor
      ),
      label.trailingAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.trailingAnchor
      ),
      label.topAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.topAnchor
      ),
      label.bottomAnchor.constraint(
        equalTo: contentView.layoutMarginsGuide.bottomAnchor
      ),
      label.widthAnchor.constraint(
        equalToConstant: UIScreen.main.bounds.width - 32
      )
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
