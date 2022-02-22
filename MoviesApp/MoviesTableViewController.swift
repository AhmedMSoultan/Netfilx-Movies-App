//
//  MoviesTableViewController.swift
//  MoviesApp
//
//  Created by Ahmed Soultan on 02/02/2022.
//

import UIKit
import SDWebImage
import Cosmos
import Alamofire
import Reachability
import CoreData

let reachability = try! Reachability() // OUTSIDE THE CLASS AT THE BEGINNING

class MoviesTableViewController: UITableViewController {
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        reachability.whenReachable = { reachabilty in
                    if reachabilty.connection == .wifi {
                        print("Reachable via wifi")
                        self.deleteEntries()
                        self.getMovies()
                        
                    } else {
                        print("Reachable via cellular")
                    }
                }
                reachability.whenUnreachable = { _ in
                    print("Not reachable")
                    self.showAlert()
                    let rMovies = self.retrieveMovies()
                    self.movies = rMovies
                    
                    self.showAlert()
                }
                
                do {
                    try reachability.startNotifier()
                } catch {
                    print("Unable to start notifier")
                }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        print(movies.count)
        ///////////////////////////////////////////////////
        /// Old Connection Way /////
        ///
//        let url = URL(string: "https://api.androidhive.info/json/movies.json")!
//        let request = URLRequest(url: url)
//        let session = URLSession(configuration: URLSessionConfiguration.default)
//
//        let task = session.dataTask(with: request, completionHandler: {(data,response,error) in
//            do{
//                let moviesFromApi = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Dictionary<String,Any>]
//
//                for i in 0...moviesFromApi.count-1{
//                    let mov = Movie()
//                    mov.title = moviesFromApi[i]["title"] as! String
//                    mov.image = moviesFromApi[i]["image"] as! String
//                    mov.rating = moviesFromApi[i]["rating"] as! Double
//                    mov.releaseYear = moviesFromApi[i]["releaseYear"] as! Int
//                    mov.genre = moviesFromApi[i]["genre"] as! [String]
//                    self.movies.append(mov)
//                    print(self.movies.count)
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//            }catch{
//                print("Error")
//            }
//        })
//        task.resume()
        
        ////////////////////////////////////////////////////////////
        
//        Alamofire.request("https://api.androidhive.info/json/movies.json").validate().responseJSON { response in
//            switch response.result {
//            case .success:
//                response.data
//            case .failure:
//
//            default:
//                <#code#>
//            }
//        }
    }
    
    func getMovies() {
            Alamofire.request("https://api.androidhive.info/json/movies.json", method: .get).validate().responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    let jsonDecoder = JSONDecoder()
                    if let moviesData = try? jsonDecoder.decode([Movie].self, from: response.data!) {
                        self.movies = moviesData
                        self.saveMovieData(movies: self.movies)
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    
    // Core data connection //
    
    func saveMovieData(movies:[Movie]){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for movie in movies {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "MovieEntity", in: context)else{return}
            let newValue = NSManagedObject(entity: entityDescription, insertInto: context)
            newValue.setValue(movie.title, forKey: "title")
            newValue.setValue(movie.image, forKey: "image")
            newValue.setValue(movie.rating, forKey: "rating")
            newValue.setValue(movie.releaseYear, forKey: "releaseYear")
            newValue.setValue(movie.genre, forKey: "genre")
            do{
                try context.save()
                print("Movie Saved Successfully")
            }catch{
                print("Error While saving data")
            }
        }
    }
    
    
    func retrieveMovies()-> [Movie]{
        
        var retrievedMovies: [Movie] = []
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"MovieEntity")
        do{
            let cashedMovies = try context.fetch(fetchRequest)
                    if !cashedMovies.isEmpty {
                        for movie in cashedMovies {
                            let title = (movie.value(forKey: "title") as? String)!
                            let image = (movie.value(forKey: "image") as? String)!
                            let rating = movie.value(forKey: "rating") as? Double
                            let releaseYear = (movie.value(forKey: "releaseYear") as? Int)!
                            let genre = (movie.value(forKey: "genre") as? [String])!

                            let movie = Movie(title: title, image: image, rating: rating!, releaseYear: releaseYear, genre: genre)
                            retrievedMovies.append(movie)
                        }
                    }
                }catch{
                print("Fetching data failed")
            }
        return retrievedMovies
    }
    
    func deleteEntries() {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MovieEntity")
            let request: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(request)
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        
        let movieTitle:UILabel =  cell.viewWithTag(1) as! UILabel
        movieTitle.text = movies[indexPath.row].title
        
        let movieReleaseYear:UILabel =  cell.viewWithTag(2) as! UILabel
        movieReleaseYear.text = String(movies[indexPath.row].releaseYear)
        
        let movieRating =  cell.viewWithTag(3) as! CosmosView
        movieRating.rating = movies[indexPath.row].rating/2
        movieRating.settings.updateOnTouch = false
        
        let movieGenres:UITextView =  cell.viewWithTag(4) as! UITextView
        for movieGenre in movies[indexPath.row].genre {
            movieGenres.text.append("\n" + movieGenre)
        }
        
//        let movieImgView:UIImageView = cell.viewWithTag(5) as! UIImageView
//        movieImgView.image = UIImage(named:movies[indexPath.row].image)
        
        let movieImgView:UIImageView = cell.viewWithTag(5) as! UIImageView
        movieImgView.sd_setImage(with: URL(string: movies[indexPath.row].image), placeholderImage: UIImage(named: "moviesImagePlaceHolder"))
        movieImgView.layer.cornerRadius = 20
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = self.storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetailsViewController
        details.detailedMovie = movies[indexPath.row]
        print(details.detailedMovie.title)
        self.navigationController?.pushViewController(details, animated: true)
    }
    
    // the alert function
    func showAlert() {
            let alert = UIAlertController(title: "No Internet", message: "Netfilx Movies Requires Wifi-Internet Connection!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {_ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    /*
    func initializeMovies(){
        let mov1 = Movie()
        mov1.title = "Man of steel"
        mov1.rating = 4.0
        mov1.genre = ["Action","Super Hero"]
        mov1.releaseYear = 2010
        mov1.image = "manOfSteel"
        movies.insert(mov1, at: 0)
        
        let mov2 = Movie()
        mov2.title = "Flash"
        mov2.rating = 4.3
        mov2.genre = ["Action","Super Hero"]
        mov2.releaseYear = 2020
        mov2.image = "flash"
        movies.append(mov2)
        
        let mov3 = Movie()
        mov3.title = "Bat Man"
        mov3.rating = 3.8
        mov3.genre = ["Action","Super Hero"]
        mov3.releaseYear = 2018
        mov3.image = "batMan"
        movies.append(mov3)
        
        let mov4 = Movie()
        mov4.title = "Thor"
        mov4.rating = 4.5
        mov4.genre = ["Action","Super Hero"]
        mov4.releaseYear = 2019
        mov4.image = "Thor"
        movies.append(mov4)
        
        let mov5 = Movie()
        mov5.title = "Spider Man"
        mov5.rating = 4.2
        mov5.genre = ["Action","Super Hero"]
        mov5.releaseYear = 2021
        mov5.image = "spiderMan"
        movies.append(mov5)
        
        
    }*/

}
