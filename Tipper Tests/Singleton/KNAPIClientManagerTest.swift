//
//  KNAPIClientManagerTest.swift
//  Tipper
//
//  Created by Jay N. 12/26/14.
//  Copyright (c) 2014 Knodeit.com. All rights reserved.
//
/*
import UIKit
import XCTest
import Tipper

class KNAPIClientManagerTest: XCTestCase {
    
    var rightUser: User? = User.createObject()
    var wrongUser: User? = User.createObject()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        rightUser!.email = "loc00@gmail.com"
        rightUser!.publicName = "Loc 00"
        rightUser!.password = "123456"
        rightUser!.userId = "54aa54c009b8da897839f563"
        rightUser!.accessToken = "991331de-1562-421f-b487-81ff4569dc68"
        rightUser!.passcode = "1111"
        
        wrongUser!.email = "loc001@gmail.com"
        wrongUser!.publicName = "Loc 001"
        wrongUser!.password = "12345"
        wrongUser!.accessToken = "123456789"
        wrongUser!.passcode = "1111"
        
        // delete all cards
        KNUserManager.sharedInstance.saveAccountInfoWithPass(self.rightUser!.userId!, pass: self.rightUser!.password!, accessToken: self.rightUser!.accessToken!)
        
        // Declare our expectation
        var registeredCards:Array<Card>?
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getListRegisteredCards { (cards, responseObj) -> () in
            
            registeredCards = cards
            readyExpectation.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        for card in registeredCards! {
            
            // //Declare our expectation
            let readyExpectationForDeletingCard = expectationWithDescription("ready")
            
            KNAPIClientManager.sharedInstance.deleteCard(card.id!) { (responseObj) -> () in
                
                readyExpectationForDeletingCard.fulfill()
            }
            
            // Loop until the expectation is fulfilled
            waitForExpectationsWithTimeout(10, { error in
                XCTAssertNil(error, "Error")
            })
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
      
        // Add one card for use later
        let readyExpectation = expectationWithDescription("ready")
        
        var name:String = "Visa"
        var cardNumber:String = "4012888888881881"
        var expMonth:String = "12"
        var expYear:String = "2020"
        var cvc:String = "000"
        
        KNAPIClientManager.sharedInstance.addCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
            
            readyExpectation.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })

    }
    
    func testAccessToken() {
        let data:Dictionary = KNAPIClientManager.sharedInstance.accessToken()
        XCTAssertNotNil(data, "It shouldn't be nil")
    }
    
    func testCheckEmailExist() {
        // Declare our expectation
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.checkEmailExist(self.rightUser!.email!, loggedUser: self.rightUser!, completed: { (success, user, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It shouldn't be have errors")
            // And fulfill the expectation...
            readyExpectation.fulfill()
        })
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        var user1: User = User.createObject()
        KNAPIClientManager.sharedInstance.checkEmailExist(self.wrongUser!.email!, loggedUser: self.wrongUser!, completed: { (success, user, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            // And fulfill the expectation...
            readyExpectation1.fulfill()
        })
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testLogin() {
        //test login success
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.login(self.rightUser!.email!, password: self.rightUser!.password!, loggedUser: self.rightUser!) { (success, user, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It shouldn't be have errors")
            // And fulfill the expectation...
            readyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        //test login fail
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.login(self.wrongUser!.email!, password: self.wrongUser!.password!, loggedUser: self.wrongUser!) { (success, user, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNil(user, "It should be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            // And fulfill the expectation...
            readyExpectation1.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test_1_CreateAccount() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.createAccount("", email: self.rightUser!.email!, username: self.rightUser!.publicName!, password: self.rightUser!.password!, confirmPassowrd: self.rightUser!.password!, loggedUser: self.rightUser!, completed: { (success, user, errors) -> () in
                XCTAssertFalse(success, "It should be false")
                XCTAssertNil(user, "It should be nil")
                XCTAssertTrue(errors?.count > 0, "It should be have errors")
                readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.createAccount("", email: self.wrongUser!.email!, username: self.wrongUser!.publicName!, password: self.wrongUser!.password!, confirmPassowrd: self.wrongUser!.password!, loggedUser: self.wrongUser!, completed: { (success, user, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation1.fulfill()
            KNAPIClientManager.sharedInstance.deleteRegistration(user!.userId!, completed: { (success, errors) -> () in
                
            })
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test_2_DeleteRegistration() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.deleteRegistration(self.rightUser!.userId!, completed: { (success, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.createAccount("", email: self.wrongUser!.email!, username: self.wrongUser!.publicName!, password: self.wrongUser!.password!, confirmPassowrd: self.wrongUser!.password!, loggedUser: self.wrongUser!, completed: { (success, user, errors) -> () in
            KNAPIClientManager.sharedInstance.deleteRegistration(user!.userId!, completed: { (success, errors) -> () in
                XCTAssertTrue(success, "It should be true")
                XCTAssertTrue(errors == nil, "It should be nil")
                readyExpectation1.fulfill()
            })
        })
        waitForExpectationsWithTimeout(10, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetUserProfile() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getUserProfile(self.rightUser!.accessToken!, currentUser: self.rightUser! ,completed: { (success, user, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getUserProfile(self.wrongUser!.accessToken!, currentUser: self.wrongUser!, completed: { (success, user, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNil(user, "It should be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation1.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testUpdateAccount() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.updateAccount("", email: self.rightUser!.email!, username: self.rightUser!.publicName!, password: self.rightUser!.password!, confirmPassowrd: self.rightUser!.password!, accessToken: self.rightUser!.accessToken!, loggedUser: self.rightUser!) { (success, user, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(user, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })

        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.updateAccount("", email: self.wrongUser!.email!, username: self.wrongUser!.publicName!, password: self.wrongUser!.password!, confirmPassowrd: self.wrongUser!.password!, accessToken: self.wrongUser!.accessToken!, loggedUser: self.wrongUser!) { (success, user, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNil(user, "It should be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation1.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
  
    func testSetUpPasscode() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.setUpPasscode(self.rightUser!.password!, pinCode: self.rightUser!.passcode!, accessToken: self.rightUser!.accessToken!) { (success, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.setUpPasscode(self.wrongUser!.password!, pinCode: self.wrongUser!.passcode!, accessToken: self.wrongUser!.accessToken!) { (success, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation1.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testCheckPinCode() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.checkPinCode(self.rightUser!.accessToken!, completed: { (success, changed, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(changed, "PETER")
            //XCTAssertTrue(changed, "It should be true")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.checkPinCode(self.wrongUser!.accessToken!, completed: { (success, changed, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNil(changed, "It should be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation1.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetCurrentBlance() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getCurrentBlance(self.rightUser!.accessToken!, completed: { (success, balance, errors) -> () in
            XCTAssertTrue(success, "It should be true")
            XCTAssertNotNil(balance, "It shouldn't be nil")
            XCTAssertTrue(errors == nil, "It should be nil")
            readyExpectation.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getCurrentBlance(self.wrongUser!.accessToken!, completed: { (success, balance, errors) -> () in
            XCTAssertFalse(success, "It should be false")
            XCTAssertNil(balance, "It should be nil")
            XCTAssertTrue(errors?.count > 0, "It should be have errors")
            readyExpectation1.fulfill()
        })
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetListOfFriend() {
        
        // test get list success
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getListOfFriends { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testAddFriend() {
    
        // test get list success
        var friends:Array<Friend> = Array<Friend>()
        
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getListOfFiends("", completed: { (responseObj) -> () in
            
            if(responseObj.status == kAPIStatusOk) {
                
                // Add new friend to list
                let apiFriends: NSArray = responseObj.dataObject as NSArray
                for (var i = 0; i < apiFriends.count; i++) {
                    var newFriend: Friend = Friend.createObject()
                    newFriend.parseFromAPI(apiFriends[i])
                    friends.append(newFriend)
                }
            }
            
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        if friends.count > 0 {
        
            for friend in friends {
            
                if friend.isFavorite == false {
                
                    let readyExpectation1 = expectationWithDescription("ready")
                    KNAPIClientManager.sharedInstance.addFriend(friend.friendId!, completed: { (responseObj) -> () in
                        
                        XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
                        XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
                        readyExpectation.fulfill()
                    })
                    
                    waitForExpectationsWithTimeout(5, { error in
                        XCTAssertNil(error, "Error")
                    })
                }
            }
        }
    }
    
    func testSearchFriend(){
        
        // test get list success
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getListOfFiends("Tony", completed: { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            readyExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testGetTaskId(){
    
        // test get list success
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getTaskId { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetTaskStatus(){
    
        // test get list success
        var taskId:String?
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getTaskId { (responseObj) -> () in
            
            let data = responseObj.dataObject as NSDictionary
            taskId = data["id"] as String?
            readyExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        // test get list success
        let readyExpectation1 = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getTaskStatus(taskId!, completed: { (responseObj) -> () in
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            readyExpectation1.fulfill()
            })
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testSynAddressBook() {
    
        // test get list success
        var contacts:Array<KNAddressRecord> = Array<KNAddressRecord>()
        var contact1:KNAddressRecord = KNAddressRecord()
        contact1.firstName = "Tony"
        contact1.lastName = "H 1"
        contact1.phoneNumbers = ["84123456789"]
        contact1.emails = ["tonyh1@nustechnology.com"]
        contact1.recID = "1"
        
        var contact2:KNAddressRecord = KNAddressRecord()
        contact2.firstName = "Tony"
        contact2.lastName = "H 2"
        contact2.phoneNumbers = ["84123456789"]
        contact2.emails = ["tonyh2@nustechnology.com"]
        contact2.recID = "2"
        
        var contact3:KNAddressRecord = KNAddressRecord()
        contact3.firstName = "Tony"
        contact3.lastName = "H 3"
        contact3.phoneNumbers = ["84123456789"]
        contact3.emails = ["tonyh3@nustechnology.com"]
        contact3.recID = "3"
        
        var contact4:KNAddressRecord = KNAddressRecord()
        contact4.firstName = "Tony"
        contact4.lastName = "H 4"
        contact4.phoneNumbers = ["84123456789"]
        contact4.emails = ["tonyh4@nustechnology.com"]
        contact4.recID = "4"
        
        var contact5:KNAddressRecord = KNAddressRecord()
        contact5.firstName = "Tony"
        contact5.lastName = "H 5"
        contact5.phoneNumbers = ["84123456789"]
        contact5.emails = ["tonyh5@nustechnology.com"]
        contact5.recID = "5"
        
        var contact6:KNAddressRecord = KNAddressRecord()
        contact6.firstName = "Tony"
        contact6.lastName = "H 6"
        contact6.phoneNumbers = ["84123456789"]
        contact6.emails = ["tonyh6@nustechnology.com"]
        contact6.recID = "6"
        
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.synAddressBook(contacts, completed: { (responseObj) -> () in
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            readyExpectation.fulfill()
            })
        
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testGetTipHistoryList() {
        // test get list success
        let readyExpectation = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getTipHistoryList(self.rightUser!.accessToken!, completed: { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            
            readyExpectation.fulfill()
        })
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        // test get list fail
        let readyExpectation1 = expectationWithDescription("ready")
        
        KNAPIClientManager.sharedInstance.getTipHistoryList(self.wrongUser!.accessToken!, completed: { (responseObj) -> () in
            XCTAssertNotEqual(responseObj.status, kAPIStatusOk, "It shouldn't be OK")
            XCTAssertNil(responseObj.dataObject, "It should be nil")
            
            readyExpectation1.fulfill()
        })
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testAddCard(){
    
        KNUserManager.sharedInstance.saveAccountInfoWithPass(self.rightUser!.userId!, pass: self.rightUser!.password!, accessToken: self.rightUser!.accessToken!)
        
        // Declare our expectation
        let readyExpectation = expectationWithDescription("ready")
        
        var name:String = "Visa"
        var cardNumber:String = "4012888888881881"
        var expMonth:String = "12"
        var expYear:String = "2020"
        var cvc:String = "000"
        
        KNAPIClientManager.sharedInstance.addCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            
            readyExpectation.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        // test for faild case
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.addCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
            
            XCTAssertNotEqual(responseObj.status, kAPIStatusOk, "It shouldn't be OK")
            XCTAssertNil(responseObj.dataObject, "It should be nil")
            
            readyExpectation1.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func testGetListRegisteredCards(){
        
        KNUserManager.sharedInstance.saveAccountInfoWithPass(self.rightUser!.userId!, pass: self.rightUser!.password!, accessToken: self.rightUser!.accessToken!)
        
        // Declare our expectation
        let readyExpectationForAddingCard = expectationWithDescription("ready")
        
        var name:String = "Visa"
        var cardNumber:String = "4012888888881881"
        var expMonth:String = "12"
        var expYear:String = "2020"
        var cvc:String = "000"
        
        KNAPIClientManager.sharedInstance.addCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
            
            readyExpectationForAddingCard.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        // Declare our expectation for getting registered cards
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getListRegisteredCards { (cards, responseObj) -> () in
            
            let result = cards!.count > 0
            XCTAssertTrue(result, "It should contain cards")
            
            readyExpectation.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testDeleteCard(){
        
        var deletingCardId:String?
        
        KNUserManager.sharedInstance.saveAccountInfoWithPass(self.rightUser!.userId!, pass: self.rightUser!.password!, accessToken:self.rightUser!.accessToken!)
        
        // Declare our expectation
        let readyExpectationForAddingCard = expectationWithDescription("ready")
        
        var name:String = "Visa"
        var cardNumber:String = "4012888888881881"
        var expMonth:String = "12"
        var expYear:String = "2020"
        var cvc:String = "000"
        
        KNAPIClientManager.sharedInstance.addCard(name, cardNumber: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvc) { (responseObj) -> () in
            
            readyExpectationForAddingCard.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
        // //Declare our expectation
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.getListRegisteredCards { (cards, responseObj) -> () in
            
            if  cards!.count > 0 {
                deletingCardId = cards![0].id
            }
            
            readyExpectation.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
        
      
        let readyExpectation1 = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.deleteCard(deletingCardId!) { (responseObj) -> () in
            
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "It should be OK")
            XCTAssertNotNil(responseObj.dataObject, "It shouldn't be nil")
            
            readyExpectation1.fulfill()
        }
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })

    }
     
    func testLogout() {
        let readyExpectation = expectationWithDescription("ready")
        KNAPIClientManager.sharedInstance.logout { (responseObj) -> () in
            XCTAssertEqual(responseObj.status, kAPIStatusOk, "String are equal")
            readyExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(5, { error in
            XCTAssertNil(error, "Error")
        })
    }

}
 

*/