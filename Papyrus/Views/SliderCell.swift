//
//  SliderCell.swift
//  Papyrus
//
//  Created by Chris Nevin on 7/07/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit

class SliderCell : UITableViewCell, NibLoadable {
    
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var label: UILabel!
    
    private var values: [String]?
    private var stepValue: Float = 1
    private var index: Int = 0
    private var onChange: ((newIndex: Int) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        slider.value = Float(index)
        changedValue()
    }
    
    func configure(index: Int, values: [String], onChange: (newIndex: Int) -> ()) {
        self.values = values
        self.index = index
        slider.maximumValue = Float(values.count - 1)
        self.onChange = onChange
    }
    
    private func changedValue() {
        onChange?(newIndex: index)
        label.text = values?[index]
    }
    
    @IBAction private func sliderChanged(slider: UISlider) {
        slider.value = round(slider.value / stepValue) * stepValue
        index = Int(slider.value)
        changedValue()
    }
    
}
