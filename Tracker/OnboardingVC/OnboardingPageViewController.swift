//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 04.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    private var pages = [OnboardingHelper]()
    
    private lazy var onboardingViewControllers: [OnboardingViewController] = {
        var vc = [OnboardingViewController]()
        pages.forEach { vc.append(OnboardingViewController(with: $0)) }
        return vc
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addVC()
        setupPageControl()

        dataSource = self
        
        onboardingViewControllers = pages.map { OnboardingViewController(with: $0) }
        
        if let firstVC = onboardingViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func addVC() {
        let firstPage = OnboardingHelper(
            greeting: "Отслеживайте только\n то, что хотите",
            image: UIImage(named: "1") ?? UIImage()
        )
        let secondPage = OnboardingHelper(
            greeting: "Даже если это\n не литры воды и йога",
            image: UIImage(named: "2") ?? UIImage()
        )
        pages = [firstPage, secondPage]
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let index = onboardingViewControllers.firstIndex(of: onboardingVC), 
                index > 0 else {
            return nil
        }
        return onboardingViewControllers[index - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingViewController,
              let index = onboardingViewControllers.firstIndex(of: onboardingVC), 
                index < onboardingViewControllers.count - 1 else {
            return nil
        }
        return onboardingViewControllers[index + 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentVC = viewControllers?.first,
           let index = onboardingViewControllers.firstIndex(of: currentVC as! OnboardingViewController) {
            pageControl.currentPage = index
        }
    }
}
