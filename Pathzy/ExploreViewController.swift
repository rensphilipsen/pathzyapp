//
//  ViewController.swift
//  Pathzy
//
//  Created by Rens Philipsen on 21-04-16.
//  Copyright © 2016 ExstoDigital. All rights reserved.
//

import UIKit
import MapKit

class ExploreViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var Locations = [Location]()
    var locationManager: CLLocationManager!
    var FillColor = UIColor()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        self.loadJsonData()
        _ = self.setInterval(5, block: { () -> Void in
            self.loadJsonData()
        })
        
        self.mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Setting the current location to camera
        //let location = locations.last
        //let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = FillColor.colorWithAlphaComponent(0.5)
        circleRenderer.strokeColor = FillColor.colorWithAlphaComponent(1)
        circleRenderer.lineWidth = 3
        
        let mapPoint = MKMapPointForCoordinate(mapView.userLocation.coordinate);
        let circlePoint = circleRenderer.pointForMapPoint(mapPoint)
        let entered = CGPathContainsPoint(circleRenderer.path, nil, circlePoint, false)
        
        if(entered) {
            print("entered!!")
        }
        
        
        return circleRenderer
    }
    

    func loadJsonData() {
        let url = NSURL(string: "http://pathzy.nl/getlocations.php?getAll")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if (data != nil) {
                do
                {
                    if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    {
                        self.parseJsonData(jsonObject)
                    }
                }
                catch
                {
                    print("Error parsing JSON data")
                }
            }
        }
        dataTask.resume()
    }
    
    func parseJsonData(jsonObject:AnyObject) {
        if let jsonData = jsonObject as? NSArray
        {
            self.Locations.removeAll()
            for item in jsonData
            {
                let userData = item.objectForKey("user")! as! [String: String]
                let user = User(
                    id: Int(userData["id"]!)!,
                    username: userData["name"]!,
                    color: userData["color"]!)
                
                let newLocation = Location(
                    id: Int(item.objectForKey("id") as! String)!,
                    user: user,
                    title: item.objectForKey("title") as! String,
                    latitude: Double(item.objectForKey("pos_latitude") as! String)!,
                    longitude: Double(item.objectForKey("pos_longitude") as! String)!,
                    radius: Double(item.objectForKey("radius") as! String)!
                )
                self.Locations.append(newLocation);
            }
        }
        self.loadLocations()
    }
    
    func loadLocations(){
        dispatch_async(dispatch_get_main_queue(), {
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
        })
        
        for location in self.Locations {
            dispatch_async(dispatch_get_main_queue(), {
                self.FillColor = self.colorWithHexString(location.user.color)
                let locationCoords = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                self.mapView.addOverlay(MKCircle(centerCoordinate: locationCoords, radius: location.radius))
            })
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(0.2))
    }
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
    }
    
    func setInterval(interval:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(interval, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
    }
}

