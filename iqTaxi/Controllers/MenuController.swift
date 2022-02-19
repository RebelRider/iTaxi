import UIKit

private let reuseIdentifier = "MenuCell"

enum MenuOptions: Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips: return "Your Trips"
        case .settings: return "Settings"
        case .logout: return "Log Out"
        }
    }
}

protocol MenuControllerDelegate: AnyObject {//???
    func didSelect(option: MenuOptions)
}

class MenuController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    private let user: User
    weak var delegate: MenuControllerDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var menuHeader: MenuHeader = {
        let frame = CGRect(x: 0,
                           y: 54,
                           width: self.view.frame.width - 80,
                           height: 140)
        let view = MenuHeader(user: user, frame: frame)
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        print("Authorized as  \(user) \n .... init MenuController DONE")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("OK: viewDidLoad MenuController")
        super.viewDidLoad()
        view.tintColor = .green
        view.backgroundColor = .red
        setupUI()
        setupTableView()
        configureTableView()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helper Functions
    
    private func setupUI(){
        view.backgroundColor = .white
        print("DEBUG: setupUI MenuController ...DONE")
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)//, paddingTop: 44)
    }
    
    func configureTableView() {
        print("DEBUG: calling -configureTableView in MenuController-")
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 59
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}

// MARK: - UITableViewDelegate/DataSource

extension MenuController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        print("DEBUG: calling -cellForRowAt-")
        guard let option = MenuOptions(rawValue: indexPath.row) else { print("DEBUG: options -cellForRowAt- is nil!")
            return UITableViewCell() }
        cell.textLabel?.text = option.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG: calling -didSelectRowAt-")
        guard let option = MenuOptions(rawValue: indexPath.row) else { print("DEBUG: options -didSelectRowAt- is nil!")
            return }
        delegate?.didSelect(option: option)
    }
}
