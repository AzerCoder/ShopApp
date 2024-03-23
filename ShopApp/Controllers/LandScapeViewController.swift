//
//  LandScapeViewController.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 22/03/24.
//

import UIKit

class LandScapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    var searchResults = [SearchResult]()
    private var firstTime = true
    private var downloads = [URLSessionDownloadTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        initView()
    }
    
    func initView(){
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        pageControll.removeConstraints(pageControll.constraints)
        pageControll.translatesAutoresizingMaskIntoConstraints = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "appbackground")!)
        pageControll.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeFrams = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrams
        pageControll.frame = CGRect(x: safeFrams.origin.x, y: safeFrams.size.height - pageControll.frame.size.height, width: safeFrams.size.width, height:pageControll.frame.size.height)
        
        if firstTime{
            firstTime = false
            tileButtons()
        }
        
        func tileButtons(){
            let itemWidth: CGFloat = 94
            let itemHeight: CGFloat = 88
            
            var columsPerPage = 0
            var rowsPerPage = 0
            
            var marginX: CGFloat = 0
            var marginY: CGFloat = 0
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            columsPerPage = Int(viewWidth / itemWidth)
            rowsPerPage = Int(viewHeight / itemHeight)
            
            marginX = (viewWidth - (CGFloat(columsPerPage)*itemWidth)) * 0.5
            marginY = (viewHeight - (CGFloat(rowsPerPage)*itemHeight)) * 0.5
            
            //Button size
            
            let buttonWidth: CGFloat = 82
            let buttonHeight: CGFloat = 82
            let paddingHor = (itemWidth - buttonWidth)/2
            let paddingVer = (itemHeight - buttonHeight)/2
            
            //Add Button
            
            var row = 0
            var column = 0
            var x = marginX

            
            for (index,result) in searchResults.enumerated(){
                let button = UIButton(type: .custom)
                button.setBackgroundImage(UIImage(named: "square"), for: .normal)
                downloadImage(for: result, andPlaceOn: button)
                button.frame = CGRect(x: x + paddingHor, y: marginY + CGFloat(row) * itemHeight + paddingVer, width: buttonWidth, height: buttonHeight)
                scrollView.addSubview(button)
                row += 1
                
                if row == rowsPerPage{
                    row = 0
                    x += itemWidth
                    column += 1
                    
                    if column == columsPerPage{
                        column = 0
                        x += marginX * 2
                    }
                }
            }
            
            // Set scrollView content size
            
            let buttonPerPage = columsPerPage * rowsPerPage
            let numPages = 1 + (searchResults.count - 1) / buttonPerPage
            scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: scrollView.bounds.size.height)
            pageControll.numberOfPages = numPages
            pageControll.numberOfPages = 0
        }
        
       
    }
    
    private func downloadImage(for result:SearchResult, andPlaceOn button : UIButton){
        guard let urlString = result.imageSmall, let url = URL(string: urlString) else {
                return
            }

            let task = URLSession.shared.downloadTask(with: url) { location, _, error in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }

                guard let location = location, let data = try? Data(contentsOf: location), let image = UIImage(data: data) else {
                    print("Error converting data to image")
                    return
                }

                DispatchQueue.main.async {
                    button.setImage(image, for: .normal)
                }
            }

            task.resume()
            downloads.append(task)
    }
    
    @IBAction func pageChange(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }
    }
    
    deinit{
        downloads.forEach{ task in
            task.cancel()
        }
    }

}

extension LandScapeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width/2)/width)
        pageControll.currentPage = page
    }
}
