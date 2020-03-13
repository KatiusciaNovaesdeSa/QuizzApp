//
//  ViewController.swift
//  QuizzApp
//
//  Created by Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo. on 2020-03-06.
//  Copyright © 2020 Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo . All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var difficultyPickerView: UIPickerView!
    @IBOutlet weak var startButton: UIButton!
    
    let apiUrl = "https://opentdb.com/api.php?amount=10&type=multiple"
    let categoryUrl = "https://opentdb.com/api_category.php"
    
    var question: [Question] = [Question]()
    var category: [QuizCategory] = [QuizCategory]()
    var difficulty: [(key: String, value: String)] = [(String, String)]()
    
    var quizCategory: Int = 0
    var quizDifficulty: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up difficult and category
        difficulty = [("Easy", "easy"), ("Medium", "medium"), ("Hard", "hard")]
        self.getCategory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Detail" {
            let controller = segue.destination as! QuizViewController
            
            // Set properties of controller as needed to pass objects
            controller.detailItem = question
        }
        
        if segue.identifier == "Show Scores" {
            
        }
    }
    
    
    // retrieves the available quiz question categories from the API. It populates the category //  view with the information that it receives.
    
    func getCategory () {
        var newCategory = [QuizCategory]()
        do {
            guard let url = URL(string: categoryUrl) else {
                // error handling
                print("Invalid URL string")
                return
            }
            let task = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                let httpResponse = response as? HTTPURLResponse
                if httpResponse!.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: ("Could not retrieve categories"))
                    }
                } else if httpResponse!.statusCode != 200 {
                    // error handling
                    print("Unexpected http response")
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: ("Unexpected http response"))
                    }
                } else if (data == nil && error != nil) {
                    // error handling
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: (error!.localizedDescription))
                    }
                } else {
                    // download and decode JSON into User object /
                    do {
                        let jsonString = String(data: data!, encoding: String.Encoding.utf8)
                        print(jsonString!)
                        let getCategoriesData = try JSONDecoder().decode(CategoryData.self, from: data!)
                        newCategory = getCategoriesData.trivia_categories
                        self.category = newCategory
                        self.quizDifficulty = self.difficulty[0].value
                        self.quizCategory = self.category[0].id
                        DispatchQueue.main.async {
                            self.categoryPickerView.reloadAllComponents()
                            self.difficultyPickerView.reloadAllComponents()
                        }
                    } catch {
                        print("Did not decode getUser data")
                    }
                }
            }
            task.resume()
        }
    }
    
    // MARK: Picker View functions
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == categoryPickerView) {
            return category.count
        }
        else {
            return difficulty.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == categoryPickerView) {
            return category[row].name
        } else {
            return difficulty[row].key
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == categoryPickerView) {
            quizCategory = category[row].id
        } else {
            quizDifficulty = difficulty[row].value
        }
    }
    
   
     //retrieves questions from an external service. It makes a rest call to an API using the  //given URL string. Parameter url: the API to retrieve the question information from.
     
    func getQuestions (url: String) {
        do {
            // try to upload jsonData
            guard let url = URL(string: url) else { // Perform some error handling
                print("Invalid URL string")
                return
            }
            
            // make REST call to API service
            let call = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                let httpResponse = response as? HTTPURLResponse
                
                // if the data not found
                if httpResponse!.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: ("Could not retrieve questions"))
                    }
                } else if httpResponse!.statusCode != 200 {
                    // error handling
                    print("Unexpected http response")
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: ("Unexpected http response"))
                    }
                } else if (data == nil && error != nil) {
                    // error handling
                    print(error!.localizedDescription)
                    DispatchQueue.main.async {
                        self.presentAlert(title: "Failed", message: (error!.localizedDescription))
                    }
                } else {
                    // download succeeded, decode JSON into User object
                    do {
                        let getQuizQuestions = try JSONDecoder().decode(Quiz.self, from: data!)
                        self.question = getQuizQuestions.results
                        DispatchQueue.main.async {
                            // Segue to QuizViewController
                            self.performSegue(withIdentifier: "Show Detail", sender: self)
                        }
                    } catch {
                        print("Did not decode getUser data")
                    }
                }
            }
            call.resume()
        }
    }

   
     // handles what happens when the user presses the button to begin the quiz
     
     
    @IBAction func quizStarted(_ sender: Any) {
        if (quizCategory == 0 || quizDifficulty.isEmpty || quizCategory == 13 || quizCategory == 19 || quizCategory == 24 || quizCategory == 25 || quizCategory == 29 || quizCategory == 30) {
            self.presentAlert(title: "Category not yet available", message: ("Choose a different category!"))
        } else {
            getQuestions(url: "\(apiUrl)&difficulty=\(quizDifficulty)&category=\(quizCategory)")
        }
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

