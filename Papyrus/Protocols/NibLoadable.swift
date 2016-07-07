//
//  NibLoadable.swift
//  Papyrus
//
//  Created by Chris Nevin on 7/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var nibName: String { get }
    static func nib(in bundle: Bundle) -> UINib
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(self).components(separatedBy: ".").last!
    }
    
    static func nib(in bundle: Bundle = .main()) -> UINib {
        return UINib(nibName: nibName, bundle: bundle)
    }
}

extension UITableView {
    func register<T: NibLoadable>(loadable: T.Type, in bundle: Bundle = .main()) {
        self.register(loadable.nib(in: bundle), forCellReuseIdentifier: loadable.nibName)
    }
    
    func cell<T: NibLoadable where T: UITableViewCell>(at indexPath: IndexPath) -> T? {
        return self.cellForRow(at: indexPath) as? T
    }
    
    func dequeueCell<T: NibLoadable where T: UITableViewCell>(at indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.nibName, for: indexPath) as! T
    }
}
