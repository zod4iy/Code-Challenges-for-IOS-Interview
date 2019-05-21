//
//  NoteCell.swift
//  NotesForEvo
//
//  Created by Alexandr Kurylenko on 5/17/19.
//  Copyright © 2019 Alexandr Kurylenko. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupView()
    }
    
    private func setupView() {
        noteLabel.text = nil
        dateLabel.text = nil
        timeLabel.text = nil
    }
    
    func config(with model: NoteModel) {
        noteLabel.text = model.textFormated
        dateLabel.text = model.dateFormated
        timeLabel.text = model.timeFormated
    }
}
