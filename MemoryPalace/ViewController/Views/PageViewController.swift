//
//  PaginationView.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/21/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import UIKit.UIScrollView;

class PageViewController: UIViewController, UIScrollViewDelegate {
    private var scrollView: UIScrollView!;
    private var pageControl: UIPageControl!;
    public var pages: [UIViewController]! = [];
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        // add the subview 
        scrollView = UIScrollView();
        scrollView.delegate = self;
        scrollView.isPagingEnabled = true;
        view.addSubview(scrollView);
        
        // page control
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
        pageControl.numberOfPages = 2;
        pageControl.addTarget(self, action: #selector(self.pageSelectorAction(_:)), for: .touchUpInside)
        view.addSubview(pageControl);
    }
    
    override func viewDidLayoutSubviews() {
        scrollView!.frame = view.frame;
        
        for (pageIdx, page) in self.pages.enumerated() {
            page.view.frame = CGRect(x: view.frame.width * CGFloat(pageIdx), y:0, width: view.frame.width, height: view.frame.height);
        }
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(self.pages.count), height: view.frame.height);
        
        pageControl.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50);
        pageControl.numberOfPages = self.pages.count;
        
        view.bringSubviewToFront(pageControl);
    }
    
    public func addPage(page: UIViewController) {
        scrollView.addSubview(page.view);
        addChild(page);
        page.didMove(toParent: self);
        self.pages.append(page);
        
        self.viewDidLayoutSubviews();
    }
    
    public func scrollToPage(pageIdx: Int) {
        pageControl.currentPage = pageIdx;
        scrollView.scrollRectToVisible(self.pages[pageIdx].view.frame, animated: true);
    }
    
    @objc func pageSelectorAction(_ sender: UIPageControl) {
        scrollToPage(pageIdx: sender.currentPage);
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.stoppedScrolling()
        }
    }

    func stoppedScrolling() {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width);
    }
}
