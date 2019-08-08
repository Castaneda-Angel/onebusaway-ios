//
//  TripStopListItem.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 8/5/19.
//

import UIKit
import IGListKit

// MARK: - View Model

class TripStopListItem: NSObject, ListDiffable {

    /// Is this where the vehicle on the trip is currently located?
    let isCurrentVehicleLocation: Bool

    /// Is this the trip stop where the user is intending to go?
    let isUserDestination: Bool

    /// The title of this item. e.g., "15th Ave E & E Galer St"
    let title: String

    /// The `Date` at which the vehicle will arrive/depart this trip stop.
    let date: Date

    /// A formatted representation of `date`
    let formattedDate: String

    /// The route type which will be used to determine the image to display.
    let routeType: RouteType

    /// The `Stop` referred to by this object.
    let stop: Stop

    init(stopTime: TripStopTime, arrivalDeparture: ArrivalDeparture?, formatters: Formatters) {
        stop = stopTime.stop

        if let arrivalDeparture = arrivalDeparture {
            isUserDestination = stopTime.stopID == arrivalDeparture.stopID
        }
        else {
            isUserDestination = false
        }

        if let closestStopID = arrivalDeparture?.tripStatus?.closestStopID {
            isCurrentVehicleLocation = stopTime.stopID == closestStopID
        }
        else {
            isCurrentVehicleLocation = false
        }

        title = stopTime.stop.name

        date = stopTime.arrivalDate
        formattedDate = formatters.timeFormatter.string(from: date)

        routeType = stopTime.stop.prioritizedRouteTypeForDisplay
    }

    // MARK: - ListDiffable

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let rhs = object as? TripStopListItem else {
            return false
        }

        return isCurrentVehicleLocation == rhs.isCurrentVehicleLocation &&
            isUserDestination == rhs.isUserDestination &&
            title == rhs.title &&
            date == rhs.date &&
            formattedDate == rhs.formattedDate &&
            routeType == rhs.routeType &&
            stop == rhs.stop
    }
}

// MARK: - Controller

final class TripStopSectionController: ListSectionController {
    private var object: TripStopListItem?

    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 40)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: TripStopCell.self, for: self, at: index) as? TripStopCell else {
            fatalError()
        }
        cell.tripStopListItem = object
        return cell
    }

    override func didUpdate(to object: Any) {
        self.object = (object as! TripStopListItem) // swiftlint:disable:this force_cast
    }

    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)

        guard
            let tripStopListItem = object,
            let appContext = viewController as? AppContext
        else { return }

        appContext.application.viewRouter.navigateTo(stop: tripStopListItem.stop, from: appContext)
    }
}

// MARK: - Cell

final class TripStopCell: SelfSizingCollectionCell, ListKitCell {

    /*
     [ |                             ]
     [ O  15th & Galer 7:25PM      > ]
     [ |                             ]
     */

    let separator: CALayer = TripStopCell.separatorLayer()

    var tripStopListItem: TripStopListItem? {
        didSet {
            guard let tripStopListItem = tripStopListItem else { return }
            titleLabel.text = tripStopListItem.title

            timeLabel.text = tripStopListItem.formattedDate

            // abxoxo - todo: figure out a way to depict the
            // vehicle and the user on the same segment view.

            if tripStopListItem.isUserDestination {
                segmentView.image = Icons.walkTransport
            }

            if tripStopListItem.isCurrentVehicleLocation {
                segmentView.image = Icons.transportIcon(from: tripStopListItem.routeType)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        segmentView.image = nil
    }

    private let titleLabel: UILabel = {
        let label = UILabel.autolayoutNew()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel.autolayoutNew()
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let segmentView = TripSegmentView.autolayoutNew()

    private let accessoryImageView: UIView = {
        let imageView = UIImageView.autolayoutNew()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.image = Icons.from(accessoryType: .disclosureIndicator)
        let wrapper = imageView.embedInWrapperView(setConstraints: false)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: ThemeMetrics.compactPadding),
            imageView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor)
        ])

        return wrapper
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(separator)
        contentView.backgroundColor = .white

        let stack = UIStackView.horizontalStack(arrangedSubviews: [segmentView, titleLabel, UIView.autolayoutNew(), timeLabel, accessoryImageView])
        stack.spacing = ThemeMetrics.compactPadding
        let stackWrapper = stack.embedInWrapperView(setConstraints: true)
        contentView.addSubview(stackWrapper)

        NSLayoutConstraint.activate([
            stackWrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackWrapper.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackWrapper.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackWrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackWrapper.heightAnchor.constraint(greaterThanOrEqualToConstant: 48.0),
            segmentView.widthAnchor.constraint(equalToConstant: 40.0)
        ])
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private lazy var leftSeparatorInset: CGFloat = segmentView.intrinsicContentSize.width + 10.0

    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = contentView.bounds
        let height: CGFloat = 0.5
        separator.frame = CGRect(x: leftSeparatorInset, y: bounds.height - height, width: bounds.width - leftSeparatorInset, height: height)
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = UIColor(white: isHighlighted ? 0.9 : 1, alpha: 1)
        }
    }
}
