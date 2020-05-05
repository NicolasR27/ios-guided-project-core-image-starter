import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {
    
    private var originalImage: UIImage?{
        didSet{
            updateViews()
            
        }
    }
    
    private var scaledImage:UIImage?{
        didSet{
            updateViews()
            
            
            guard let  originalImage = originalImage else  {return}
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale// 1x(no iphone)2x 3x
            
            // Debug statement ,take these out for your final submissions
            print("image size: \(originalImage.size)")
            print("size: \(scaledSize)")
            print("scale:\(scale)")
            
            
            // how many pixels can we fit on the screen ?
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
            
            
            
        }
    }
    
    
    private var context = CIContext(options: nil)
    
    
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter = CIFilter.colorControls()
        print(filter)
        
        print(filter.attributes)
        
        // Test the filter quickly
        originalImage = imageView.image
        
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker,animated: true,completion: nil)
    }
    
    
    
    func updateViews(){
        if  let originalImage = originalImage {
            imageView.image = filterImage(originalImage)
            
        }else{
            imageView.image = nil // placeholder image
        }
        
    }
    
    
    func filterImage(_ image: UIImage) -> UIImage? {
        // UImage -> CGImage(core graphic) -> CImage(CoreImage)
        guard let  cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage:cgImage)
        
        
        
        // Filter
        let filter = CIFilter.colorControls()
        
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        
        // Render the image
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else {
                                                            return nil
                                                            
        }
        
        // CIImage -> CGImage -> UIImage
        return UIImage(cgImage: outputCGImage)
        
    }
    
    // MARK: Actions
    
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        guard let originalImage = originalImage else { return }
        
        
        guard let processedImage = filterImage(originalImage) else { return }
        PHPhotoLibrary.requestAuthorization { (status) in
            
            guard status == .authorized else {return}
            
            
            PHPhotoLibrary.shared().performChanges({
                
               
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
            }, completionHandler: {(success,error) in
                
                if let error = error {
                    NSLog("error saving photo:\(error)")
                    return
                }
                
                DispatchQueue.main.async{
                    print("save photo")
                }
                
            })
            
        }
        
        
    }
    
    // MARK: Slider events
    
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
    }
    
    @IBAction func contrastChanged(_ sender: Any) {
        updateViews()
    }
    
    @IBAction func saturationChanged(_ sender: Any) {
        updateViews()
    }
}


extension PhotoFilterViewController: UIImagePickerControllerDelegate {
    
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let image = info[.originalImage] as? UIImage{
            originalImage = image
            
        }
        picker.dismiss(animated: true)
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


extension PhotoFilterViewController: UINavigationControllerDelegate {
    
}

