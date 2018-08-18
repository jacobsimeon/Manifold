# Manifold

Easily construct [multipart http requests][0] in swift.

## Example Usage

```swift
import Manifold

let manifold = Manifold()

func uploadAnImageFile() {
  // Set the boundary that separates each part of the request
  manifold.boundary = UUID().uuidString

  // Start building a new part for the request
  let part = Part()

  // request parts can have their own headers
  part.header("Content-Disposition", "form-data; name=\"image\"; filename=\"the-image.jpg\"")
  part.header("Content-Type", "image/jpeg")

  // The 'body' of this part is the contents of an image file
  part.body(InputStream(fileAtPath: pathToAFile)

  // add the part to the manifold object
  // any number of parts can be added. For Example, you may want to add a
  // second part containing additional form data that will be handled by the server
  manifold.append(part)

  //  Manifold will notify its delegate when encoding completes
  manifold.delegate = self
  manifold.encode()
}

func manifold(_ manifold: Manifold, didFinishEncoding stream: InputStream) {
  // Manifold encodes all its parts into a single input stream that can be
  // attached to an HTTPURLRequest
  var request = URLRequest(url: fileUploadURL)
  request.httpBodyStream =  stream

  // ... continue sending the HTTP request
}

func manifold(_ manifold: Manifold, didFailWithError error: Error) {
  print("An error occurred while encoding the multipart request")
}
```

## Installation

### Carthage

Add this to your Cartfile
```
github "jacobsimeon/Manifold"
```

Then run `carthage update`

[0]: https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
