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
    
    public func addPage(page: UIViewController) {
        view.addSubview(page.view);
        addChild(page);
        page.didMove(toParent: self);
        self.pages.append(page);
    }
}
