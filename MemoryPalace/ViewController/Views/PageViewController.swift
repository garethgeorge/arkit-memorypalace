//
//  PaginationView.swift
//  MemoryPalace
//
//  Created by Gareth George on 5/21/20.
//  Copyright © 2020 Gareth George. All rights reserved.
//

import Foundation
import UIKit.UIScrollView;

class PageViewController: UIViewController {
    private var scrollView: UIScrollView!;
    private var pageControl: UIPageControl!;
    public var pages: [UIViewController]! = [];
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override func viewDidLoad() {
        // add the subview 
        scrollView = UIScrollView();
        scrollView.isScrollEnabled = false;
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
    
    @objc func pageSelectorAction(_ sender: UIPageControl) {
        scrollView.scrollRectToVisible(self.pages[sender.currentPage].view.frame, animated: true);
    }
}
