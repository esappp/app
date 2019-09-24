//
//  QuizViewController.swift
//  GreenScore
//
//  Created by Anura Ghodke on 4/10/19.
//  Copyright © 2019 Anura Ghodke. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

struct question {
    var question : String?
    var answers : [String]?
    var answer : Int!
    var explanation : String?
}

class QuizViewController: UIViewController {
    @IBOutlet weak var QLabel: UITextView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var explanation: UITextView!
    
    var questions = [question]()
    var QNumber = 0
    var correctAnswer = Int()
    
    var correctAudio = AVAudioPlayer()
    var incorrectAudio = AVAudioPlayer()
    
    var allCorrect = true
    
    var db: Firestore!
    let userID = Auth.auth().currentUser!.uid
    var greenScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            correctAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "correct", ofType: "mp3")!))
            correctAudio.prepareToPlay()
        } catch  {
            print(error)
        }
        
        do {
            incorrectAudio = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "incorrect", ofType: "mp3")!))
            incorrectAudio.prepareToPlay()
        } catch  {
            print(error)
        }
        //  Order: 7 1 5 3 6 9 2 8 4 10

        questions = [question(question: "Which of the following does NOT contribute to a kind of pollution?", answers: ["Factories", "Air", "Fire", "Washing a car on the driveway"], answer: 1, explanation: "Air is the only option that doesn’t contribute to pollution, however, air pollution is real and is when elements that are not nitrogen, oxygen, and water vapor are released into the atmosphere."),
                     
                     //Question 2
                     question(question: "Which of the following is one method of combating overpopulation?", answers: ["Reducing average no. of kids per family", "Improving fertility treatments", "Improving medical care", "Recycling"], answer: 0, explanation: "Though recycling, improving medical care and fertility treatments are important, they wouldn’t be helping the population of a society."),
                     
                     //Question 3
                     question(question: "How many marine animals die a year due to waste in the ocean?", answers: ["500,000", "1,000,000", "50,000,000", "100,000,000"], answer: 3, explanation: "In the article, it says that more than 100,000,000 marine animals die a year due to plastic in the ocean and we are creating harmful ecosystems for these animals."),
                     
                     //Question 4
                     question(question: "Which of the following is a health effect of global warming?", answers: ["Syphillis", "Anemia", "Erythromelalgia", "Lymphoma"], answer: 2, explanation: "The other diseases mentioned in the article besides Erythromelalgia were Malaria, Dengue Fever, and Tick-Borne Disease. "),
                     
                     //Question 5
                     question(question: "Which of the following is NOT beneficial to the environment?", answers: ["Repurposing old clothing", "Throwing recycling waste in the disposal", "Preventing unnecessary waste", "Reducing production"], answer: 1, explanation: "Throwing recycling waste in the disposal is harmful because they could be sent to waste sites, where waste can be extremely harmful to the ecosystem and organisms living there."),
                     
                     //Question 6
                    question(question: "Which of the following does NOT lead to animals being put on the endangered species list?", answers: ["Feeding wild animals", "Polluting the animals’ habitats", "Bringing animals into exotic environments", "Hunting animals"], answer: 0, explanation: "Feeding wild animals would not result in that animal being put onto the endangered species list but can also be a harmful thing to do without knowing their diet."),
                     
                     //Question 7
                     question(question: "Which is NOT a cause of overpopulation?", answers: ["Urbanization", "Poverty", "Health Care", "Improved medical care"], answer: 2, explanation: "Urbanization, poverty, and improved medical health care were all causes of overpopulation mentioned in the article. The use of health care products can prevent overpopulation."),
                     
                     //Question 8
                     question(question: "What is released when the Ozone layer is depleted?", answers: ["Gamma rays", "Infrared rays", "Visible rays", "UV (ultaviolet) rays"], answer: 3, explanation: "Ultraviolet rays were the only kind of rays mentioned in the article and can result in skin cancer and cataracts."),
                     
                     //Question 9
                     question(question: "How do we make the Earth more sustainable?", answers: ["Driving less", "Having more children", "Using aerosols with CFCs", "Using packages with styrofoam peanuts"], answer: 0, explanation: "Driving by yourself increases your carbon footprint making Earth less sustainable for our future generations."),
                     
                     //Question 10
                     question(question: "What is NOT one way to save endangered animals?", answers: ["Volunteering at organizations", "Adopting an animal on WWF", "Bringing animals into exotic environments", "Donating to non-profit organizations"], answer: 2, explanation: "Bringing animals into exotic environments is the opposite of helping them, because they are exposed to environments they aren't adapted to.")]
        
        pickQuestion()
        print(questions)
        // Do any additional setup after loading the view.
    }

    func pickQuestion(){
        //reality: 10
        if QNumber < 10 {
            let question = questions[QNumber].question
            guard let answerChoices = questions[QNumber].answers else {return}
            
            correctAnswer = questions[QNumber].answer
            
            QLabel.text = question
            
            for i in 0..<buttons.count {
                buttons[i].setTitle(answerChoices[i], for: UIControl.State.normal)
                buttons[i].layer.cornerRadius = 30
                buttons[i].clipsToBounds =  true
            }
        } else {
            print("End Quiz")
            performSegue(withIdentifier: "toTrivia", sender: nil)
            // add point to greenscore
            
            if allCorrect == true {
                getScore()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.greenScore = self.greenScore + 2
                    self.enterScore()
                }
            }
        }
    }
    
    func getScore() {
        db = Firestore.firestore()
        let scoreRef = db.collection("users").document("\(userID)").collection("greenscore").document("greenscore")
        scoreRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                var newString = dataDescription.replacingOccurrences(of: "[\"greenscore\": ", with: "")
                newString = newString.replacingOccurrences(of: "]", with: "")
                
                self.greenScore = Int(newString) ?? 0
            } else {
            }
        }
    }
    
    func enterScore() {
        db = Firestore.firestore()
        db.collection("users").document("\(userID)").collection("greenscore").document("greenscore").setData([
            "greenscore": greenScore
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                
            }
        }
    }

    @IBAction func btn1(_ sender: Any) {
        
        if  correctAnswer == 0 {
            correctAudio.play()
            QNumber = QNumber + 1
            pickQuestion()
            explanation.isHidden = true
        } else {
            incorrectAudio.play()
            allCorrect = false
            let exp = questions[QNumber].explanation
            explanation.isHidden = false
            var newString = exp!.replacingOccurrences(of: "Optional(", with: "")
            newString = newString.replacingOccurrences(of: ")", with: "")
            explanation.text = "Incorrect.\n\(newString)"
        }
        
    }
    
    @IBAction func btn2(_ sender: Any) {
        
        if correctAnswer == 1 {
            correctAudio.play()
            QNumber = QNumber + 1
            pickQuestion()
            explanation.isHidden = true
            
        } else {
            incorrectAudio.play()
            allCorrect = false
            let exp = questions[QNumber].explanation
            explanation.isHidden = false
            var newString = exp!.replacingOccurrences(of: "Optional(", with: "")
            newString = newString.replacingOccurrences(of: ")", with: "")
            explanation.text = "Incorrect.\n\(newString)"
        }
        
    }
    
    @IBAction func btn3(_ sender: Any) {
        
        if correctAnswer == 2 {
            correctAudio.play()
            QNumber = QNumber + 1
            pickQuestion()
            explanation.isHidden = true
        } else {
            incorrectAudio.play()
            allCorrect = false
            let exp = questions[QNumber].explanation
            explanation.isHidden = false
            var newString = exp!.replacingOccurrences(of: "Optional(", with: "")
            newString = newString.replacingOccurrences(of: ")", with: "")
            explanation.text = "Incorrect.\n\(newString)"
        }
        
    }
    
    @IBAction func btn4(_ sender: Any) {
        
        if correctAnswer == 3 {
            correctAudio.play()
            QNumber = QNumber + 1
            pickQuestion()
            explanation.isHidden = true
        } else {
            incorrectAudio.play()
            allCorrect = false
            let exp = questions[QNumber].explanation
            explanation.isHidden = false
            var newString = exp!.replacingOccurrences(of: "Optional(", with: "")
            newString = newString.replacingOccurrences(of: ")", with: "")
            explanation.text = "Incorrect.\n\(newString)"
        }
    }
}
