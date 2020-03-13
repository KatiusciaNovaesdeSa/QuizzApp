//
//  JSON.swift
//  QuizzApp
//
//  Created by Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo. on 2020-03-06.
//  Copyright © 2020 Katiuscia Novaes de Sa, Yuri Kusik, Alejandro Mancebo . All rights reserved.



import Foundation
import UIKit

public struct Question: Decodable {
    var category: String
    var type: String
    var difficulty: String
    var question: String
    var correct_answer: String
    var incorrect_answers: [String]
}

public struct Quiz: Decodable {
    var response_code: Int
    var results: [Question]
}

public struct CategoryData: Decodable {
    var trivia_categories: [QuizCategory]
}

public struct QuizCategory: Decodable {
    var id: Int
    var name: String
}
