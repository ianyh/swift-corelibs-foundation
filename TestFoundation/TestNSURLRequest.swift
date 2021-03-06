// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
    import Foundation
    import XCTest
#else
    import SwiftFoundation
    import SwiftXCTest
#endif

class TestNSURLRequest : XCTestCase {
    
    static var allTests: [(String, (TestNSURLRequest) -> () throws -> Void)] {
        return [
            ("test_construction", test_construction),
            ("test_mutableConstruction", test_mutableConstruction),
            ("test_headerFields", test_headerFields),
            ("test_copy", test_copy),
            ("test_mutableCopy_1", test_mutableCopy_1),
            ("test_mutableCopy_2", test_mutableCopy_2),
            ("test_mutableCopy_3", test_mutableCopy_3),
        ]
    }
    
    let url = NSURL(string: "http://swift.org")!
    
    func test_construction() {
        let request = NSURLRequest(url: url)
        // Match OS X Foundation responses
        XCTAssertNotNil(request)
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.allHTTPHeaderFields)
        XCTAssertNil(request.mainDocumentURL)
    }
    
    func test_mutableConstruction() {
        let url = NSURL(string: "http://swift.org")!
        let request = NSMutableURLRequest(url: url)
        
        //Confirm initial state matches NSURLRequest responses
        XCTAssertNotNil(request)
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.allHTTPHeaderFields)
        XCTAssertNil(request.mainDocumentURL)
        
        request.mainDocumentURL = url
        XCTAssertEqual(request.mainDocumentURL, url)
        
        request.httpMethod = "POST"
        XCTAssertEqual(request.httpMethod, "POST")
        
        let newURL = NSURL(string: "http://github.com")!
        request.url = newURL
        XCTAssertEqual(request.url, newURL)
    }
    
    func test_headerFields() {
        let request = NSMutableURLRequest(url: url)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        XCTAssertNotNil(request.allHTTPHeaderFields)
        XCTAssertEqual(request.allHTTPHeaderFields?["Accept"], "application/json")
        
        // Setting "accept" should remove "Accept"
        request.setValue("application/xml", forHTTPHeaderField: "accept")
        XCTAssertNil(request.allHTTPHeaderFields?["Accept"])
        XCTAssertEqual(request.allHTTPHeaderFields?["accept"], "application/xml")
        
        // Adding to "Accept" should add to "accept"
        request.addValue("text/html", forHTTPHeaderField: "Accept")
        XCTAssertEqual(request.allHTTPHeaderFields?["accept"], "application/xml,text/html")
    }
    
    func test_copy() {
        let mutableRequest = NSMutableURLRequest(url: url)
        
        let urlA = NSURL(string: "http://swift.org")!
        let urlB = NSURL(string: "http://github.com")!
        mutableRequest.mainDocumentURL = urlA
        mutableRequest.url = urlB
        mutableRequest.httpMethod = "POST"
        mutableRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        guard let requestCopy1 = mutableRequest.copy() as? NSURLRequest else {
            XCTFail(); return
        }
        
        // Check that all attributes are copied and that the original ones are
        // unchanged:
        XCTAssertEqual(mutableRequest.mainDocumentURL, urlA)
        XCTAssertEqual(requestCopy1.mainDocumentURL, urlA)
        XCTAssertEqual(mutableRequest.httpMethod, "POST")
        XCTAssertEqual(requestCopy1.httpMethod, "POST")
        XCTAssertEqual(mutableRequest.url, urlB)
        XCTAssertEqual(requestCopy1.url, urlB)
        XCTAssertEqual(mutableRequest.allHTTPHeaderFields?["Accept"], "application/json")
        XCTAssertEqual(requestCopy1.allHTTPHeaderFields?["Accept"], "application/json")

        // Change the original, and check that the copy has unchanged
        // values:
        let urlC = NSURL(string: "http://apple.com")!
        let urlD = NSURL(string: "http://ibm.com")!
        mutableRequest.mainDocumentURL = urlC
        mutableRequest.url = urlD
        mutableRequest.httpMethod = "HEAD"
        mutableRequest.addValue("text/html", forHTTPHeaderField: "Accept")
        XCTAssertEqual(requestCopy1.mainDocumentURL, urlA)
        XCTAssertEqual(requestCopy1.httpMethod, "POST")
        XCTAssertEqual(requestCopy1.url, urlB)
        XCTAssertEqual(requestCopy1.allHTTPHeaderFields?["Accept"], "application/json")

        // Check that we can copy the copy:
        guard let requestCopy2 = requestCopy1.copy() as? NSURLRequest else {
            XCTFail(); return
        }
        XCTAssertEqual(requestCopy2.mainDocumentURL, urlA)
        XCTAssertEqual(requestCopy2.httpMethod, "POST")
        XCTAssertEqual(requestCopy2.url, urlB)
        XCTAssertEqual(requestCopy2.allHTTPHeaderFields?["Accept"], "application/json")
    }

    func test_mutableCopy_1() {
        let originalRequest = NSMutableURLRequest(url: url)
        
        let urlA = NSURL(string: "http://swift.org")!
        let urlB = NSURL(string: "http://github.com")!
        originalRequest.mainDocumentURL = urlA
        originalRequest.url = urlB
        originalRequest.httpMethod = "POST"
        originalRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let requestCopy = originalRequest.mutableCopy() as? NSMutableURLRequest else {
            XCTFail(); return
        }
        
        // Change the original, and check that the copy has unchanged values:
        let urlC = NSURL(string: "http://apple.com")!
        let urlD = NSURL(string: "http://ibm.com")!
        originalRequest.mainDocumentURL = urlC
        originalRequest.url = urlD
        originalRequest.httpMethod = "HEAD"
        originalRequest.addValue("text/html", forHTTPHeaderField: "Accept")
        XCTAssertEqual(requestCopy.mainDocumentURL, urlA)
        XCTAssertEqual(requestCopy.httpMethod, "POST")
        XCTAssertEqual(requestCopy.url, urlB)
        XCTAssertEqual(requestCopy.allHTTPHeaderFields?["Accept"], "application/json")
    }

    func test_mutableCopy_2() {
        let originalRequest = NSMutableURLRequest(url: url)
        
        let urlA = NSURL(string: "http://swift.org")!
        let urlB = NSURL(string: "http://github.com")!
        originalRequest.mainDocumentURL = urlA
        originalRequest.url = urlB
        originalRequest.httpMethod = "POST"
        originalRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let requestCopy = originalRequest.mutableCopy() as? NSMutableURLRequest else {
            XCTFail(); return
        }
        
        // Change the copy, and check that the original has unchanged values:
        let urlC = NSURL(string: "http://apple.com")!
        let urlD = NSURL(string: "http://ibm.com")!
        requestCopy.mainDocumentURL = urlC
        requestCopy.url = urlD
        requestCopy.httpMethod = "HEAD"
        requestCopy.addValue("text/html", forHTTPHeaderField: "Accept")
        XCTAssertEqual(originalRequest.mainDocumentURL, urlA)
        XCTAssertEqual(originalRequest.httpMethod, "POST")
        XCTAssertEqual(originalRequest.url, urlB)
        XCTAssertEqual(originalRequest.allHTTPHeaderFields?["Accept"], "application/json")
    }

    func test_mutableCopy_3() {
        let urlA = NSURL(string: "http://swift.org")!
        let originalRequest = NSURLRequest(url: urlA)
        
        guard let requestCopy = originalRequest.mutableCopy() as? NSMutableURLRequest else {
            XCTFail(); return
        }
        
        // Change the copy, and check that the original has unchanged values:
        let urlC = NSURL(string: "http://apple.com")!
        let urlD = NSURL(string: "http://ibm.com")!
        requestCopy.mainDocumentURL = urlC
        requestCopy.url = urlD
        requestCopy.httpMethod = "HEAD"
        requestCopy.addValue("text/html", forHTTPHeaderField: "Accept")
        XCTAssertNil(originalRequest.mainDocumentURL)
        XCTAssertEqual(originalRequest.httpMethod, "GET")
        XCTAssertEqual(originalRequest.url, urlA)
        XCTAssertNil(originalRequest.allHTTPHeaderFields)
    }
}
