//
//  UIButton+Ex.swift
//  mobiita
//
//  Created by 三木俊作 on 2016/12/01.
//  Copyright © 2016年 Shunsaku Miki. All rights reserved.
//

import UIKit

extension UIButton {
    
    private func actionHandler(action: ((UIButton) -> ())? = nil) {
        struct __ {
            static var action: ((UIButton) -> ())?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?(self)
        }
    }
    
    @objc private func triggerActionHandle() {
        self.actionHandler()
    }
    
    func addAction(for control: UIControlEvents = .touchUpInside, action: @escaping ((UIButton) -> ())) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(UIButton.triggerActionHandle), for: control)
    }
}
