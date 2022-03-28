import UIKit
import Firebase
import GeoFire

class SignUpController: UIViewController {
    
    // MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = UIImage(systemName: "signpost.right")
        let view = UIView().inputContainerView(image: image!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let image = UIImage(systemName: "signature")
        let view = UIView().inputContainerView(image: image!, textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(systemName: "lock.open")
        let view = UIView().inputContainerView(image: image!, textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let image = UIImage(systemName: "car.circle") 
        let view = UIView().inputContainerView(image: image!,
                                               segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
    
    private lazy var carModelContainerView: UIView = {
        let image = UIImage(systemName: "car")
        let view = UIView().inputContainerView(image: image!, textField: carmodelTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    
    
    
    
    private let emailTextField: UITextField = {
        let emtf = UITextField()
        emtf.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        emtf.keyboardType = UIKeyboardType.emailAddress
        emtf.isSecureTextEntry = false
        emtf.textColor = .white
        return emtf
    }()
    
    private let fullnameTextField: UITextField = {
        let fnmtf = UITextField()
        fnmtf.attributedPlaceholder = NSAttributedString(string:"Fullname", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        fnmtf.keyboardType = UIKeyboardType.asciiCapable
        fnmtf.isSecureTextEntry = false
        fnmtf.textColor = .white
        return fnmtf
    }()
    
    private let passwordTextField: UITextField = {
        let passtf = UITextField()
        passtf.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        passtf.keyboardType = UIKeyboardType.asciiCapable
        passtf.isSecureTextEntry = true
        passtf.textColor = .white
        return passtf
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let scz = UISegmentedControl(items: ["Rider", "Driver"])
        scz.backgroundColor = .backgroundColor
        scz.tintColor = UIColor(white: 1, alpha: 0.87)
        scz.selectedSegmentIndex = 0
        scz.addTarget(self, action: #selector(showHideCarModel(_:)), for: UIControl.Event.valueChanged)
        return scz
    }()
    
    private let carmodelTextField: UITextField = {
        let carm = UITextField()
        carm.attributedPlaceholder = NSAttributedString(string:"Car model", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        carm.keyboardType = UIKeyboardType.asciiCapable
        carm.isSecureTextEntry = false
        carm.textColor = .white
        return carm
    }()
    
    private let statusLabel: UILabel = {
        let slabel = UILabel()
        slabel.text = " "
        slabel.font = UIFont(name: "Avenir-Light", size: 15)
        slabel.textColor = UIColor(white: 1, alpha: 0.8)
        slabel.setDimensions(height: 44, width: 111)
        return slabel
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    
    
    // MARK: - Selectors
    
    @objc func showHideCarModel(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex != 1 {
            carModelContainerView.isHidden = true
        }
        else {
            carModelContainerView.isHidden = false
        }
    }
    
    @objc func handleSignUp() {
        statusLabel.text = ""
        print("DEBUG: handleSignUp called")
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let carmodel = carmodelTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
                
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                self.statusLabel.text = error.localizedDescription
                return
            }
            
            guard let uid = result?.user.uid else { return }
            print("DEBUG: creating user \(uid)")
            
            let values = ["email": email,
                          "fullname": fullname,
                          "accountType": accountTypeIndex] as [String : Any]
            
            if accountTypeIndex == 1 {
                let values = ["email": email,
                              "fullname": fullname,
                              "accountType": accountTypeIndex,
                              "carmodel": carmodel] as [String : Any]
                
                print("DEBUG: creating user as driver")
                print(values)
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                guard let location = self.location else {
                    print("DEBUG: driver location is nil! ERROR")
                    return }
                print("DEBUG: signed up as Driver, setting location")
                geofire.setLocation(location, forKey: uid, withCompletionBlock: { (error) in
                    self.uploadUserDataAndShowHomeController(uid: uid, values: values)
                })
            }
            
            self.uploadUserDataAndShowHomeController(uid: uid, values: values)
        }
    }
    
    @objc func handleShowLogin() {
        print("DEBUG: handleShowLogin called")
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    func uploadUserDataAndShowHomeController(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
            //check!!!
            //guard let controller = UIApplication.shared.keyWindow?.rootViewController as? ContainerController else { return }
            guard let controller = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? ContainerController else { print("DEBUG: controller is nil")
                return }//??? is it right solution?
            print("DEBUG: calling controller.configure func")
            controller.configure()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func configureUI() {
        showHideCarModel(accountTypeSegmentedControl)
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullnameContainerView,
                                                   passwordContainerView,
                                                   accountTypeContainerView,
                                                   carModelContainerView,
                                                   signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
}
