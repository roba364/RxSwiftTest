import Foundation

public func example(_ rxOperator: String, completion: () -> ()) {
    print("\n--- Example of:", rxOperator, "---")
    completion()
}
