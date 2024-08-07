//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 07.08.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let buttonTitle = "Добавить категорию"
    
    private var categories: [String] = []
    private var isAddingCategory = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private lazy var addCategoryButton = UIButton(
        title: buttonTitle,
        backgroundColor: .ypBlack,
        titleColor: .ypWhite,
        cornerRadius: 20,
        font: UIFont.systemFont(ofSize: 16),
        target: self,
        action: #selector(addCategoryButtonAction)
    )
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            tableView,
            addCategoryButton
        ])
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var placeholder: Placeholder = {
        let placeholder = Placeholder(image: UIImage(named: "Error"), text: "Что будем отслеживать?")
        return placeholder
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        self.title = "Категория"
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        [tableView, addCategoryButton, placeholder.view].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            placeholder.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateUI() {
        placeholder.view.isHidden = !categories.isEmpty
        addCategoryButton.isEnabled = !isAddingCategory
        addCategoryButton.backgroundColor = isAddingCategory ? .ypGray : .ypBlack
        addCategoryButton.setTitle(isAddingCategory ? "Готово" : buttonTitle, for: .normal)
        tableView.reloadData()
    }
    
    @objc private func addCategoryButtonAction() {
        if isAddingCategory {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextViewCell,
               let categoryText = cell.getText().text, !categoryText.isEmpty {
                categories.append(categoryText)
            }
            isAddingCategory.toggle()
        } else {
            isAddingCategory.toggle()
        }
        updateUI()
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return isAddingCategory ? 1 : categories.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if isAddingCategory {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as? TextViewCell else { return UITableViewCell() }
            //cell.getText().delegate = self
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell  else { return UITableViewCell() }
            cell.configure(with: categories[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
}

// MARK: - UITextViewDelegate
extension CategoryViewController: TextViewCellDelegate {
    func textViewCellDidBeginEditing(_ cell: TextViewCell) {
        
    }
    
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addCategoryButton.isEnabled = !textView.text.isEmpty
        addCategoryButton.backgroundColor = textView.text.isEmpty ? .ypGray : .ypBlack
    }
}

