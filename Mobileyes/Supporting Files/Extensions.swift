
import SwiftMessages
import UIKit

extension UIViewController {
    
    // MARK: - Swift Messages Functions
    
    func showDefaultError() {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(body: "Something went wrong")
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .automatic
        config.duration = .seconds(seconds: 1.5)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        SwiftMessages.show(config: config, view: view)
    }
    
    func showError(with message: String) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(body: message)
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .automatic
        config.duration = .seconds(seconds: 1.5)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        SwiftMessages.show(config: config, view: view)
    }
}
