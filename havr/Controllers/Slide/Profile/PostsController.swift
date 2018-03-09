//
//  PostsController.swift
//  havr
//
//  Created by Agon Miftari on 4/23/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit
import UIScrollView_InfiniteScroll
import MBProgressHUD

class PostsController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var profileVC : ProfileController?
    var isFromProfileVC : Bool = false
    var unfilteredPosts: [Post] = []
    var filteredPosts: [Post] = []
    var dataSource: [Post] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    
    var unfilteredPagination = Pagination()
    var filteredPagination = Pagination()
    var user: User!
    var lastSelectedInterest: Int? = nil
    
    let profileWaterfallFlowLayout = CollectionViewWaterfallLayout()
    
    lazy var pullRefresh: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(pullRefreshReload), for: .valueChanged)
        return r
    }()
    lazy var noPostInInterest: EmptyProfileView = {
        let v = EmptyProfileView.createForNoPostsInInterest()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    lazy var privateProfile: EmptyProfileView = {
        let v = EmptyProfileView.createForPrivateProfile()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()
    
    lazy var noInternetConnection: EmptyProfileView = {
        let v = EmptyProfileView.createForNoInternet()
        //v.frame = self.view.frame
        v.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: 195)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionInit()
        setupInitialLayout()
        setupInfiniteScrolling()
        fetchUser()
        getPosts()
        self.noPostInInterest.hide()
        self.privateProfile.hide()
        
        if user.id != AccountManager.currentUser?.id {
            if user.isPublic {
                getPosts()
                self.privateProfile.hide()
            } else {
                self.privateProfile.show(to: self.collectionView)
                self.privateProfile.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                print("Posts private")
                hideHud()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GA.TrackScreen(name: "Posts")
    }
    
    func fetchUser(){
        self.navigationItem.title = "\(user.fullName)' posts"
//        if user.isPublic {
//            getPosts()
//        } else {
//            print("Posts private")
//        }
    }
    
    func pullRefreshReload(sender: UIRefreshControl){
        if let selected = lastSelectedInterest{
            filteredPagination = Pagination()
            getPostsBy(interestId: selected)
        }else{
            unfilteredPagination = Pagination()
            getPosts()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cellSize(post: Post) -> CGSize {
        
        let width = (collectionView.frame.width - 2) / 3
        let postRatio = CGFloat(post.media.height) / CGFloat(post.media.width)
        
        if postRatio <= CGFloat(1) {
            return CGSize(width: width, height: width)
        }else {
            return CGSize(width: width, height: width * 1.286)
        }
    }
    
    func collectionInit() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerFocusImageCollectionCell()
        collectionView.register(UINib.init(nibName: "PostsHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionHeader, withReuseIdentifier: "PostsHeaderCollectionReusableView")
        self.collectionView.addSubview(pullRefresh)

    }
    func setupInitialLayout() {
        profileWaterfallFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        profileWaterfallFlowLayout.minimumColumnSpacing = 1
        profileWaterfallFlowLayout.minimumInteritemSpacing = 1
        
        collectionView.collectionViewLayout = profileWaterfallFlowLayout
    }
    func setupInfiniteScrolling() {
        self.collectionView.addInfiniteScroll {[unowned self] (collection) in
            if let selected = self.lastSelectedInterest{
                self.getPostsBy(interestId: selected)
            }else{
                self.getPosts()
            }
        }
        self.collectionView.infiniteScrollTriggerOffset = 120
        
        self.collectionView.setShouldShowInfiniteScrollHandler {[unowned self] _ in
            if self.lastSelectedInterest != nil{
                return self.filteredPagination.hasNext
            }else{
                return self.unfilteredPagination.hasNext
            }
        }
    }
    
    func getPosts() {
        if self.unfilteredPosts.count == 0{
//            showHud()
        }
        PostsAPI.get(page: unfilteredPagination.nextPage, for: user.id, in: nil) { (posts, pagination, error) in
            
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
//            self.hideHud()
            
            if let posts = posts, let pagination = pagination {
                if self.unfilteredPagination.currentPage == 0{
                    self.unfilteredPosts = []
                }
                self.unfilteredPagination = pagination

                self.unfilteredPosts += posts
                self.dataSource = self.unfilteredPosts
                //someone handle if user has no posts
                //show no posts view
            }
            if let error = error {
                print(error.message)
            }
        }
    }
    
    func getPostsBy(interestId: Int){
        if self.filteredPosts.count == 0{
            showHud()
        }
        PostsAPI.getPostsBy(interest: interestId, page: filteredPagination.nextPage, for: user.id) { (posts, pagination, error) in
            
            self.pullRefresh.endRefreshing()
            self.collectionView.finishInfiniteScroll()
            self.hideHud()
            
            if let posts = posts, let pagination = pagination {
                if self.filteredPagination.currentPage == 0{
                    self.filteredPosts = []
                }
                self.filteredPagination = pagination

                self.filteredPosts += posts
                self.dataSource = self.filteredPosts
                
                
                if self.dataSource.count < 1 {
                    self.noPostInInterest.show(to: self.collectionView)
                    self.noPostInInterest.frame = CGRect(x: 0, y: 340, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 404)
                }else {
                    self.noPostInInterest.hide()
                }
                
                //someone handle if user has no posts
                //show no posts view
            }
            if let error = error {
                print(error.message)
            }
        }

    }
}

extension PostsController {
    static func create() ->PostsController {
        return UIStoryboard.profile.instantiateViewController(withIdentifier: "PostsController") as! PostsController
    }
}


extension PostsController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueFocusImageCollectionCell(indexpath: indexPath)
        let post = dataSource[indexPath.item]
//        cell.productHomeImageView.kf.setImage(with: post.getImageUrl(), options: [.onlyLoadFirstFrame])
        cell.productHomeImageView.kf.setImage(with: post.getImageUrl())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let post = dataSource[indexPath.item]
        return cellSize(post: post)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsVC = PostDetailController.create()
        detailsVC.post = dataSource[indexPath.item]
        self.push(detailsVC)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PostsHeaderCollectionReusableView", for: indexPath) as! PostsHeaderCollectionReusableView
        headerView.user = user
        headerView.isFromProfileVC = isFromProfileVC
        headerView.fetchProfile()
        headerView.interestView.delegate = self
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSize(width: width, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, heightForHeaderInSection section: Int) -> Float {
        return 110
    }
}
extension PostsController: InterestViewDelegate{
    func didSelect(contentType: InterestContent, interest: UserInterest?, in collectionCiew: UICollectionView, at indexPath: IndexPath) {
        collectionView.isUserInteractionEnabled = true
    }
    
    func didSave(sender: InterestView) {
        //
    }

    
    func didSelect(interest: UserInterest, at index: IndexPath) {
        if interest.isSelected {
            lastSelectedInterest = interest.item!.id
            filteredPagination = Pagination()
            getPostsBy(interestId: lastSelectedInterest!)
        }else{
            lastSelectedInterest = nil
            dataSource = unfilteredPosts
        }
    }

    
    func didUpload(media: Media?, error: ErrorMessage?, at index: Int) {
        
    }
}
