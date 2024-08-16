import UIKit
import AVFoundation

public class CameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCapturePhotoOutput!
    var preview: AVCaptureVideoPreviewLayer!
    var startomCaptureCompletion: (() -> Void)?
    var photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
    var currentFlashMode: AVCaptureDevice.FlashMode = .off
    
    private var completion: ((UIImage?) -> Void)?
    public var currentPosition = CameraGlobals.shared.defaultCameraPosition
    
    public func startSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo

        device = cameraWithPosition(position: currentPosition)
        if let device = device, device.hasFlash {
            do {
                try device.lockForConfiguration()
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error)")
            }
        }

        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            print("Error: \(error.localizedDescription)")
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }
        imageOutput = AVCapturePhotoOutput()
        session.addOutput(imageOutput)
        session.commitConfiguration()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let isRunning = self?.session?.isRunning {
                if !isRunning {
                    self?.session?.startRunning()
                    // 切换回主线程处理UI更新或后续操作
                    DispatchQueue.main.async {
                        if let completion = self?.startomCaptureCompletion {
                            completion()
                        }
                    }
                }
            }
        }
        createPreview()
        rotatePreview()
    }
    
    public func stopSession() {
        if self.session.isRunning {
            DispatchQueue.global(qos: .background).async { [weak self] in
                if let isRunning = self?.session?.isRunning {
                    if isRunning {
                        self?.session?.stopRunning()
                        self?.session = nil
                    }
                }
            }
            preview?.removeFromSuperlayer()
            input = nil
            imageOutput = nil
            preview = nil
            device = nil
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        preview?.frame = bounds
    }

    public func configureZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        addGestureRecognizer(pinchGesture)
    }

    @objc internal func pinch(gesture: UIPinchGestureRecognizer) {
        guard let device = device else { return }

        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(max(factor, 1.0), device.activeFormat.videoMaxZoomFactor)
        }

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }

        let velocity = gesture.velocity
        let velocityFactor: CGFloat = 8.0
        let desiredZoomFactor = device.videoZoomFactor + atan2(velocity, velocityFactor)

        let newScaleFactor = minMaxZoom(desiredZoomFactor)
        switch gesture.state {
        case .began, .changed:
            update(scale: newScaleFactor)
        default:
            break
        }
    }
    
    private func createPreview() {
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds

        layer.addSublayer(preview)
    }
    
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera],
            mediaType: .video,
            position: .unspecified
        )

        return discoverySession.devices.first { $0.position == position }
    }
    
    public func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        isUserInteractionEnabled = false
        guard let photoOutput = imageOutput else {
            completion(nil)
            return
        }
        photoSettings.flashMode = currentFlashMode
        self.completion = completion
        photoOutput.capturePhoto(with: photoSettings, delegate:self)
    }
    
    public func focusCamera(toPoint: CGPoint) -> Bool {
        guard let device = device, let preview = preview, device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        let focusPoint = preview.captureDevicePointConverted(fromLayerPoint: toPoint)

        device.focusPointOfInterest = focusPoint
        device.focusMode = .continuousAutoFocus

        device.exposurePointOfInterest = focusPoint
        device.exposureMode = .continuousAutoExposure

        device.unlockForConfiguration()
        
        return true
    }
    
    public func cycleFlash() {
        guard let device = device, device.hasFlash else {
            return
        }
        do {
            switch currentFlashMode {
            case .on:
                currentFlashMode = .off
            case .off:
                currentFlashMode = .auto
            case .auto:
                currentFlashMode = .on
            default:
                currentFlashMode = .off
            }
        } catch {
            print("Error locking device for configuration: \(error.localizedDescription)")
        }
    }

    public func swapCameraInput() {
        guard let session = session, let currentInput = input else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        if currentInput.device.position == AVCaptureDevice.Position.back {
            currentPosition = AVCaptureDevice.Position.front
            device = cameraWithPosition(position: currentPosition)
        } else {
            currentPosition = AVCaptureDevice.Position.back
            device = cameraWithPosition(position: currentPosition)
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        input = newInput
        
        session.addInput(newInput)
        session.commitConfiguration()
    }
  
    public func rotatePreview() {
        guard let preview = preview,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        let orientation = windowScene.interfaceOrientation
        switch orientation {
        case .portrait:
            preview.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            preview.connection?.videoOrientation = .portraitUpsideDown
        case .landscapeRight:
            preview.connection?.videoOrientation = .landscapeRight
        case .landscapeLeft:
            preview.connection?.videoOrientation = .landscapeLeft
        default:
            break
        }
    }
}

extension CameraView: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput,
                       didFinishProcessingPhoto photo: AVCapturePhoto,
                       error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            if let block = self.completion {
                block(nil)
            }
            return
        }
        if let block = self.completion {
            block(image)
        }
    }
}
