//
//  Parser.swift
//  Natalie
//
//  Created by Marcin Krzyzanowski on 07/08/16.
//  Copyright © 2016 Marcin Krzyzanowski. All rights reserved.
//

import Foundation


struct Parser {

    struct Header: CustomStringConvertible {
        var description: String {
            var output = String()
            output += "//\n"
            output += "// Autogenerated by Natalie - Storyboard Generator\n"
            output += "// by Marcin Krzyzanowski http://krzyzanowskim.com\n"
            output += "//\n"
            return output
        }
    }

    let storyboards: [StoryboardFile]
    let header = Header()

    init(storyboards: [StoryboardFile]) {
        self.storyboards = storyboards
    }

    func process(os: OS) -> String {
        var output = String()

        output += header.description
        output += "import \(os.framework)\n"
        for module in storyboards.lazy.flatMap({ $0.storyboard.customModules }) {
            output += "import \(module)\n"
        }
        output += "\n"
        output += "//MARK: - Storyboards\n"

        output += "\n"
        output += "extension \(os.storyboardType) {\n"
        for (signatureType, returnType) in os.storyboardInstantiationInfo {
            output += "    func instantiateViewController<T: \(returnType)>(ofType type: T.Type) -> T? where T: IdentifiableProtocol {\n"
            output += "        let instance = type.init()\n"
            output += "        if let identifier = instance.storyboardIdentifier {\n"
            output += "            return self.instantiate\(signatureType)(withIdentifier: identifier) as? T\n"
            output += "        }\n"
            output += "        return nil\n"
            output += "    }\n"
            output += "\n"
        }
        output += "}\n"

        output += "\n"
        output += "protocol Storyboard {\n"
        output += "    static var storyboard: \(os.storyboardType) { get }\n"
        output += "    static var identifier: String { get }\n"
        output += "}\n"
        output += "\n"

        output += "struct Storyboards {\n"
        for file in storyboards {
            output += file.storyboard.processStoryboard(storyboardName: file.storyboardName, os: os)
        }
        output += "}\n"
        output += "\n"

        output += "//MARK: - ReusableKind\n"
        output += "enum ReusableKind: String, CustomStringConvertible {\n"
        output += "    case TableViewCell = \"tableViewCell\"\n"
        output += "    case CollectionViewCell = \"collectionViewCell\"\n"
        output += "\n"
        output += "    var description: String { return self.rawValue }\n"
        output += "}\n"
        output += "\n"

        output += "//MARK: - SegueKind\n"
        output += "enum SegueKind: String, CustomStringConvertible {    \n"
        output += "    case Relationship = \"relationship\" \n"
        output += "    case Show = \"show\"                 \n"
        output += "    case Presentation = \"presentation\" \n"
        output += "    case Embed = \"embed\"               \n"
        output += "    case Unwind = \"unwind\"             \n"
        output += "    case Push = \"push\"                 \n"
        output += "    case Modal = \"modal\"               \n"
        output += "    case Popover = \"popover\"           \n"
        output += "    case Replace = \"replace\"           \n"
        output += "    case Custom = \"custom\"             \n"
        output += "\n"
        output += "    var description: String { return self.rawValue } \n"
        output += "}\n"
        output += "\n"
        output += "//MARK: - IdentifiableProtocol\n"
        output += "\n"
        output += "public protocol IdentifiableProtocol: Equatable {\n"
        output += "    var storyboardIdentifier: String? { get }\n"
        output += "}\n"
        output += "\n"
        output += "//MARK: - SegueProtocol\n"
        output += "\n"
        output += "public protocol SegueProtocol {\n"
        output += "    var identifier: String? { get }\n"
        output += "}\n"
        output += "\n"

        output += "public func ==<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {\n"
        output += "    return lhs.identifier == rhs.identifier\n"
        output += "}\n"
        output += "\n"
        output += "public func ~=<T: SegueProtocol, U: SegueProtocol>(lhs: T, rhs: U) -> Bool {\n"
        output += "    return lhs.identifier == rhs.identifier\n"
        output += "}\n"
        output += "\n"
        output += "public func ==<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {\n"
        output += "    return lhs.identifier == rhs\n"
        output += "}\n"
        output += "\n"
        output += "public func ~=<T: SegueProtocol>(lhs: T, rhs: String) -> Bool {\n"
        output += "    return lhs.identifier == rhs\n"
        output += "}\n"
        output += "\n"
        output += "public func ==<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {\n"
        output += "    return lhs == rhs.identifier\n"
        output += "}\n"
        output += "\n"
        output += "public func ~=<T: SegueProtocol>(lhs: String, rhs: T) -> Bool {\n"
        output += "    return lhs == rhs.identifier\n"
        output += "}\n"
        output += "\n"

        output += "//MARK: - ReusableViewProtocol\n"
        output += "public protocol ReusableViewProtocol: IdentifiableProtocol {\n"
        output += "    var viewType: \(os.viewType).Type? { get }\n"
        output += "}\n"
        output += "\n"

        output += "public func ==<T: ReusableViewProtocol, U: ReusableViewProtocol>(lhs: T, rhs: U) -> Bool {\n"
        output += "    return lhs.storyboardIdentifier == rhs.storyboardIdentifier\n"
        output += "}\n"
        output += "\n"

        output += "//MARK: - Protocol Implementation\n"
        output += "extension \(os.storyboardSegueType): SegueProtocol {\n"
        output += "}\n"
        output += "\n"

        if let reusableViews = os.resuableViews {
            for reusableView in reusableViews {
                output += "extension \(reusableView): ReusableViewProtocol {\n"
                output += "    public var viewType: UIView.Type? { return type(of: self) }\n"
                output += "    public var storyboardIdentifier: String? { return self.reuseIdentifier }\n"
                output += "}\n"
                output += "\n"
            }
        }

        for controllerType in os.storyboardControllerTypes {
            output += "//MARK: - \(controllerType) extension\n"
            output += "extension \(controllerType) {\n"
            output += "    func perform<T: SegueProtocol>(segue: T, sender: AnyObject?) {\n"
            output += "        if let identifier = segue.identifier {\n"
            output += "            performSegue(withIdentifier: identifier, sender: sender)\n"
            output += "        }\n"
            output += "    }\n"
            output += "\n"
            output += "    func perform<T: SegueProtocol>(segue: T) {\n"
            output += "        perform(segue: segue, sender: nil)\n"
            output += "    }\n"
            output += "}\n"
            output += "\n"
        }

        if os == OS.iOS {
            output += "//MARK: - UICollectionView\n"
            output += "\n"
            output += "extension UICollectionView {\n"
            output += "\n"
            output += "    func dequeue<T: ReusableViewProtocol>(reusable: T, for: IndexPath) -> UICollectionViewCell? {\n"
            output += "        if let identifier = reusable.storyboardIdentifier {\n"
            output += "            return dequeueReusableCell(withReuseIdentifier: identifier, for: `for`)\n"
            output += "        }\n"
            output += "        return nil\n"
            output += "    }\n"
            output += "\n"
            output += "    func register<T: ReusableViewProtocol>(reusable: T) {\n"
            output += "        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {\n"
            output += "            register(type, forCellWithReuseIdentifier: identifier)\n"
            output += "        }\n"
            output += "    }\n"
            output += "\n"
            output += "    func dequeueReusableSupplementaryViewOfKind<T: ReusableViewProtocol>(elementKind: String, withReusable reusable: T, for: IndexPath) -> UICollectionReusableView? {\n"
            output += "        if let identifier = reusable.storyboardIdentifier {\n"
            output += "            return dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier, for: `for`)\n"
            output += "        }\n"
            output += "        return nil\n"
            output += "    }\n"
            output += "\n"
            output += "    func register<T: ReusableViewProtocol>(reusable: T, forSupplementaryViewOfKind elementKind: String) {\n"
            output += "        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {\n"
            output += "            register(type, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)\n"
            output += "        }\n"
            output += "    }\n"
            output += "}\n"

            output += "//MARK: - UITableView\n"
            output += "\n"
            output += "extension UITableView {\n"
            output += "\n"
            output += "    func dequeue<T: ReusableViewProtocol>(reusable: T, for: IndexPath) -> UITableViewCell? {\n"
            output += "        if let identifier = reusable.storyboardIdentifier {\n"
            output += "            return dequeueReusableCell(withIdentifier: identifier, for: `for`)\n"
            output += "        }\n"
            output += "        return nil\n"
            output += "    }\n"
            output += "\n"
            output += "    func register<T: ReusableViewProtocol>(reusable: T) {\n"
            output += "        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {\n"
            output += "            register(type, forCellReuseIdentifier: identifier)\n"
            output += "        }\n"
            output += "    }\n"
            output += "\n"
            output += "    func dequeueReusableHeaderFooter<T: ReusableViewProtocol>(_ reusable: T) -> UITableViewHeaderFooterView? {\n"
            output += "        if let identifier = reusable.storyboardIdentifier {\n"
            output += "            return dequeueReusableHeaderFooterView(withIdentifier: identifier)\n"
            output += "        }\n"
            output += "        return nil\n"
            output += "    }\n"
            output += "\n"
            output += "    func registerReusableHeaderFooter<T: ReusableViewProtocol>(_ reusable: T) {\n"
            output += "        if let type = reusable.viewType, let identifier = reusable.storyboardIdentifier {\n"
            output += "             register(type, forHeaderFooterViewReuseIdentifier: identifier)\n"
            output += "        }\n"
            output += "    }\n"
            output += "}\n"
            output += "\n"
        }

        for file in storyboards {
            output += file.storyboard.processViewControllers()
        }

        return output
    }
}
