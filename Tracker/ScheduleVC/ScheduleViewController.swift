//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 11.08.2024.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelect(_ days: String)
}

class ScheduleViewController: BaseTrackerViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    
    private var selectedDays: [String] = []
    
    private lazy var addDoneButton = UIButton(
        title: "Готово",
        backgroundColor: .ypBlack,
        titleColor: .ypWhite,
        cornerRadius: 20,
        font: UIFont.systemFont(ofSize: 16),
        target: self,
        action: #selector(addDoneButtonAction)
    )
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            tableView,
            addDoneButton
        ])
        stack.axis = .vertical
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        [stack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
       
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            addDoneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureScheduleCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let oneDay = DayOfTheWeek.allCases[indexPath.row].rawValue
        
        cell.configure(with: DayOfTheWeek.allCases[indexPath.row].rawValue)
        let switchView = cell.toggleSwitch
        
        switchView.isOn = selectedDays.contains(oneDay)
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        configureBaseCell(cell, at: indexPath, totalRows: DayOfTheWeek.allCases.count)
        configureSeparator(cell, isLastRow: indexPath.row == DayOfTheWeek.allCases.count - 1)
        
        return cell
    }
    
    private func selectedDaysString() -> String {
        let daysOrder = [
            "Понедельник", "Вторник", "Среда",
            "Четверг", "Пятница", "Суббота",
            "Воскресенье"
        ]
        
        let fullWeek = Set(daysOrder)
        let selectedSet = Set(selectedDays)

        if selectedSet == fullWeek {
            return "Каждый день"
        }

        let sortedDays = selectedDays.sorted {
            guard let firstIndex = daysOrder.firstIndex(of: $0),
                  let secondIndex = daysOrder.firstIndex(of: $1) else {
                return false
            }
            return firstIndex < secondIndex
        }
        
        let dayShortcuts = sortedDays.compactMap { day in
            switch day {
            case "Понедельник": return "Пн"
            case "Вторник": return "Вт"
            case "Среда": return "Ср"
            case "Четверг": return "Чт"
            case "Пятница": return "Пт"
            case "Суббота": return "Сб"
            case "Воскресенье": return "Вс"
            default: return nil
            }
        }
        
        return dayShortcuts.joined(separator: ", ")
    }

    
    @objc func switchChanged(sender: UISwitch) {
        guard let cell = sender.superview(of: ScheduleCell.self),
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let oneDay = DayOfTheWeek.allCases[indexPath.row].rawValue

        if sender.isOn {
            if !selectedDays.contains(oneDay) {
                selectedDays.append(oneDay)
            }
        } else {
            selectedDays.removeAll { $0 == oneDay }
        }
    }
    
    @objc private func addDoneButtonAction() {
        let selectedDays = selectedDaysString()
        print(selectedDays)
        delegate?.didSelect(selectedDays)
        dismiss(animated: true)
    }
}

// MARK: - cellForRowAt
extension ScheduleViewController {
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            switch viewControllerType {
            case .schedule:
                return configureScheduleCell(at: indexPath)
            default:
                return UITableViewCell()
            }
        }
}
