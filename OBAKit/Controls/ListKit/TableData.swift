//
//  TableData.swift
//  OBANext
//
//  Created by Aaron Brethorst on 1/15/19.
//  Copyright © 2019 OneBusAway. All rights reserved.
//

import Foundation
import IGListKit

// MARK: - TableRowData

/// Models a single table row
public class TableRowData: ListViewModel {

    let title: String?
    let attributedTitle: NSAttributedString?

    let subtitle: String?
    let accessoryType: UITableViewCell.AccessoryType
    let style: UITableViewCell.CellStyle

    public var image: UIImage?
    public var imageSize: CGFloat?

    // MARK: - Initialization

    /// Default Initializer. Lets you set everything.
    ///
    /// - Parameters:
    ///   - title: The title of the row. Optional.
    ///   - attributedTitle: The attributed title of the row. Optional.
    ///   - subtitle: The subtitle of the row. Optional.
    ///   - style: The style (appearance/layout) of the row.
    ///   - accessoryType: The accessory type on the right side, if any.
    ///   - tapped: Tap event handler.
    public init(title: String?, attributedTitle: NSAttributedString?, subtitle: String?, style: UITableViewCell.CellStyle, accessoryType: UITableViewCell.AccessoryType, tapped: ListRowActionHandler?) {
        self.title = title
        self.attributedTitle = attributedTitle
        self.subtitle = subtitle
        self.style = style
        self.accessoryType = accessoryType

        super.init(tapped: tapped)
    }

    /// Create a default-style row with an attributed string title.
    ///
    /// - Parameters:
    ///   - attributedTitle: The attributed string title.
    ///   - accessoryType: The accessory type on the right side, if any.
    ///   - tapped: Tap event handler.
    convenience init(attributedTitle: NSAttributedString, accessoryType: UITableViewCell.AccessoryType, tapped: ListRowActionHandler?) {
        self.init(title: nil, attributedTitle: attributedTitle, subtitle: nil, style: .default, accessoryType: accessoryType, tapped: tapped)
    }

    /// Create a default-style row with an accessory.
    ///
    /// - Parameters:
    ///   - title: The title for the row.
    ///   - accessoryType: The accessory type of the row.
    ///   - tapped: Tap event handler
    convenience init(title: String, accessoryType: UITableViewCell.AccessoryType, tapped: ListRowActionHandler?) {
        self.init(title: title, attributedTitle: nil, subtitle: nil, style: .default, accessoryType: accessoryType, tapped: tapped)
    }

    /// Create a subtitle-style row with an accessory.
    ///
    /// - Parameters:
    ///   - title: The title for the row.
    ///   - subtitle: The subtitle for the row.
    ///   - accessoryType: The accessory type.
    ///   - tapped: Tap event handler.
    convenience init(title: String, subtitle: String, accessoryType: UITableViewCell.AccessoryType, tapped: ListRowActionHandler?) {
        self.init(title: title, attributedTitle: nil, subtitle: subtitle, style: .subtitle, accessoryType: accessoryType, tapped: tapped)
    }

    /// Create a value-style row with an accessory.
    ///
    /// - Parameters:
    ///   - title: The title for the row.
    ///   - values: The value for the row.
    ///   - accessoryType: The accessory type.
    ///   - tapped: Tap event handler.
    convenience init(title: String, value: String?, accessoryType: UITableViewCell.AccessoryType, tapped: ListRowActionHandler?) {
        self.init(title: title, attributedTitle: nil, subtitle: value, style: .value1, accessoryType: accessoryType, tapped: tapped)
    }

    // MARK: - Object Methods

    override public var debugDescription: String {
        let desc = super.debugDescription
        let props: [String: Any] = ["title": title as Any, "subtitle": subtitle as Any, "style": style, "accessoryType": accessoryType]
        return "\(desc) \(props)"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TableRowData else { return false }

        return
            title == rhs.title &&
            attributedTitle == rhs.attributedTitle &&
            subtitle == rhs.subtitle &&
            accessoryType == rhs.accessoryType &&
            style == rhs.style &&
            image == rhs.image
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(attributedTitle)
        hasher.combine(subtitle)
        hasher.combine(accessoryType)
        hasher.combine(style)
        hasher.combine(image)
        return hasher.finalize()
    }
}

// MARK: - TableSectionData

/// Models a section in a table. Contains many `TableRowData` objects.
public class TableSectionData: NSObject, ListDiffable {
    let rows: [TableRowData]

    public func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let rhs = object as? TableSectionData else {
            return false
        }

        return rows == rhs.rows
    }

    /// Creates a `TableSectionData`
    /// - Parameter rows: The table rows
    public init(rows: [TableRowData]) {
        self.rows = rows
        super.init()
    }
}
