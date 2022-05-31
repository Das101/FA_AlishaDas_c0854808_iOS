//
//  ViewController.swift
//  TicTacToe
//
//  Created by Alisha on 30/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var scoreX: UILabel!
    @IBOutlet weak var score0: UILabel!
    
    
    @IBOutlet weak var btn0: UIButton!{
        didSet{
            btn0.tag = 0
        }
    }
    @IBOutlet weak var btn1: UIButton!{
        didSet{
            btn1.tag = 1
        }
    }
    @IBOutlet weak var btn2: UIButton!{
        didSet{
            btn2.tag = 2
        }
    }
    @IBOutlet weak var btn3: UIButton!{
        didSet{
            btn3.tag = 3
        }
    }
    @IBOutlet weak var btn4: UIButton!{
        didSet{
            btn4.tag = 4
        }
    }
    @IBOutlet weak var btn5: UIButton!{
        didSet{
            btn5.tag = 5
        }
    }
    @IBOutlet weak var btn6: UIButton!{
        didSet{
            btn6.tag = 6
        }
    }
    @IBOutlet weak var btn7: UIButton!{
        didSet{
            btn7.tag = 7
        }
    }
    @IBOutlet weak var btn8: UIButton!{
        didSet{
            btn8.tag = 8
        }
    }
    
    @IBOutlet var superView: UIView!
    var turn = 0
    var scorX = 0
    var scor0 = 0
    var buttonArray0 = [UIButton]()
    var allButtons = [UIButton]()
    var buttonArrayX = [UIButton]()
    let winningCombo = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
    var scoreContext: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        allButtons.append(btn0)
        allButtons.append(btn1)
        allButtons.append(btn2)
        allButtons.append(btn3)
        allButtons.append(btn4)
        allButtons.append(btn5)
        allButtons.append(btn6)
        allButtons.append(btn7)
        allButtons.append(btn8)
        
        whosTurn()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeUp)
        self.superView.addGestureRecognizer(swipeUp)
        
        self.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")

      do {
          scoreContext = try managedContext.fetch(fetchRequest)
          if scoreContext.count > 0{
          scor0 = scoreContext[0].value(forKeyPath: "score0") as? Int ?? 0
          self.score0.text = "\(scor0)"
          scorX = scoreContext[0].value(forKeyPath: "scoreX") as? Int ?? 0
          self.scoreX.text = "\(scorX)"
          }
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            showAlertMsg(Message: "Do you want to undo your move?", AutoHide: false, from: "UNDO")
        }
    }
    func save(scorePar: Int,name:String) {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }

      let managedContext = appDelegate.persistentContainer.viewContext
        if scoreContext.count > 0{
        managedContext.delete(scoreContext[0])
        }
      let entity = NSEntityDescription.entity(forEntityName: "Score", in: managedContext)!
      let score = NSManagedObject(entity: entity, insertInto: managedContext)
        if name == "0"{
            score.setValue(scorePar, forKeyPath: "score0")
        }else{
            score.setValue(scorePar, forKeyPath: "scoreX")
        }
      do {
        try managedContext.save()
          let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Score")
          do {
              scoreContext = try managedContext.fetch(fetchRequest)
          }
          
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    @IBAction func onPressBtn(_ sender: UIButton){
        if !buttonArray0.contains(sender) && !buttonArrayX.contains(sender){
        changeState(sender: sender)
        }
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.up:
                showAlertMsg(Message: "Do you want to reset the score?", AutoHide: false, from: "RESET")
            default:
                 break
            }
        }
    }
    func whosTurn(){
        if turn == 0{
            score0.textColor = .white
            scoreX.textColor = .black
        }else{
            scoreX.textColor = .white
            score0.textColor = .black
        }
    }
    func changeState(sender:UIButton){
        if turn == 0{
            sender.setImage(UIImage(systemName: "circle"), for: .normal)
            buttonArray0.append(sender)
            turn = 1
            whosTurn()
            check0()
        }else{
            sender.setImage(UIImage(systemName: "xmark"), for: .normal)
            buttonArrayX.append(sender)
            checkX()
            turn = 0
            whosTurn()
        }
    }
    func check0(){
        var checkArray = [Int]()
        var flag = false
        for item in buttonArray0{
            checkArray.append(item.tag)
        }
        let buttonSet = Set(checkArray)
        for item in winningCombo{
        let checkSet = Set(item)
            if checkSet.isSubset(of: buttonSet){
                scor0 = scor0 + 1
                self.score0.text = "\(scor0)"
                showAlertMsg(Message: "0 Won", AutoHide: false, from: "GAME")
                flag = true
                save(scorePar: scor0,name:"0")
            }
        }
        if !flag{
            if buttonArray0.count + buttonArrayX.count > 8{
                showAlertMsg(Message: "Game Tie", AutoHide: false, from: "GAME")
            }
        }
    }
    func checkX(){
        var flag = false
        var checkArray = [Int]()
        for item in buttonArrayX{
            checkArray.append(item.tag)
        }
        let buttonSet = Set(checkArray)
        for item in winningCombo{
        let checkSet = Set(item)
            if checkSet.isSubset(of: buttonSet){
             scorX = scorX + 1
                self.scoreX.text = "\(scorX)"
                showAlertMsg(Message: "X Won", AutoHide: false, from: "GAME")
                flag = true
                save(scorePar: scorX,name:"X")
            }
        }
        if !flag{
            if buttonArray0.count + buttonArrayX.count > 8{
                showAlertMsg(Message: "Game Tie", AutoHide: false, from: "GAME")
            }
        }
    }
    func resetGame(){
        DispatchQueue.main.async
            {
                self.btn0.imageView?.image = nil
                self.btn1.imageView?.image = nil
                self.btn2.imageView?.image = nil
                self.btn3.imageView?.image = nil
                self.btn4.imageView?.image = nil
                self.btn5.imageView?.image = nil
                self.btn6.imageView?.image = nil
                self.btn7.imageView?.image = nil
                self.btn8.imageView?.image = nil
                self.turn = 0
                self.whosTurn()
                self.buttonArray0.removeAll()
                self.buttonArrayX.removeAll()
            }
    }
    func showAlertMsg(Message: String, AutoHide:Bool,from:String) -> Void
    {
        DispatchQueue.main.async
            {
            let alert = UIAlertController(title: "", message: Message, preferredStyle: UIAlertController.Style.alert)
            
            if AutoHide == true
            {
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime)
                {
                    print("Alert Dismiss")
                    alert.dismiss(animated: true, completion:nil)
                }
            }
            else
            {
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                    if from == "GAME"{
                        self.resetGame()
                    }else if from == "RESET"{
                        self.resetGame()
                        self.scor0 = 0
                        self.score0.text = "0"
                        self.scorX = 0
                        self.scoreX.text = "0"
                    }
                    else if from == "UNDO"{
                        if self.turn == 0{
                            if self.buttonArrayX.count != 0 {
                            self.buttonArrayX.last?.imageView?.image = nil
                            self.buttonArrayX.removeLast()
                                self.turn = 1
                                self.checkmarks()
                            }
                        }else{
                            if self.buttonArray0.count != 0 {
                            self.buttonArray0.last?.imageView?.image = nil
                            self.buttonArray0.removeLast()
                                self.turn = 0
                                self.checkmarks()
                            }
                        }
                    }
                }))
                if from == "RESET" || from == "UNDO"{
                    alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) in
                        if from == "UNDO"{
                            self.checkmarks()
                        }
                    }))
                }
            }
            UIApplication.shared.windows[0].rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    func checkmarks(){
        for item in allButtons{
            if !buttonArray0.contains(item) && !buttonArrayX.contains(item){
                item.imageView?.image = nil
            }else if buttonArray0.contains(item){
                item.setImage(UIImage(systemName: "circle"), for: .normal)
            }else if buttonArrayX.contains(item){
                item.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
        }
    }
    
}

