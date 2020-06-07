//
//  MemMarkerEditorViewController.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/23/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import UIKit
import RGSColorSlider

class MemMarkerEditorViewController : UIViewController, UITextFieldDelegate {
    var navBar: UINavigationBar!;
    var content: UIStackView!;
    
    var doneButton: UIBarButtonItem!;
    
    var marker: MemoryMarker!;
    
    var questionField: UITextField!;
    var answerField: UITextField!;
    var deleteButton: UIButton!;
    
    var removeOnCancel: Bool = false;
    var colorSlider: RGSColorSlider!;
    
    convenience init(marker: MemoryMarker, removeOnCancel: Bool = false) {
        self.init(nibName:nil, bundle:nil)
        self.marker = marker;
        self.removeOnCancel = removeOnCancel;
    }
    
    override func viewDidLoad() {
        // add rounded corners
        view.layer.cornerRadius = 15.0;
        view.clipsToBounds = true;
        view.backgroundColor = .secondarySystemBackground;
        
        
        // disable swiping to close
        isModalInPresentation = true;
        
        // add a navbar
        navBar = UINavigationBar();
        view.addSubview(navBar);
        
        let title = UINavigationItem(title: "Memory Marker Editor");
        // set the done button
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(doneButtonPressed));
        doneButton.isEnabled = marker.isValid();
        title.rightBarButtonItem = doneButton;
        title.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: #selector(cancelButtonPressed))
        
        navBar.setItems([title], animated: false);
        
        // content view
        content = UIStackView();
        content.axis = .vertical;
        content.alignment = .fill;
        content.spacing = 5;
        content.distribution = .equalCentering;
        view.addSubview(content);
        
        colorSlider = RGSColorSlider();
        colorSlider.color = marker.markerView?.backgroundColor;
        colorSlider.addTarget(self, action: #selector(changeLineColour(_:)), for: .touchDragInside)
        content.addArrangedSubview(colorSlider);
        
        let questionFieldLabel = UILabel();
        questionFieldLabel.textColor = .secondaryLabel;
        questionFieldLabel.text = "Question: ";
        content.addArrangedSubview(questionFieldLabel);
        
        questionField = UITextField();
        questionField.placeholder = "a fascinating question...";
        questionField.text = marker.question;
        questionField.delegate = self;
        content.addArrangedSubview(questionField);
        
        let answerFieldLabel = UILabel();
        answerFieldLabel.textColor = .secondaryLabel;
        answerFieldLabel.text = "Answer: ";
        content.addArrangedSubview(answerFieldLabel);
        
        answerField = UITextField();
        answerField.placeholder = "a fascinating question...";
        answerField.text = marker.answer;
        answerField.delegate = self;
        content.addArrangedSubview(answerField);
        
        content.addArrangedSubview(UIView());
        
        
        // delete button
        deleteButton = UIButton();
        deleteButton.layer.cornerRadius = 5;
        deleteButton.layer.borderWidth = 1;
        deleteButton.layer.borderColor = UIColor.red.cgColor;
        deleteButton.setTitle("REMOVE MARKER", for: .normal);
        deleteButton.setTitleColor(UIColor.red, for: .normal);
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside);
        

        content.addArrangedSubview(deleteButton);
        
//        deleteButton.sizeToFit()

    }
    
    @objc func changeLineColour(_ sender: Any) {
        let color = (sender as! RGSColorSlider).color!;
        marker.color = CodableColor(color: color);
    }
    override func viewWillLayoutSubviews() {
        let parentFrame = view.superview!.frame
        let minDim = min(parentFrame.width, parentFrame.height) * 0.9;
        view.frame = CGRect(
            x: (parentFrame.width - minDim) / 2.0, y: minDim * 0.2,
            width: minDim, height: 200 + 60 + 10
        );
        
        navBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40);
        content.frame = CGRect(x: 10, y: 60, width: view.frame.width - 20, height: 200);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case questionField:
            answerField.becomeFirstResponder();
        default:
            textField.resignFirstResponder();
        }
        
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textChanged(textField: textField);
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textChanged(textField: textField);
        return true;
    }
    
    func textChanged(textField: UITextField) {
        switch textField {
        case questionField:
            marker.question = questionField.text!;
        case answerField:
            marker.answer = answerField.text!;
        default:
            break;
        }
        doneButton.isEnabled = marker.isValid();
    }
    
    @objc func doneButtonPressed() {
        print("MemMarkerEditor done button pressed");
        
        answerField.resignFirstResponder();
        questionField.resignFirstResponder();
        AppDataController.global.updateMemoryMarker(marker: marker);
        
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc func deleteButtonPressed(sender: UIButton!) {
        print("MemMarkerEditor Delete button Pressed");
        
        answerField.resignFirstResponder();
        questionField.resignFirstResponder();
        AppDataController.global.removeMemoryMarker(marker: marker);
        
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc func cancelButtonPressed() {
        print("MemMarkerEditor cancel button pressed");
        
        answerField.resignFirstResponder();
        questionField.resignFirstResponder();
        
        if (removeOnCancel) {
            AppDataController.global.removeMemoryMarker(marker: marker);
        }
        
        self.dismiss(animated: true, completion: nil);
    }

}
