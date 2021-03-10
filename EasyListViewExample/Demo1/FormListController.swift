//
//  FormListController.swift
//  EasyListViewExample
//
//  Created by carefree on 2020/8/17.
//  Copyright © 2020 carefree. All rights reserved.
//

import UIKit

class FormListController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        
        return scrollView
    }()
    
    var nameTextField: UITextField!
    var birthdayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        view.subviews(scrollView)
        view.layout(
            0,
            |scrollView|,
            0
        )
        
        let addSeparator: () -> Void = {
            let view = UIView()
            view.backgroundColor = #colorLiteral(red: 0.8979505897, green: 0.8981012702, blue: 0.8979307413, alpha: 1)
            view.height(0.5)
            
            self.scrollView.easy.append(view)
        }
        
        scrollView.easy.append({
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 14)
            label.textColor = .lightGray
            label.text = "Section Title"
            return label
        }(), with: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
        
        let nameCell: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "Name"
            cell.showIndicator = false
            
            let textField = UITextField()
            textField.textAlignment = .right
            textField.placeholder = "type your name"
            self.nameTextField = textField
            
            cell.subviews(textField)
            cell.height(48)
            cell.layout(
                0,
                textField-16-|,
                0
            )
            textField.Leading == cell.textLabel.Trailing + 10
            
            return cell
        }()
        scrollView.easy.append(nameCell, spacing: 10)
        
        addSeparator()
        
        let emailCell: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "Email"
            cell.showIndicator = false
            
            let textField = UITextField()
            textField.textAlignment = .right
            textField.placeholder = "email@domain.com"
            
            cell.subviews(textField)
            cell.height(48)
            cell.layout(
                0,
                textField-16-|,
                0
            )
            textField.Leading == cell.textLabel.Trailing + 10
            
            return cell
        }()
        scrollView.easy.append(emailCell)
        
        addSeparator()
        
        let birthdayCell: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "Birthday"
            cell.onTap = {[unowned self] in
                self.tapBirthdayCell()
            }
            
            let label = UILabel()
            label.textAlignment = .right
            label.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            label.text = formatter.string(from: Date())
            self.birthdayLabel = label
            
            cell.subviews(label)
            cell.height(48)
            cell.layout(
                label.centerVertically()-30-|
            )
            label.Leading == cell.textLabel.Trailing + 10
            
            return cell
        }()
        scrollView.easy.append(birthdayCell, for: "birthday", spacing: 0)
        
        addSeparator()
        
        let switchCell: UIView = {
            let cell = EasyListCell()
            cell.textLabel.text = "Other"
            cell.showIndicator = false
            
            let swt = UISwitch()
            
            cell.subviews(swt)
            cell.height(48)
            cell.layout(
                swt.centerVertically()-16-|
            )
            
            return cell
        }()
        scrollView.easy.append(switchCell)
        
        scrollView.easy.append({
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 16)
            label.textColor = .lightGray
            label.text = "1.AAA\n2.BBB\n3.CCC"
            return label
        }(), with: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
        
        let inputView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            
            let label = UILabel()
            label.font = .systemFont(ofSize: 12)
            label.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            label.text = "Description"
            
            let textView = UITextView()
            textView.layer.cornerRadius = 6
            textView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            textView.layer.borderWidth = 1 / UIScreen.main.scale
            
            view.subviews(label, textView)
            view.height(150)
            view.layout(
                15,
                |-16-label,
                10,
                |-15-textView-15-|,
                10
            )
            
            return view
        }()
        scrollView.easy.append(inputView, spacing: 10)
        
        let button = UIButton(type: .custom)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.height(45)
        button.addTarget(self, action: #selector(tapDone), for: .touchUpInside)
        scrollView.easy.append(button, with: UIEdgeInsets(top: 40, left: 16, bottom: 20, right: 16))
    }
    
    deinit {
        print("deinit")
    }
    
    func tapBirthdayCell() {
        if let _ = scrollView.easy.getElement(identifier: "birthdaySelector") as? UIDatePicker {
            scrollView.easy.delete("birthdaySelector")
            birthdayLabel.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
            return
        }
        
        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        if let text = birthdayLabel.text, !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            picker.date = formatter.date(from: text) ?? Date()
        }
        birthdayLabel.textColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        
        scrollView.easy.insert(picker, after: "birthday", with: .zero, for: "birthdaySelector", completion: nil)
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        birthdayLabel.text = formatter.string(from: sender.date)
    }
    
    @objc func tapDone() {
        view.endEditing(true)
        let alert = UIAlertController(title: "Hello!\(nameTextField.text ?? "")", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension FormListController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
