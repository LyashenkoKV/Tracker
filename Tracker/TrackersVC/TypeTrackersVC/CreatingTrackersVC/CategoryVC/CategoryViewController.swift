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
    
    private let placeholderText = "Введите название категории"
    
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
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
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
            cell.delegate = self
            cell.getText().text = placeholderText
            placeholder.view.isHidden = true
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell  else { return UITableViewCell() }
            cell.configure(with: categories[indexPath.row])
            configureButtonCell(cell, at: indexPath)
            return cell
        }
    }
    
    private func configureButtonCell(
        _ cell: CategoryCell,
        at indexPath: IndexPath) {
            cell.layer.masksToBounds = true
            cell.backgroundColor = .ypWhiteGray
            cell.selectionStyle = .none
            cell.tintColor = .systemBlue
            cell.accessoryType = .checkmark
            
            let totalRows = categories.count
            
            if totalRows == 1 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner,
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            } else if indexPath.row == 0 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMinYCorner,
                    .layerMaxXMinYCorner
                ]
            } else if indexPath.row == totalRows - 1 {
                cell.layer.cornerRadius = 15
                cell.layer.maskedCorners = [
                    .layerMinXMaxYCorner,
                    .layerMaxXMaxYCorner
                ]
            } else {
                cell.layer.cornerRadius = 0
            }
            
            if indexPath.row < categories.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .lightGray
                separator.translatesAutoresizingMaskIntoConstraints = false
                
                cell.contentView.addSubview(separator)
                
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    separator.widthAnchor.constraint(equalToConstant: cell.frame.width - 40),
                    separator.heightAnchor.constraint(equalToConstant: 1),
                    separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
            }
        }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
}

// MARK: - UITextViewDelegate
extension CategoryViewController: TextViewCellDelegate {
    func textViewCellDidChange(_ cell: TextViewCell) {
        guard let text = cell.getText().text else { return }
        addCategoryButton.isEnabled = !text.isEmpty
        addCategoryButton.backgroundColor = text.isEmpty ? .ypGray : .ypBlack
    }
    func textViewCellDidBeginEditing(_ cell: TextViewCell) {}
    func textViewCellDidEndEditing(_ cell: TextViewCell, text: String?) {}
}

