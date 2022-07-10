import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var city: UITextField!
    
    let loc = CLLocationManager()
    var lat: CLLocationDegrees = 0.0
    var lon: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loc.delegate = self
        loc.requestWhenInUseAuthorization()
        loc.requestLocation()
        
        
        city.delegate = self
        // Do any additional setup after loading the view.
    }


    @IBAction func cl(_ sender: Any) {
        loc.requestLocation()
    }
   
    @IBAction func sea(_ sender: Any) {
        city.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if city.text == ""
        {
            city.placeholder = "Type Something"
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        city.endEditing(true)
        print(city.text!)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        fetWC(c: "C")
    }
    
    func fetWC(c:String)
    {
        let ur: String
        if c == "C"
        {
            ur = "https://api.openweathermap.org/data/2.5/weather?appid=644e3c6afb3ce044715e77d2e51d652c&units=metric&q=" + city.text!
        }
        else
        {
            ur = "https://api.openweathermap.org/data/2.5/weather?appid=644e3c6afb3ce044715e77d2e51d652c&units=metric&lat=\(lat)&lon=\(lon)"
        }
        
        if let url = URL(string: ur)
        {
            let urls = URLSession(configuration: .default)
            let task = urls.dataTask(with: url) { data, response, error in
                if error != nil
                {
                    print(error!)
                    return
                }
                if let sD = data
                {
                    self.decJSON(data: sD)
                }
            }
            task.resume()
            
        }
        
        city.text = ""
    }
    
    func decJSON(data: Data)
    {
        let decoder = JSONDecoder()
        do
        {
            let fD = try decoder.decode(app.self, from: data)
            var sym: String
            {
                switch fD.weather[0].id {
                        case 200...232:
                            return "cloud.bolt"
                        case 300...321:
                            return "cloud.drizzle"
                        case 500...531:
                            return "cloud.rain"
                        case 600...622:
                            return "cloud.snow"
                        case 701...781:
                            return "cloud.fog"
                        case 800:
                            return "sun.max"
                        case 801...804:
                            return "cloud.bolt"
                        default:
                            return "cloud"
                        }

            }
            DispatchQueue.main.async {
                self.temperatureLabel.text = String(format: "%.01f", fD.main.temp)
                self.conditionImageView.image = UIImage(systemName: sym)
                self.cityLabel.text = fD.name
            }
        }
        catch
        {
            print(error)
        }
    }
}

//Mark: - Loc

extension WeatherViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let l = locations.last
        {
            loc.stopUpdatingLocation()
            lat = l.coordinate.latitude
            lon = l.coordinate.longitude
            fetWC(c: "0")
            print(lat,lon)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error,"   hello")
    }
}
