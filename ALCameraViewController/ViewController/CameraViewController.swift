//
//  CameraViewController.swift
//  CameraViewController
//
//  Created by Alex Littlejohn.
//  Copyright (c) 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

public extension CameraViewController {
    /// Provides an image picker wrapped inside a UINavigationController instance
    class func imagePickerViewController(completion: @escaping CameraViewCompletion,close:@escaping closeCompleted) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        imagePicker.modalPresentationStyle = .fullScreen
        navigationController.modalPresentationStyle = .fullScreen
        imagePicker.closeBlock = close
        imagePicker.onSelectionComplete = { [weak imagePicker] asset in
            if let asset = asset {
                SingleImageFetcher()
                    .setAsset(asset)
                    .setTargetSize(largestPhotoSize())
                    .onSuccess { image in
                        completion(image,asset)
                    }
                    .onFailure { error in
                        completion(nil,asset)
                    }
                    .fetch()
            } else {
                completion(nil, nil)
            }
        }
        
        return navigationController
    }
}

@objcMembers public class CameraViewController: UIViewController {
    
    var didUpdateViews = false
    var animationRunning = false
    let allowVolumeButtonCapture: Bool
    
    var lastInterfaceOrientation : UIInterfaceOrientation?
    open var onCompletion: CameraViewCompletion?
    var volumeControl: VolumeControl?
    
    var animationDuration: TimeInterval = 0.5
    var animationSpring: CGFloat = 0.5
    var rotateAnimation: UIView.AnimationOptions = .curveLinear
    
    var cameraButtonEdgeConstraint: NSLayoutConstraint?
    var cameraButtonGravityConstraint: NSLayoutConstraint?
    
    var closeButtonEdgeConstraint: NSLayoutConstraint?
    var closeButtonGravityConstraint: NSLayoutConstraint?
    
    var containerButtonsEdgeOneConstraint: NSLayoutConstraint?
    var containerButtonsEdgeTwoConstraint: NSLayoutConstraint?
    var containerButtonsGravityConstraint: NSLayoutConstraint?
    
    var swapButtonEdgeOneConstraint: NSLayoutConstraint?
    var swapButtonEdgeTwoConstraint: NSLayoutConstraint?
    var swapButtonGravityConstraint: NSLayoutConstraint?
    
    var libraryButtonEdgeOneConstraint: NSLayoutConstraint?
    var libraryButtonEdgeTwoConstraint: NSLayoutConstraint?
    var libraryButtonGravityConstraint: NSLayoutConstraint?
    
    var flashButtonEdgeConstraint: NSLayoutConstraint?
    var flashButtonGravityConstraint: NSLayoutConstraint?

    let cameraView : CameraView = {
        let cameraView = CameraView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        return cameraView
    }()
    
    let cameraButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setImage(UIImage(named: "cameraButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        button.setImage(UIImage(named: "cameraButtonHighlighted",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .highlighted)
        return button
    }()
    
    let closeButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close_nav_white",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()
    
    let swapButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "swapButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()
    
    let libraryButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "libraryButton",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()
    
    let flashButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "flashAutoIcon",
                                in: CameraGlobals.shared.bundle,
                                compatibleWith: nil),
                        for: .normal)
        return button
    }()
    
    let topMaskView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let bottomMaskView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
	private let allowsLibraryAccess: Bool
  
    public init(allowsLibraryAccess: Bool = true,
                allowsSwapCameraOrientation: Bool = true,
                allowVolumeButtonCapture: Bool = true,
                completion: @escaping CameraViewCompletion) {

        self.allowsLibraryAccess = allowsLibraryAccess
        self.allowVolumeButtonCapture = allowVolumeButtonCapture
        super.init(nibName: nil, bundle: nil)
        onCompletion = completion
        libraryButton.isEnabled = allowsLibraryAccess
        libraryButton.isHidden = !allowsLibraryAccess
		swapButton.isEnabled = allowsSwapCameraOrientation
		swapButton.isHidden = !allowsSwapCameraOrientation
    }
	
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    /**
     * Configure the background of the superview to black
     * and add the views on this superview. Then, request
     * the update of constraints for this superview.
     */
    open override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.black
        view.addSubview(topMaskView)
        view.addSubview(bottomMaskView)
        view.addSubview(cameraView)
        [closeButton,
         flashButton].forEach({
            topMaskView.addSubview($0)
        })
        
        [libraryButton,
         cameraButton,
         swapButton].forEach({
            bottomMaskView.addSubview($0)
        })

        view.setNeedsUpdateConstraints()
    }
    
    /**
     * Setup the constraints when the app is starting or rotating
     * the screen.
     * To avoid the override/conflict of stable constraint, these
     * stable constraint are one time configurable.
     * Any other dynamic constraint are configurable when the
     * device is rotating, based on the device orientation.
     */
    override open func updateViewConstraints() {
        removeTopMaskConstraints()
        removeBottomMaskConstraints()
        configTopMaskViewConstraint()
        configBottomMaskConstraint()
        if !didUpdateViews {
            configCameraViewConstraints()
            didUpdateViews = true
        }
        
        
        removeCloseButtonConstraints()
        configCloseButtonConstraint()

        removeflashButtonConstraints()
        configFlashButtonConstraint()

        configCameraButtonConstraint()
        
        configSwapButtonConstraint()
        removeLibraryButtonConstraints()
        
        configLibraryButtonConstraint()
        
        super.updateViewConstraints()
    }
    
    /**
     * Add observer to check when the camera has started,
     * enable the volume buttons to take the picture,
     * configure the actions of the buttons on the screen,
     * check the permissions of access of the camera and
     * the photo library.
     * Configure the camera focus when the application
     * start, to avoid any bluried image.
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        setupActions()
        checkPermissions()
        cameraView.configureZoom()
        self.libraryButton.isHidden = true
        self.closeButton.isHidden = true
        self.cameraView.startomCaptureCompletion = { [weak self] in
            self?.libraryButton.isHidden = false
            self?.closeButton.isHidden = false
        }
        self.cameraView.startSession()
    }

    /**
     * Start the session of the camera.
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        cameraView.startSession()
        addCameraObserver()
        addRotateObserver()

        if allowVolumeButtonCapture {
            setupVolumeControl()
        }
    }
    
    /**
     * Enable the button to take the picture when the
     * camera is ready.
     */
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraView.session?.isRunning == true {
            notifyCameraReady()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        volumeControl = nil
    }

    /**
     * This method will disable the rotation of the
     */
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        lastInterfaceOrientation = UIApplication.shared.statusBarOrientation
        if animationRunning {
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        coordinator.animate(alongsideTransition: { [weak self] animation in
            self?.view.setNeedsUpdateConstraints()
            }, completion: { _ in
                CATransaction.commit()
        })
    }
    
    /**
     * Observer the camera status, when it is ready,
     * it calls the method cameraReady to enable the
     * button to take the picture.
     */
    private func addCameraObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyCameraReady),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
    }
    
    /**
     * Observer the device orientation to update the
     * orientation of CameraView.
     */
    private func addRotateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotateCameraView),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    @objc internal func notifyCameraReady() {
        DispatchQueue.main.async {[weak self] in
            self?.cameraButton.isEnabled = true
        }
    }
    
    /**
     * Attach the take of picture for any volume button.
     */
    private func setupVolumeControl() {
        volumeControl = VolumeControl(view: view) { [weak self] _ in
            guard let enabled = self?.cameraButton.isEnabled, enabled else {
                return
            }
            self?.capturePhoto()
        }
    }
    
    /**
     * Configure the action for every button on this
     * layout.
     */
    private func setupActions() {
        cameraButton.action = { [weak self] in self?.capturePhoto() }
        swapButton.action = { [weak self] in self?.swapCamera() }
        libraryButton.action = { [weak self] in self?.showLibrary() }
        closeButton.action = { [weak self] in self?.close() }
        flashButton.action = { [weak self] in self?.toggleFlash() }
    }
    
    /**
     * Toggle the buttons status, based on the actual
     * state of the camera.
     */
    private func toggleButtons(enabled: Bool) {
        [cameraButton,
            closeButton,
            swapButton,
            libraryButton].forEach({ $0.isEnabled = enabled })
    }
    
    @objc func rotateCameraView() {
        cameraView.rotatePreview()
    }
    
    /**
     * This method will rotate the buttons based on
     * the last and actual orientation of the device.
     */
    internal func rotate(actualInterfaceOrientation: UIInterfaceOrientation) {
        
        if lastInterfaceOrientation != nil {
            let lastTransform = CGAffineTransform(rotationAngle: radians(currentRotation(
                lastInterfaceOrientation!, newOrientation: actualInterfaceOrientation)))
            setTransform(transform: lastTransform)
        }

        let transform = CGAffineTransform(rotationAngle: 0)
        animationRunning = true
        
        /**
         * Dispatch delay to avoid any conflict between the CATransaction of rotation of the screen
         * and CATransaction of animation of buttons.
         */

        let duration = animationDuration
        let spring = animationSpring
        let options = rotateAnimation

        let time: DispatchTime = DispatchTime.now() + Double(1 * UInt64(NSEC_PER_SEC)/10)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in

            guard let _ = self else {
                return
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.commit()
            
            UIView.animate(
                withDuration: duration,
                delay: 0.1,
                usingSpringWithDamping: spring,
                initialSpringVelocity: 0,
                options: options,
                animations: { [weak self] in
                    self?.setTransform(transform: transform)
                }, completion: { [weak self] _ in
                    self?.animationRunning = false
            })
            
        }
    }
    
    func setTransform(transform: CGAffineTransform) {
        closeButton.transform = transform
        swapButton.transform = transform
        libraryButton.transform = transform
        flashButton.transform = transform
    }
    
    /**
     * Validate the permissions of the camera and
     * library, if the user do not accept these
     * permissions, it shows an view that notifies
     * the user that it not allow the permissions.
     */
    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async() { [weak self] in
                    if !granted {
                        self?.showNoPermissionsView()
                    }
                }
            }
        }
    }
    
    /**
     * Generate the view of no permission.
     */
    private func showNoPermissionsView(library: Bool = false) {
        let permissionsView = PermissionsView(frame: view.bounds)
        let title: String
        let desc: String
        
        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }
        
        permissionsView.configureInView(view, title: title, description: desc, completion: { [weak self] in self?.close() })
    }
    
    /**
     * This method will be called when the user
     * try to take the picture.
     * It will lock any button while the shot is
     * taken, then, realease the buttons and save
     * the picture on the device.
     */
    internal func capturePhoto() {
        guard let output = cameraView.imageOutput,
            let connection = output.connection(with: AVMediaType.video) else {
            return
        }
        if connection.isEnabled {
            toggleButtons(enabled: false)
            cameraView.capturePhoto { [weak self] image in
                guard let image = image else {
                    self?.toggleButtons(enabled: true)
                    return
                }
                if let completedBlock = self?.onCompletion {
                    completedBlock(image,nil)
                }
            }
        }
    }
    
    internal func close() {
        onCompletion?(nil, nil)
        onCompletion = nil
    }
    
    internal func showLibrary() {
        self.cameraView.stopSession()
        let imagePicker = CameraViewController.imagePickerViewController() { [weak self] image, asset in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image, let asset = asset else {
                return
            }

            self?.onCompletion?(image, asset)
        } close: {
            self.cameraView.startSession()
        }
        
        present(imagePicker, animated: true) { [weak self] in
        }
    }
    
    internal func toggleFlash() {
        cameraView.cycleFlash()
        
        guard let device = cameraView.device else {
            return
        }
        let  flashMode = AVCapturePhotoSettings().flashMode
        let image = UIImage(named: flashImage(flashMode),
                            in: CameraGlobals.shared.bundle,
                            compatibleWith: nil)
        
        flashButton.setImage(image, for: .normal)
    }
    
    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevice.Position.front
    }
	
	internal func layoutCameraResult(uiImage: UIImage) {
		cameraView.stopSession()
		startConfirmController(uiImage: uiImage)
		toggleButtons(enabled: true)
	}
	
    internal func layoutCameraResult(asset: PHAsset) {
        cameraView.stopSession()
        startConfirmController(asset: asset)
        toggleButtons(enabled: true)
    }
	
	private func startConfirmController(uiImage: UIImage) {
        self.onCompletion?(uiImage, nil)
	}
	
    private func startConfirmController(asset: PHAsset) {
        SingleImageFetcher()
            .setAsset(asset)
            .setTargetSize(largestPhotoSize())
            .onSuccess { [weak self] image in
                self?.onCompletion?(image,asset)
            }
            .onFailure { [weak self] error in
                self?.onCompletion?(nil,asset)
            }
            .fetch()
    }

    private func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.style = .medium
        spinner.center = view.center
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubviewToFront(spinner)
        
        return spinner
    }
    
    private func hideSpinner(_ spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    deinit {
        print("=== talkme \(PhotoLibraryViewController.self) dealloc");
    }
    
}
