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
        //let location = locations.last
        //let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blueColor()
        circleRenderer.lineWidth = 1
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
                let newLocation = Location(
                    id: Int(item.objectForKey("id") as! String)!,
                    title: item.objectForKey("title") as! String,
                    latitude: Double(item.objectForKey("pos_latitude") as! String)!,
                    longitude: Double(item.objectForKey("pos_longitude") as! String)!,
                    radius: Double(item.objectForKey("radius") as! String)!,
                    strokeWidth: Double(item.objectForKey("stroke_width") as! String)!,
                    strokeColor: item.objectForKey("stroke_color") as! String,
                    fillColor: item.objectForKey("fill_color") as! String
                )
                self.Locations.append(newLocation);
            }
        }
        self.loadLocations()
    }
    
    func loadLocations(){
        for location in self.Locations {
            dispatch_async(dispatch_get_main_queue(), {
                let locationCoords = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                self.mapView.addOverlay(MKCircle(centerCoordinate: locationCoords, radius: location.radius))
            });
            
            
            /*let radius = GMSCircle()
            radius.position = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            radius.radius = location.radius
            radius.strokeWidth = 2
            radius.strokeColor =
            radius.fillColor =
            radius.title = location.title
            radius.map = mapView*/
        }
    }
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
    }
    
    func setInterval(interval:NSTimeInterval, block:()->Void) -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(interval, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
    }
}

