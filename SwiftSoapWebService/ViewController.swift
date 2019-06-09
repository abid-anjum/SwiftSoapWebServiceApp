//
//  ViewController.swift
//  SwiftSoapWebService
//
//  Created by abid hussain on 06/10/1440 AH.
//  Copyright © 1440 abid hussain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    public static private(set) var StatusCode:Int?
    public static private(set) var ErrorString:String?
    public static private(set) var StatusDescription:String?
    
    public class func HasError()->Bool{
        return (self.StatusCode != nil) && (self.StatusCode !=  200);
    }
    public static private(set) var Error:Error?
    public static private(set) var ResponseString:String!
    public static private(set) var ResponseData:Data?
    
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func uploadpicture(_ sender: Any) {
        
        //let semaphore = dispatch_semaphore_create(0);
        let semaphore = DispatchSemaphore.init(value: 0)
        let url = URL.init(string: "http://127.0.0.1:8080/helloservice.asmx")
        let req = NSMutableURLRequest(url: url!)
        let image = UIImage(named:"logo")
        let data = UIImagePNGRepresentation(image!)
        let base64String = dataToBase64(data: data!)
        
        var SoapMessage = "<?xml version=\"1.0\" encoding=\"utf-16\"?>"
        SoapMessage += "<soap:Envelope"
        SoapMessage += " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
        SoapMessage += " xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\""
        SoapMessage += " xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        SoapMessage += "<soap:Body>"
        SoapMessage += "<base64upload xmlns=\"http://tempuri.org/\">"
        SoapMessage += "<fileName>file1</fileName>"
        SoapMessage += "<base64Bytes>\(base64String)</base64Bytes>"
        SoapMessage += "</base64upload>"
        SoapMessage += "</soap:Body>"
        SoapMessage += "</soap:Envelope>"

        let session = URLSession.shared
        req.httpMethod = "POST"
        req.httpBody = SoapMessage.data(using: String.Encoding.utf8, allowLossyConversion: false)
        req.addValue("text/xml;charset =utf-8", forHTTPHeaderField: "Content-Type")
        
        let contentLength = SoapMessage.utf8.count
        req.addValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        // req.addValue(SoapAction, forHTTPHeaderField: "SOAPAction")
        
        var responseData : Data = Data()
        let task_ = session.dataTask(with: req as URLRequest){ (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                ViewController.StatusCode = httpResponse.statusCode
                
                if httpResponse.statusCode != 200 {
                    
                    responseData = Data()
                    let responseString =  String.init(data: data!, encoding: String.Encoding.utf8)
                    
                    print(responseString)
                }
                else
                {
                    responseData = data!
                    ViewController.ResponseData = data
                    let responseString =  String.init(data: data!, encoding: String.Encoding.utf8)
                    
                    print(responseString)
                    
                    ViewController.ResponseString = responseString!
                }
            }
            semaphore.signal()
        }
        task_.resume()
        semaphore.wait()
    }
    
    
    public func dataToBase64(data: Data)->String {
        let result = data.base64EncodedString()
        return result
    }
}

