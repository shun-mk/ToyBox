//
//  UITableView+Ex.swift
//  mobiita
//
//  Created by 三木俊作 on 2016/11/29.
//  Copyright © 2016年 Shunsaku Miki. All rights reserved.
//

import UIKit


/**
 カスタムセルに準拠させるプロトコル
 */
protocol Registrable: class {
    static var reuseIdentifier: String { get }
}

/**
 Registrableプロトコルを拡張しデフォルトでクラス名を返却する処理を追加
 */
extension Registrable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

/**
 クラスからセルを作成する場合はこのプロトコルを準拠させる
 */
protocol ClassRegistrable: Registrable { }

/**
  Nibからセルを作成する場合はこのプロトコルを準拠させる
 */
protocol NibRegistrable: Registrable {
    static var nib: UINib { get }
}

extension NibRegistrable {
    static var nib : UINib {
        let nibName = String(describing: self)
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

extension UITableView {
    
    /// 　TableViewへセルの登録を行う
    ///
    /// - Parameter registrableType: カスタムセルが準拠しているProtocolType
    func register<T: Registrable>(_ registrableType: T.Type) where T: UITableViewCell {
        switch registrableType {
        case let nibRegistrableType as NibRegistrable.Type:
            register(nibRegistrableType.nib, forCellReuseIdentifier: nibRegistrableType.reuseIdentifier)
        case let classRegistrableType as ClassRegistrable.Type:
            register(classRegistrableType, forCellReuseIdentifier: classRegistrableType.reuseIdentifier)
        default:
            assertionFailure("\(registrableType) is unknown type")
        }
    }
    
    
    ///  登録されているセルのインスタンスを取得
    ///
    /// - Parameter indexPath: indexPath
    /// - Returns: Custom Cell Instance
    func dequeueReusableCell<T: Registrable>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with type \(T.self)")
        }
        return cell
    }
}
