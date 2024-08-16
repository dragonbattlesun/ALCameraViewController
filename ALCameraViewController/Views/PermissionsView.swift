//
//  PermissionsView.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal class PermissionsView: UIView {
   
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let settingsButton = UIButton()
    
    let horizontalPadding: CGFloat = 50
    let verticalPadding: CGFloat = 50
    let verticalSpacing: CGFloat = 10
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func configureInView(_ view: UIView, title: String, description: String, completion: @escaping ButtonAction) {
        let closeButton = UIButton(frame: CGRect(x: 20, y: 0, width: 44, height: 44))
        
        view.addSubview(self)
        addSubview(closeButton)
        
        titleLabel.text = title
        descriptionLabel.text = description
        
        closeButton.action = completion
        closeButton.setImage(UIImage(named: "close_nav_white", in: CameraGlobals.shared.bundle, compatibleWith: nil), for: UIControl.State())
        closeButton.sizeToFit()
        let safeAreaInsets = safeAreaInsets
        let closeY = safeAreaInsets.top + 10
        closeButton.frame.origin = CGPoint(x: 20, y: closeY)
    }
    
    func commonInit() {
        
        backgroundColor = UIColor.black
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.text = localizedString("permissions.title")
        
        descriptionLabel.textColor = UIColor.lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = NSTextAlignment.center
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.text = localizedString("permissions.description")
        
        let icon = UIImage(named: "permissionsIcon", in: CameraGlobals.shared.bundle, compatibleWith: nil)!
        iconView.image = icon
        settingsButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        settingsButton.setTitle(localizedString("permissions.settings"), for: UIControl.State())
        settingsButton.setTitleColor(UIColor.white, for: UIControl.State())
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        settingsButton.backgroundColor = UIColor(red: 52.0/255.0, green: 120.0/255.0, blue: 246.0/255.0, alpha: 1)
        settingsButton.addTarget(self, action: #selector(PermissionsView.openSettings), for: UIControl.Event.touchUpInside)
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(settingsButton)
    }
    
    @objc func openSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(appSettings)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maxLabelWidth = frame.width - horizontalPadding * 2
        
        let iconSize = iconView.image!.size
        let constrainedTextSize = CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude)
        let titleSize = titleLabel.sizeThatFits(constrainedTextSize)
        let descriptionSize = descriptionLabel.sizeThatFits(constrainedTextSize)
        let settingsSize = settingsButton.sizeThatFits(constrainedTextSize)
        
        let iconX = frame.width/2 - iconSize.width/2
        let iconY: CGFloat = frame.height/3 - (iconSize.height + verticalSpacing + verticalSpacing + titleSize.height + verticalSpacing + descriptionSize.height)/2;
        
        iconView.frame = CGRect(x: iconX, y: iconY, width: iconSize.width, height: iconSize.height)
        
        let titleX = frame.width/2 - titleSize.width/2
        let titleY = iconY + iconSize.height + verticalSpacing + verticalSpacing
        
        titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleSize.width, height: titleSize.height)
        
        let descriptionX = frame.width/2 - descriptionSize.width/2
        let descriptionY = titleY + titleSize.height + verticalSpacing
        
        descriptionLabel.frame = CGRect(x: descriptionX, y: descriptionY, width: descriptionSize.width, height: descriptionSize.height)
        
        let settingsX = frame.width/2 - settingsSize.width/2
        let settingsY = descriptionY + descriptionSize.height + verticalSpacing * 3
        
        settingsButton.frame = CGRect(x: settingsX, y: settingsY, width: settingsSize.width, height: settingsSize.height)
        settingsButton.layer.cornerRadius = settingsButton.frame.size.height / 2.0
    }
}
