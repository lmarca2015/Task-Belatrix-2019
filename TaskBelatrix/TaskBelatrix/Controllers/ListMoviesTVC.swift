//
//  ListMoviesTVC.swift
//  TaskBelatrix
//
//  Created by APPLE on 5/03/19.
//  Copyright © 2019 Oxicode. All rights reserved.
//

import UIKit
import Kingfisher
import SafariServices

class ListMoviesTVC: UITableViewController {
    
    var arrayMovies, arraySearchMovies : NSMutableArray?
    var currentPageNumber, searchPageNumber : Int!
    var searchTerm : String?
    var searchController : UISearchController!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        initVariables()
        setupView()
        
    }
    
    func initVariables()
    {
        
        currentPageNumber = 0
        arrayMovies = NSMutableArray()
        
        let pref = UserDefaults.standard
        pref.set(false, forKey: "isInSearchPhase")
        pref.set(true, forKey: "isPageRefreshing")
        pref.synchronize()
        
    }
    
    func setupView()
    {
        
        title = "TaskBelatrix"
        
        setupSearchBar()
        
        // hide searchbar at start
        tableView.setContentOffset(CGPoint(x:0, y:self.searchController.searchBar.frame.size.height), animated: false)
        
        // Automatic Row Heigth
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300;
        
        
        //SwiftSpinner.show("Loading movies please wait...")
        
        
        registerObserver()
        loadMovies()
        
        
    }
    
    func registerObserver()
    {
        // Define identifier
        let notificationName = Notification.Name("needUpdateTable")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(ListMoviesTVC.updateRecords), name: notificationName, object: nil)
    }
    
    public func scrollToTop()
    {
        
        let indexPath = IndexPath(row: 0, section: 0) as IndexPath
        tableView.scrollToRow(at: indexPath , at: .top, animated: false)
        
    }
    
    func loadMovies()
    {
        
        currentPageNumber = currentPageNumber + 1
        APITrakt().downloadMovies(pageNumber: currentPageNumber, arrayResults: arrayMovies!)
        
    }
    
    func loadMoviesWithString(_ searchTerm : String)
    {
        
        searchPageNumber = searchPageNumber + 1
        APITrakt().searchMovies(pageNumber: searchPageNumber, arrayResults: arraySearchMovies!, searchTerms: searchTerm)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if UserDefaults.standard.bool(forKey: "isInSearchPhase"){
            if let arraySearchMovies = arraySearchMovies{
                return arraySearchMovies.count
            }
        }else{
            if let arrayMovies = arrayMovies{
                return arrayMovies.count
            }
        }
        
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        var arrayMoviesToShow = NSMutableArray()
        
        // Select array to load
        if UserDefaults.standard.bool(forKey: "isInSearchPhase"){
            arrayMoviesToShow = arraySearchMovies!
        }else{
            arrayMoviesToShow = arrayMovies!
        }
        
        let movie = arrayMoviesToShow.object(at: indexPath.row) as! Movie
        
        // Configure the cell...
        if let year = movie.year{
            (cell.contentView.viewWithTag(10) as! UILabel).text = String(year)
        }
        
        if let title = movie.title{
            (cell.contentView.viewWithTag(11) as! UILabel).text = title
        }
        
        if let overview = movie.overview{
            (cell.contentView.viewWithTag(12) as! UILabel).text = overview
        }
        
        if let imgURL = movie.imageURL{
            let img_poster = (cell.contentView.viewWithTag(13) as! UIImageView)
            img_poster.kf.setImage(with: URL(string:imgURL))
            CustomImage().setClippingImageView(imgView: img_poster)
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var arrayMoviesToShow = NSMutableArray()
        
        // Select array to load
        if UserDefaults.standard.bool(forKey: "isInSearchPhase"){
            arrayMoviesToShow = arraySearchMovies!
        }else{
            arrayMoviesToShow = arrayMovies!
        }
        
        let movie = arrayMoviesToShow.object(at: indexPath.row) as! Movie
        
        showTrailerForMovie(movie)
    }
    
    func showTrailerForMovie(_ movie: Movie)
    {
        
        let alert = UIAlertController(title: "Desea ver el trailer de la película \(movie.title!)", message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "SI", style: .default, handler: { action in
            self.openSFSafari(movie.trailer!)
        })
        alert.addAction(cancel)
        
        let ok = UIAlertAction(title: "NO", style: .default, handler: { action in
            
        })
        alert.addAction(ok)
        
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
    }
    
    
    /* Hide keyboard when user scroll interface */
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        
        searchController.searchBar.resignFirstResponder()
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        // Reload at half of content for get improve preformance, if user reaches the end of the list also reloading
        if(self.tableView.contentOffset.y >= ((self.tableView.contentSize.height/2) - self.tableView.bounds.size.height))
        {
            loadNextPage()
        }
        else if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
        {
            loadNextPage()
        }
        
    }
    
    func loadNextPage()
    {
        
        if !UserDefaults.standard.bool(forKey: "isPageRefreshing"){
            let pref = UserDefaults.standard
            pref.set(true, forKey: "isPageRefreshing")
            pref.synchronize()
            
            
            if UserDefaults.standard.bool(forKey: "isInSearchPhase"){
                if let searchTerm = searchTerm{
                    loadMoviesWithString(searchTerm)
                }
            }
            else{
                loadMovies()
            }
        }
    }
    
    
    
    // MARK: - Butons actions functionality
    /* Called when UIBarButton Search is pressed */
    @IBAction func pushedSearchButton(_ sender: UIBarButtonItem)
    {
        
        searchController.searchBar.becomeFirstResponder()
        scrollToTop()
        
    }
    
    /* Called when Cancel button on search is pressed */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        
        let pref = UserDefaults.standard
        pref.set(false, forKey: "isInSearchPhase")
        pref.synchronize()
        
        tableView.reloadData()
        scrollToTop()
        
    }
    
    
    /* Called by NetworkLayer when need update interface*/
    @objc func updateRecords()
    {
        
        // update some UI
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            //SwiftSpinner.hide()
            
        }
        
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
}



extension  ListMoviesTVC: UISearchDisplayDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    public func setupSearchBar()
    {
        
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = true
        
    }
    
    /* Called when searchTextfield is changed */
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(request), object: nil)
        
        searchTerm = searchText
        
        scrollToTop()
        
        perform(#selector(request), with: nil, afterDelay: 0.8)
        
    }
    
    // MARK: - Search logic
    @objc func request()
    {
        
        searchPageNumber = 0;
        
        let pref = UserDefaults.standard
        pref.set(true, forKey: "isInSearchPhase")
        pref.synchronize()
        
        arraySearchMovies = NSMutableArray()
        if let searchTerm = searchTerm { loadMoviesWithString(searchTerm) }
        
    }
}


extension ListMoviesTVC {
    
    func openSFSafari(_ scheme: String) {
        if let url = URL(string: scheme) {
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
}
