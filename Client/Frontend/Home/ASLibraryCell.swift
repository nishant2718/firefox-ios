/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SnapKit

class ASLibraryCell: UICollectionViewCell, Themeable {

    // MARK: - Properties
    
    struct LibraryPanel {
        let title: String
        let image: UIImage?
        let color: UIColor
    }
    
    var libraryButtons: [LibraryShortcutView] = []

    let bookmarks = LibraryPanel(title: Strings.AppMenuBookmarksTitleString, image: UIImage.templateImageNamed("menu-Bookmark"), color: UIColor.Photon.Blue40)
    let history = LibraryPanel(title: Strings.AppMenuHistoryTitleString, image: UIImage.templateImageNamed("menu-panel-History"), color: UIColor.Photon.Violet50)
    let readingList = LibraryPanel(title: Strings.AppMenuReadingListTitleString, image: UIImage.templateImageNamed("menu-panel-ReadingList"), color: UIColor.Photon.Pink40)
    let downloads = LibraryPanel(title: Strings.AppMenuDownloadsTitleString, image: UIImage.templateImageNamed("menu-panel-Downloads"), color: UIColor.Photon.Green60)
    
    // UI
    var libraryStackView: UIStackView = .build { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalCentering
    }

    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        configureLibraryPanel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupLayout() {
        addSubview(libraryStackView)
        
        NSLayoutConstraint.activate([
            libraryStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            libraryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            libraryStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 2),
            libraryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureLibraryPanel() {
        [bookmarks, history, downloads, readingList].forEach { item in
            let view = LibraryShortcutView()
            view.button.setImage(item.image, for: .normal)
            view.titleLabel.text = item.title
            let words = view.titleLabel.text?.components(separatedBy: NSCharacterSet.whitespacesAndNewlines).count
            view.titleLabel.numberOfLines = words == 1 ? 1 : 2
            view.button.tintColor = item.color
            view.accessibilityLabel = item.title
            libraryStackView.addArrangedSubview(view)
            libraryButtons.append(view)
        }
    }

    func applyTheme() {
        libraryButtons.forEach { button in
            button.button.backgroundColor = UIColor.theme.homePanel.shortcutBackground
            button.button.layer.shadowColor = UIColor.theme.homePanel.shortcutShadowColor
            button.button.layer.shadowOpacity = UIColor.theme.homePanel.shortcutShadowOpacity
            button.titleLabel.textColor = UIColor.theme.homePanel.activityStreamCellTitle
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        applyTheme()
    }
    
}
