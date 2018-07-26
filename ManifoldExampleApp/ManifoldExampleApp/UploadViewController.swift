//
//  UploadViewController.swift
//  ManifoldExampleApp
//
//  Created by pivotal on 7/22/18.
//  Copyright © 2018 Pivotal Labs. All rights reserved.
//

import UIKit
import Photos
import Manifold

protocol UploadViewControllerDelegate: class {
  func uploadViewControllerDelegateDidUploadSuccessfully(
    _ uploadViewController: UploadViewController
  )
}

class UploadViewController : UIViewController {
  let asset: PHAsset
  let imageManager: PHImageManager
  weak var delegate: UploadViewControllerDelegate?

  let imageView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .gray
    view.contentMode = .scaleAspectFit
    return view
  }()

  let filenameLabel = UILabel()
  let fileID: String
  let mimeTypeLabel = UILabel()

  init(asset: PHAsset) {
    self.asset = asset
    self.imageManager = PHImageManager.default()
    self.fileID = String(UUID().uuidString.split(separator: "-").first!)

    super.init(nibName: nil, bundle: nil)

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Upload",
      style: .done,
      target: self,
      action: #selector(upload)
    )
  }

  override func loadView() {
    let rootView = UIView()
    rootView.backgroundColor = .white

    rootView.addSubview(imageView)
    rootView.addSubview(filenameLabel)
    rootView.addSubview(mimeTypeLabel)

    view = rootView
    applyLayout()
  }

  private func applyLayout() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    filenameLabel.translatesAutoresizingMaskIntoConstraints = false
    mimeTypeLabel.translatesAutoresizingMaskIntoConstraints = false

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
      mimeTypeLabel.topAnchor.constraint(
        equalTo: filenameLabel.bottomAnchor,
        constant: 8
      ),
      mimeTypeLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let height: CGFloat = UIScreen.main.bounds.height * 0.5
    let width = UIScreen.main.bounds.width * 0.5

    imageManager.requestImage(
      for: asset,
      targetSize: CGSize(width: width, height: height),
      contentMode: .aspectFit,
      options: nil
    ) { [weak self] (image, _) in
      self?.imageView.image = image
    }

    switch(asset.mediaType) {
    case .image:
      populateImageInfo()
    case .video:
      populateVideoInfo()
    default:
      break
    }
  }

  func populateImageInfo() {
    asset.requestContentEditingInput(with: nil) { [weak self] (input, _) in
      guard let sself = self,
        let utiString = input?.uniformTypeIdentifier else { return }

      let uti = UTI(string: utiString)
      let fileName = "\(sself.fileID).\(uti.fileExtension)"
      sself.mimeTypeLabel.text = "MIME type: \(uti.mimeType)"
      sself.filenameLabel.text = "File name: \(fileName)"
    }
  }

  func populateVideoInfo() {
    mimeTypeLabel.text = "MIME type: image/mp4"
    filenameLabel.text = "File name: \(fileID).mp4"
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  @objc
  func upload(sender: Any?) {
    switch(asset.mediaType) {
    case .image:
      uploadImage()
    case .video:
      uploadVideo()
    default:
      break
    }
  }

  var streamReader: StreamReader?
  func uploadVideo() {
    imageManager.requestExportSession(
      forVideo: asset,
      options: nil,
      exportPreset: AVAssetExportPresetHighestQuality
    ) { (session, info) in
      guard let session = session else { return }

      let tempDir = NSTemporaryDirectory() as NSString
      let tempFilePath = tempDir.appendingPathComponent(UUID().uuidString)

      session.outputFileType = .mp4
      session.outputURL = URL(fileURLWithPath: tempFilePath)

      session.exportAsynchronously {
        let input = InputStream(fileAtPath: tempFilePath)!

        switch(session.status) {
        case .completed:
          DispatchQueue.main.async {
            self.uploadMedia(input, mimeType: "video/mp4", fileExtension: "mp4")
          }
        default:
          break
        }
      }
    }
  }

  func uploadImage() {
    imageManager.requestImageData(
      for: asset,
      options: nil
    ) { [weak self] (data, utiString, orientation, info) in
      guard let data = data, let utiString = utiString else { return }

      let uti = UTI(string: utiString)
      self?.uploadMedia(
        InputStream(data: data),
        mimeType: uti.mimeType,
        fileExtension: uti.fileExtension
      )
    }
  }

  private var manifold: Manifold?
  func uploadMedia(
    _ inputStream: InputStream,
    mimeType: String,
    fileExtension: String
  ) {
    manifold = Manifold()
    let boundary = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    manifold?.boundary = boundary

    let part = Part()
    let fileName = "\(self.fileID).\(fileExtension)"
    part.header(
      "Content-Disposition",
      "form-data; name=\"file\"; filename=\"\(fileName)\""
    )
    part.header("Content-Type", mimeType)
    part.body(inputStream)

    manifold?.append(part: part)

    let urlString = baseURLString.appendingPathComponent("/files")
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "POST"
    request.setValue(
      "multipart/form-data; boundary=\(boundary)",
      forHTTPHeaderField: "Content-Type"
    )
    request.httpBodyStream = manifold?.getBodyStream()


    URLSession.shared.dataTask(with: request) {
      [weak self]
      (data, response, error) in

      guard error == nil else {
        print(error!)
        return
      }

      guard let sself = self,
        let response = response as? HTTPURLResponse else { return }

      if(response.statusCode == 201) {
        DispatchQueue.main.async {
          sself
            .delegate?
            .uploadViewControllerDelegateDidUploadSuccessfully(sself)
        }
      }
    }.resume()
    manifold?.startWriting()

  }
}
