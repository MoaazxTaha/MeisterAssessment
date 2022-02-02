//
//  ViewController.swift
//  MeisterTaskAssessment
//
//  Created by Moaaz Ahmed Fawzy Taha on 01/02/2022.
//

import UIKit

class TaskListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var taskList: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bufferingView: UIView!
    
    private let viewModel = TaskListViewModel()
    private var result:Result?
    private var timer = Timer()
    
    fileprivate var listIsEmpty:Bool {
        return viewModel.filteredTasks.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindReachability()
        searchBar.delegate = self
        setupTableView()
        loadTasks(with: .All)
    }

    
    deinit {
        unbindReachability()
    }
    
    private func loadTasks(with filterValue:FilterationParameter) {
        showBuffering()
        viewModel.fetchTasks(filterValue: filterValue) {[weak self] in
            DispatchQueue.main.async {[weak self] in
                self?.hideBuffering()
                self?.taskList.reloadData()
            }
        }
    }

    private func setupTableView() {
        taskList.register(UINib(nibName: String(describing: TaskCell.self) , bundle: nil), forCellReuseIdentifier:TaskCell.cellIdentfier)
        taskList.register(UINib(nibName: String(describing: EmptySearchBarCell.self) , bundle: nil), forCellReuseIdentifier:EmptySearchBarCell.cellIdentfier)
        taskList.dataSource = self
        taskList.delegate = self
        taskList.tableHeaderView?.frame.size.height = 80
        taskList.backgroundColor = .clear
        taskList.separatorStyle = .none
        
        //RefreshControl setup
        taskList.refreshControl = UIRefreshControl()
        taskList.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
    }
    
}

//MARK: - Actions

extension TaskListViewController {
    //SegmentControl Action
    @IBAction func segmentChanged(_ sender: Any) {
        if let segmentControl = sender as? UISegmentedControl {
            loadTasks(with: FilterationParameter(rawValue: segmentControl.selectedSegmentIndex) ?? .All)
        }
    }
    
    // refreshControl Action
    @objc func refresh(_ sender: AnyObject) {
        performSearch()
        taskList.refreshControl?.endRefreshing()
    }
    
    // ActivityIndicator utils
    func showBuffering(){
        self.activityIndicator.startAnimating()
        self.bufferingView.isHidden = false
    }
    
    func hideBuffering(){
        activityIndicator.stopAnimating()
        bufferingView.isHidden = true
    }
}

//MARK: - TableView Delegate & Data source

// TableView Datasource
extension TaskListViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !listIsEmpty else {return 1}
        
        return (viewModel.filteredTasks.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !listIsEmpty else {
            let cell = taskList.dequeueReusableCell(withIdentifier: EmptySearchBarCell.cellIdentfier, for: indexPath) as! EmptySearchBarCell
            return cell
        }
        
        let cell = taskList.dequeueReusableCell(withIdentifier: TaskCell.cellIdentfier, for: indexPath) as! TaskCell
        cell.configureCell(with: viewModel.filteredTasks[indexPath.row])
        return cell
    }
    
}

// TableView Delegate
extension TaskListViewController:UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !listIsEmpty else {return}
        dismissKeyboard()
        showAlert(title: viewModel.filteredTasks[indexPath.row].projectName ?? "" , message: viewModel.filteredTasks[indexPath.row].name ?? "")
        taskList.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - searchbar Delegate
extension TaskListViewController:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
    }
        
    @objc func performSearch() {
        showBuffering()
        if let serachingTerm = searchBar.searchTextField.text {
            viewModel.searchingTerm = serachingTerm
            taskList.reloadData()
        }
        hideBuffering()
    }
}
