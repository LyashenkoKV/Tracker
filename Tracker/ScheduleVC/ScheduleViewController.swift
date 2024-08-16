//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Konstantin Lyashenko on 11.08.2024.
//

import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelect(_ days: [DayOfTheWeek])
}

class ScheduleViewController: BaseTrackerViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    
    var selectDays: [DayOfTheWeek] = []
    
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
        loadSelectedDays()
        selectDays = selectedDays?.days ?? []
        tableView.reloadData()
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
        
        let day = DayOfTheWeek.allCases[indexPath.row]
        
        cell.configure(with: day.rawValue)
        
        let switchView = cell.toggleSwitch
        switchView.isOn = selectDays.contains(day)
        
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        configureBaseCell(cell, at: indexPath, totalRows: DayOfTheWeek.allCases.count)
        configureSeparator(cell, isLastRow: indexPath.row == DayOfTheWeek.allCases.count - 1)
        
        return cell
    }
    
    @objc func switchChanged(sender: UISwitch) {
        guard let cell = sender.superview(of: ScheduleCell.self),
              let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let selectedDay = DayOfTheWeek.allCases[indexPath.row]

        if sender.isOn {
            if !selectDays.contains(selectedDay) {
                selectDays.append(selectedDay)
            }
        } else {
            selectDays.removeAll { $0 == selectedDay }
        }
        selectedDays = Schedule(days: selectDays)
    }
    
    @objc private func addDoneButtonAction() {
        selectedDays = Schedule(days: selectDays)
        delegate?.didSelect(selectDays)
        saveSelectedDays()
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
