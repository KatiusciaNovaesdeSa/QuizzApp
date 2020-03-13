//
//  QuizViewController.swift
//  QuizzApp
//
//  Created by Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo. on 2020-03-06.
//  Copyright © 2020 Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo . All rights reserved.
//

import Foundation
import UIKit

// Extension to convert HTML text into readable format
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

class QuizViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Outlets for elements in the view controller
    @IBOutlet weak var questionNameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var answerPicker: UIPickerView!
    
    
    var currentQuestion: Int = 0
    var score: Int = 0
    var userAnswer: String = String()
    var pickerData: [String] = [String]()
    
    var detailItem: [Question]? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    
     //corresponds with the button that submits your answer for validation.
     
    
    @IBAction func submitAnswer(_ sender: Any) {
        if (!userAnswer.isEmpty) {
            if let detail = detailItem {
                // If the answer submitted was correct
                if (detail[currentQuestion].correct_answer.htmlToString == userAnswer) {
                    // Increment the score
                    score += 1
                    
                    // Only present this alert if not the last question
                    if (currentQuestion != detail.count - 1) {
                        presentAlert(title: "Correct!", message: "\(detail[currentQuestion].question.htmlToString): \"\(detail[currentQuestion].correct_answer.htmlToString)\"")
                    }
                } else {
                    // Display only if not last question
                    if (currentQuestion != detail.count - 1) {
                        // Show the user the correct answer
                        presentAlert(title: "Incorrect!", message: "You answered \"\(userAnswer)\", but the answer was \"\(detail[currentQuestion].correct_answer.htmlToString)\"")
                    }
                }
                
                if (currentQuestion == detail.count - 1) {
                    // Finish the quiz, display score
                    self.presentQuitAlert(title: "Score", message: "\(self.score) / \(detail.count)")
                    print("Quiz finished!")
                } else if (currentQuestion < detail.count) {
                    // move to next question and reset the view
                    currentQuestion += 1
                    DispatchQueue.main.async {
                        self.configureView()
                    }
                }
            }
        } else {
            // if choice is null
            presentAlert(title: "Invalid Answer", message: "Please try again!")
        }
    }
    
    
     // function configures this view and populates the elements on the storyboard.
     //It also updates the view if a new question needs to be loaded in.
  
    func configureView() {
        if let detail = detailItem {
            if let label = questionLabel {
                // Set the question and convert it to readable text
                label.text = detail[currentQuestion].question.htmlToString
            }
            if let label2 = questionNameLabel {
                // Set the label to the current question number
                label2.text = "Question \(currentQuestion + 1)"
            }
            
            // Clear out old data from picker view
            pickerData.removeAll()
            
            pickerData.append(detail[currentQuestion].correct_answer.htmlToString)
            
            // Add new answers to pickerData
            for answer in detail[currentQuestion].incorrect_answers {
                pickerData.append(answer.htmlToString)
            }
            
            // Shuffle the data
            pickerData.shuffle()
            
            // Reload picker view
            if let picker = answerPicker {
                picker.reloadAllComponents()
                
                // Set default to first answer in picker view
                picker.selectRow(0, inComponent: 0, animated: true)
            }
            
            // Default answer is the first in the picker view
            userAnswer = pickerData.first!
        }
    }
    
    
     //It sets the picker view delegate and data source, and it configures the view.
     
    override func viewDidLoad() {
        // Connect data:
        self.answerPicker.delegate = self
        self.answerPicker.dataSource = self
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureView()
    }
    
    // Picker View functions
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == answerPicker) {
            userAnswer = pickerData[row]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Alert functions
    
    func presentAlert(title: String, message: String) {
        // Set the alert's elements
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Have a default cancel action handler
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert to the user
        present(alertController, animated: true, completion: nil)
    }
    
    func presentQuitAlert(title: String, message: String) {
        // Set alert elements
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Have the cancel action segue back to the Main View Controller
        let cancelAction = UIAlertAction(title: "OK", style: .destructive, handler: {(alert: UIAlertAction!) in self.performSegue(withIdentifier: "Return to View", sender: self)})
        alertController.addAction(cancelAction)
        
        // Present the alert to the user
        present(alertController, animated: true, completion: nil)
    }
    
}
