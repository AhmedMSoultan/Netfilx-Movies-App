//
//  MovieDetailsViewController.swift
//  MoviesApp
//
//  Created by Ahmed Soultan on 02/02/2022.
//

import UIKit
import Cosmos

class MovieDetailsViewController: UIViewController, UITableViewDataSource , UITableViewDelegate{
    
    var detailedMovie = Movie()
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieReleaseYear: UILabel!
    @IBOutlet weak var genreTable: UITableView!
    @IBOutlet weak var movieRating: CosmosView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genreTable.delegate = self
        genreTable.dataSource = self
        
        movieTitle.text! = detailedMovie.title
        movieReleaseYear.text! = String(detailedMovie.releaseYear)
        movieRating.rating = detailedMovie.rating/2
        movieRating.settings.updateOnTouch = false
//        movieImg.image = UIImage(named: detailedMovie.image)
        movieImg.sd_setImage(with: URL(string: detailedMovie.image), placeholderImage: UIImage(named: "moviesImagePlaceHolder"))
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedMovie.genre.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath)
        cell.largeContentTitle = "Genre"
        cell.textLabel?.text = detailedMovie.genre[indexPath.row]
        
        return cell
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
