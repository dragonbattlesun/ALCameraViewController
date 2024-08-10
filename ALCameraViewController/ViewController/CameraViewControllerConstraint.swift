//
//  CameraViewControllerConstraint.swift
//  CameraViewControllerConstraint
//
//  Created by Pedro Paulo de Amorim.
//  Copyright (c) 2016 zero. All rights reserved.
//

import UIKit
import AVFoundation

/**
 * This extension provides the configuration of
 * constraints for CameraViewController.
 */
extension CameraViewController {
    
    /**
     * To attach the view to the edges of the superview, it needs
     to be pinned on the sides of the self.view, based on the
     edges of this superview.
     * This configure the cameraView to show, in real time, the
     * camera.
     */
    func configCameraViewConstraints() {
        [.left, .right].forEach({
            view.addConstraint(NSLayoutConstraint(
                item: cameraView,
                attribute: $0,
                relatedBy: .equal,
                toItem: view,
                attribute: $0,
                multiplier: 1.0,
                constant: 0))
        })
        
        let topConstraint = NSLayoutConstraint(
            item: cameraView,
            attribute: .top,
            relatedBy: .equal,
            toItem: topMaskView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        )
        let leadingConstraint = NSLayoutConstraint(
            item: cameraView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: bottomMaskView,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )
        
        view.addConstraints([topConstraint, leadingConstraint])

    }
    
    
    /**
     * Remove the TopMaskView constraints to be updated when
     * the device was rotated.
     */
    func removeTopMaskConstraints() {
        for constraint in self.view.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == topMaskView {
                self.view.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == topMaskView {
                self.view.removeConstraint(constraint)
            }
        }
    }
    
    
    /**
     * Add the constraints based on the device orientation,
     * this pin the button on the bottom part of the screen
     * when the device is portrait, when landscape, pin
     * the button on the right part of the screen.
     */
    func configTopMaskViewConstraint() {
        // Remove previous constraints if needed (example implementation)
        // view.autoRemoveConstraint(cameraButtonEdgeConstraint)
        topMaskView.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints for topMaskView
        let topConstraint = NSLayoutConstraint(
            item: topMaskView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )
        let leadingConstraint = NSLayoutConstraint(
            item: topMaskView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0
        )
        let trailingConstraint = NSLayoutConstraint(
            item: topMaskView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )
        let heightConstraint = NSLayoutConstraint(
            item: topMaskView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,  // Height is not relative to another view
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 116 + self.view.safeAreaInsets.top  // Fixed height of 116
        )

        // Add constraints to the view
        NSLayoutConstraint.deactivate(view.constraints.filter { $0.firstItem === topMaskView })
        view.addConstraints([topConstraint, leadingConstraint, trailingConstraint, heightConstraint])
    }
    
    /**
     * Remove the TopMaskView constraints to be updated when
     * the device was rotated.
     */
    func removeBottomMaskConstraints() {
        for constraint in self.view.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == bottomMaskView {
                self.view.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == bottomMaskView {
                self.view.removeConstraint(constraint)
            }
        }
    }
    
    /**
     * Add the constraints based on the device orientation,
     * this pin the button on the bottom part of the screen
     * when the device is portrait, when landscape, pin
     * the button on the right part of the screen.
     */
    func configBottomMaskConstraint() {

        bottomMaskView.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints for topMaskView
        let topConstraint = NSLayoutConstraint(
            item: bottomMaskView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        )
        let leadingConstraint = NSLayoutConstraint(
            item: bottomMaskView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0
        )
        let trailingConstraint = NSLayoutConstraint(
            item: bottomMaskView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )
        let heightConstraint = NSLayoutConstraint(
            item: bottomMaskView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,  // Height is not relative to another view
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 162 + self.view.safeAreaInsets.bottom  // Fixed height of 116
        )

        // Add constraints to the view
        NSLayoutConstraint.deactivate(view.constraints.filter { $0.firstItem === bottomMaskView })
        view.addConstraints([topConstraint, leadingConstraint, trailingConstraint, heightConstraint])
    }
    
    /**
     * Add the constraints based on the device orientation,
     * this pin the button on the bottom part of the screen
     * when the device is portrait, when landscape, pin
     * the button on the right part of the screen.
     */
    func configCameraButtonConstraint() {
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
            // 添加约束来居中 cameraButton
        let centerXConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: bottomMaskView,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )

        let centerYConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: .top,
            relatedBy: .equal,
            toItem: bottomMaskView,
            attribute: .top,
            multiplier: 1.0,
            constant: 56
        )

        // 添加约束来设置 cameraButton 的宽度和高度
        let widthConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 68
        )

        let heightConstraint = NSLayoutConstraint(
            item: cameraButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 68
        
        )
        // 将所有约束添加到 bottomMaskView 上
        bottomMaskView.addConstraints([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
    }
    
    /**
     * Remove the SwapButton constraints to be updated when
     * the device was rotated.
     */
    func removeSwapButtonConstraints() {
        for constraint in bottomMaskView.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == swapButton {
                bottomMaskView.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == swapButton {
                bottomMaskView.removeConstraint(constraint)
            }
        }
    }
    
    /**
     * If the device is portrait, pin the SwapButton on the
     * right side of the CameraButton.
     * If landscape, pin the SwapButton on the top of the
     * CameraButton.
     */
    func configSwapButtonConstraint() {
        
        swapButton.translatesAutoresizingMaskIntoConstraints = false

        // Set constraints for topMaskView
        let topConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: cameraButton,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )
        let trailingConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: bottomMaskView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: -20
        )
        let heightConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 44
        )
        let widthConstraint = NSLayoutConstraint(
            item: swapButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,  // Height is not relative to another view
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 44  // Fixed height of 116
        )


        view.addConstraints([topConstraint, trailingConstraint, heightConstraint, widthConstraint])
        
    }
    
    func removeCloseButtonConstraints() {
        // 移除 bottomMaskView 中与 cameraButton 相关的所有约束
        for constraint in topMaskView.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == closeButton {
                topMaskView.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == closeButton {
                topMaskView.removeConstraint(constraint)
            }
        }
    }
    
    /**
     * Pin the close button to the left of the superview.
     */
    func configCloseButtonConstraint() {
        
        view.autoRemoveConstraint(closeButtonEdgeConstraint)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        // 设置顶部和右侧的约束
        let topConstraintConstant: CGFloat = 8 + self.view.safeAreaInsets.top
        let rightConstraintConstant: CGFloat = 20

        // 设置按钮的固定大小
        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30

        // 创建顶部约束
        let topConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: .top,
            relatedBy: .equal,
            toItem: topMaskView,
            attribute: .top,
            multiplier: 1.0,
            constant: topConstraintConstant
        )

        // 创建右侧约束
        let rightConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: .right,
            relatedBy: .equal,
            toItem: topMaskView,
            attribute: .right,
            multiplier: 1.0,
            constant: -rightConstraintConstant
        )

        // 设置按钮的宽度和高度约束
        let widthConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: buttonWidth
        )

        let heightConstraint = NSLayoutConstraint(
            item: closeButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: buttonHeight
        )

        // 将所有约束添加到视图中
        topMaskView.addConstraints([topConstraint, rightConstraint, widthConstraint, heightConstraint])
    }
   
    /**
     * Remove the LibraryButton constraints to be updated when
     * the device was rotated.
     */
    func removeLibraryButtonConstraints() {
        // 移除 bottomMaskView 中与 cameraButton 相关的所有约束
        for constraint in bottomMaskView.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == libraryButton {
                bottomMaskView.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == libraryButton {
                bottomMaskView.removeConstraint(constraint)
            }
        }
    }
    
    /**
     * Set the center gravity of the LibraryButton based
     * on the position of CameraButton.
     */
    func configLibraryButtonConstraint() {

        // Set constraints for topMaskView
        let topConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: cameraButton,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )
        let trailingConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: .leading,
            relatedBy: .equal,
            toItem: bottomMaskView,
            attribute: .leading,
            multiplier: 1.0,
            constant: 20
        )
        let heightConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 44
        )
        let widthConstraint = NSLayoutConstraint(
            item: libraryButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,  // Height is not relative to another view
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 44  // Fixed height of 116
        )

        bottomMaskView.addConstraints([topConstraint, trailingConstraint, heightConstraint, widthConstraint])
    }
    
    
    func removeflashButtonConstraints() {
        // 移除 bottomMaskView 中与 cameraButton 相关的所有约束
        for constraint in topMaskView.constraints {
            if let firstItem = constraint.firstItem as? UIView, firstItem == flashButton {
                topMaskView.removeConstraint(constraint)
            }
            if let secondItem = constraint.secondItem as? UIView, secondItem == flashButton {
                topMaskView.removeConstraint(constraint)
            }
        }
    }
    
    /**
     * If the device orientation is portrait, pin the top of
     * FlashButton to the top side of superview.
     * Else if, pin the FlashButton bottom side on the top side
     * of SwapButton.
     */
    func configFlashButtonConstraint() {

        // Set constraints for topMaskView
        let trailingConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: .leading,
            relatedBy: .equal,
            toItem: topMaskView,
            attribute: .leading,
            multiplier: 1.0,
            constant: 20
        )
        let centerConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: closeButton,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )
        let heightConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 30
        )
        let widthConstraint = NSLayoutConstraint(
            item: flashButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,  // Height is not relative to another view
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: 30  // Fixed height of 116
        )

        topMaskView.addConstraints([trailingConstraint, centerConstraint, heightConstraint, widthConstraint])
    }

}
