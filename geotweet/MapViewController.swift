//
//  MapViewController.swift
//     
//
//  Created by GELE Axel on 23/01/2017.
//  Copyright © 2017 GELE Axel. All rights reserved.
//

import UIKit
import GoogleMaps
import TwitterKit
import SwiftyJSON

class MapViewController: UIViewController {
    var mapView = GMSMapView()
    var myTextField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        myTextField = UITextField(frame: CGRect(x: 0, y: 50, width: 300, height: 50))
        myTextField.placeholder = "Enter a hashtag !"
        self.view.addSubview(myTextField)
        let myButton = UIButton(type: .system)
        myButton.frame = CGRect(x: 300, y: 50, width: 114, height: 50)
//        let myButton = UIButton(frame: CGRect(x: 300, y: 50, width: 114, height: 50))
        myButton.setTitle("Find", for: .normal)
        myButton.addTarget(self, action: #selector(self.markTweet), for: .touchDown)
        view.addSubview(myButton)
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 3)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height - 100), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.zoomGestures = true
        
        

        self.view.addSubview(mapView)
        // Do any additional setup after loading the view.
    }
    
    func markTweet()
    {
        mapView.clear()
        let hashtag = "#" + myTextField.text!
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/search/tweets.json?q=" + (hashtag.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            let params = ["id": "20"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                }
                
                do {
                    let json = JSON(data: data!)
                    print(json)
                    for item in json["statuses"].arrayValue
                    {
                        print(item["geo"]["coordinates"][0])
                        let longitude = item["geo"]["coordinates"][1].double
                        let latitude = item["geo"]["coordinates"][0].double
                        if(latitude != nil && longitude != nil)
                        {
                            let  position = CLLocationCoordinate2DMake(latitude!, longitude!)
                            let marker = GMSMarker(position: position)
                            marker.title = ""
                            //marker.icon = UIImage(named: "twitter.png")
                            marker.title = item["text"].stringValue
                            marker.map = self.mapView
                            marker.opacity = 0.6

                            self.mapView.camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 3)

                        }
                    }
                    
                    
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    convenience init() {
//        let userID = Twitter.sharedInstance().sessionStore.session()?.userID
//        let client = TWTRAPIClient(userID: userID)
//        
//        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "#ronaldo", apiClient: client)
//        self.init(dataSource: dataSource)
//        
//        // Show Tweet actions
//        self.showTweetActions = true
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
