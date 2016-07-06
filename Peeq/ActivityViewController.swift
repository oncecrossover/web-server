//
//  ActivityViewController.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var activityTableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  var userModule = User()
  var questionModule = Question()

  var questions:[(id: Int!, question: String!, status: String!, responderUrl: String!,
  responderName: String!, responderTitle: String!)] = []
  var answers:[(id: Int!, question: String!, status: String!, askerUrl: String!,
  askerName: String!, askerTitle: String!)] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func segmentedControlClicked(sender: AnyObject) {
    if (segmentedControl.selectedSegmentIndex == 0) {
      if (questions.count == 0) {
        loadData()
      }
      else {
        self.activityTableView.reloadData()
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      if (answers.count == 0) {
        loadData()
      }
      else {
        self.activityTableView.reloadData()
      }
    }
    else if (segmentedControl.selectedSegmentIndex == 2) {
      self.activityTableView.reloadData()
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.navigationItem.title = "Activity"
  }

  func loadData() {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    if segmentedControl.selectedSegmentIndex == 0 {
      loadDataWithFilter("asker=" + uid)
    }
    else if segmentedControl.selectedSegmentIndex == 1 {
      loadDataWithFilter("responder=" + uid)
    }

  }

  func loadDataWithFilter(filterString: String) {
    questionModule.getQuestions(filterString) { jsonArray in
      var count = jsonArray.count
      if count == 0 {
        dispatch_async(dispatch_get_main_queue()) {
          self.activityTableView.reloadData()
        }

      }
      for questionInfo in jsonArray as! [[String:AnyObject]] {
        let questionId = questionInfo["id"] as! Int
        let question = questionInfo["question"] as! String
        let status = questionInfo["status"] as! String

        if (self.segmentedControl.selectedSegmentIndex == 0) {
          let responderId = questionInfo["responder"] as! String
          self.userModule.getProfile(responderId) {name, title, about, url in
            self.questions.append((id: questionId, question: question, status: status,
              responderUrl: url, responderName: name, responderTitle: title))
            count--
            if (count == 0) {
              dispatch_async(dispatch_get_main_queue()) {
                self.activityTableView.reloadData()
              }
            }
          }
        }
        else if (self.segmentedControl.selectedSegmentIndex == 1) {
          let askerId = questionInfo["asker"] as! String
          self.userModule.getProfile(askerId){name, title, about, url in
            self.answers.append((id: questionId, question: question, status: status,
              askerUrl: url, askerName: name, askerTitle: title))
            count--
            if (count == 0) {
              dispatch_async(dispatch_get_main_queue()) {
                self.activityTableView.reloadData()
              }
            }
          }
        }
      }
    }

  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (segmentedControl.selectedSegmentIndex == 0) {
      return self.questions.count
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
      return self.answers.count
    }
    return 0
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 150
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if segmentedControl.selectedSegmentIndex == 0 {
      let myCell = tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath)
        as! QuestionTableViewCell
      let question = questions[indexPath.row]
      myCell.questionText.text = question.question
      myCell.titleLabel.text = "\(question.responderName)" + " | "  + "\(question.responderTitle)"
      myCell.profileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: question.responderUrl)!)!)
      myCell.status.text = question.status
      return myCell
    }
    else if segmentedControl.selectedSegmentIndex == 1 {
      let myCell = tableView.dequeueReusableCellWithIdentifier("answerCell", forIndexPath: indexPath) as! AnswerTableViewCell
      let answer = answers[indexPath.row]
      myCell.askerName.text = answer.askerName
      myCell.profileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: answer.askerUrl)!)!)
      myCell.status.text = answer.status
      myCell.question.text = answer.question
      return myCell
    }
    return tableView.dequeueReusableCellWithIdentifier("questionCell", forIndexPath: indexPath) as! QuestionTableViewCell
  }
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */

}
