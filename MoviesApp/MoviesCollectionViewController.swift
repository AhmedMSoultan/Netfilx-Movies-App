//
//  MoviesCollectionViewController.swift
//  MoviesApp
//
//  Created by Ahmed Soultan on 07/02/2022.
//

import UIKit
import Cosmos
import Alamofire
import Reachability
import Kingfisher
import CoreData

//private let reuseIdentifier = "Cell"
//let reachability = try! Reachability()

class MoviesCollectionViewController: UICollectionViewController , UICollectionViewDelegateFlowLayout {
    
    var movies = [Movie]()
    let cellPadding = 8.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachability.whenReachable = { reachabilty in
                    if reachabilty.connection == .wifi {
                        print("Reachable via wifi")
                        self.deleteEntries()
                        self.getMovies()
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    } else {
                        print("Reachable via cellular")
                    }
                }
                reachability.whenUnreachable = { _ in
                    print("Not reachable")
                    self.showAlert()
                    let rMovies = self.retrieveMovies()
                    self.movies = rMovies
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
                do {
                    try reachability.startNotifier()
                } catch {
                    print("Unable to start notifier")
                }
        
        navigationItem.title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    func getMovies() {
            Alamofire.request("https://api.androidhive.info/json/movies.json", method: .get).validate().responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    let jsonDecoder = JSONDecoder()
                    if let moviesData = try? jsonDecoder.decode([Movie].self, from: response.data!) {
                        self.movies = moviesData
                        self.saveMovieData(movies: self.movies)
                        self.collectionView.reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colItem", for: indexPath) as! customCollectionViewCell
        cell.contentView.layer.cornerRadius = 20
        // Configure the cell
        let url = URL(string: movies[indexPath.row].image)
        cell.movieImg.kf.setImage(with: url)
//        cell.movieImg.layer.cornerRadius =
        
        return cell
    }
    
    // the alert function
    func showAlert() {
            let alert = UIAlertController(title: "No Internet", message: "Netfilx Movies Requires Wifi-Internet Connection!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: {_ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let details = self.storyboard?.instantiateViewController(withIdentifier: "movieDetails") as! MovieDetailsViewController
        details.detailedMovie = movies[indexPath.row]
        print(details.detailedMovie.title)
        self.navigationController?.pushViewController(details, animated: true)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0.5 , left: 0, bottom: 0.5, right: 0)
//    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.487, height: UIScreen.main.bounds.height * 0.35)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 190, height: 250)
//    }
    
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: InGCdexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
