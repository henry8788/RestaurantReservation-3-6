

import UIKit
import Starscream

protocol StockMenuPickDelegate: class {
    
    func displayBtNum(_ num:Int)
}

extension StockMenuTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(array[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let picker1 = pickerView.selectedRow(inComponent: 0)
        let picker2 = pickerView.selectedRow(inComponent: 1)
        let picker3 = pickerView.selectedRow(inComponent: 2)
        num = picker1 * 100 + picker2 * 10 + picker3
//        num = picker1 * 10 + picker2
       
//        print("\(num)")
        
        self.delegate?.displayBtNum(num)
        pickViewSelect = true
    }
    
}

class StockMenuTableViewController: UITableViewController , UIPickerViewDelegate {

    @IBOutlet weak var Segmented_SW: UISegmentedControl!
    @IBAction func Segmentedaction(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    let WIDTH = UIScreen.main.bounds.size.width
    let HEIGHT = UIScreen.main.bounds.size.height
    var pickview = UIPickerView()
    var array = [0,1,2,3,4,5,6,7,8,9]
    var num = 0
    var pickViewSelect = false
    
    weak var delegate: StockMenuPickDelegate?
    
    var menu_id = 0
    
    var tap : UITapGestureRecognizer?
    
    @IBAction func pickViewAction(_ sender: UIButton) {
        
//        let cell = sender.superview?.superview?.superview?.superview as!  StockTableViewCell
//        menu_id = cell.tag
//
//        pickview.frame.origin.y == self.HEIGHT ? viewslide(false) : viewslide(true)
//        pickview.selectRow(0, inComponent: 0, animated: true)
//        pickview.selectRow(0, inComponent: 1, animated: true)
//        pickview.selectRow(0, inComponent: 2, animated: true)
    }
    
    func viewslide(_ BOOL: Bool, completion: ((Bool) -> Void)! = nil) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { () -> Void in
                        self.pickview.frame.origin.y = BOOL ? self.HEIGHT : self.HEIGHT - 300
        },//位移的高
                       completion: nil)
    }
    
    let downloader = Downloader.shared
    let userDefault = UserDefaults()
    
    let decoder = JSONDecoder()
    let app = UIApplication.shared.delegate as! AppDelegate
    
    var socket = SocketClient.chatWebSocketClient

    var selectIndex = 0
    
    let reData = receiveData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reData.onSet(self)
        app.downloadMenuList(self)
        
        
        pickview.frame = CGRect(x: 0,
                                y: HEIGHT,
                                width: WIDTH,
                                height: 200)//本身的高
        pickview.delegate = self
        pickview.backgroundColor = UIColor(red: 133/255, green: 180/255, blue: 226/255, alpha: 1)
        view.addSubview(pickview)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeybroad))
        view.addGestureRecognizer(tap!)
        tap?.isEnabled = false
        
//        let button = UIBarButtonItem(title: "確定", style: .done, target: nil, action: #selector(UIbuttonAtion))
//        view.addSubview(button)
    }
    @objc
    func UIbuttonAtion() {
        
    }

    @IBAction func dismissKeybroad()  {
        viewslide(true)
        tap?.isEnabled = false
        
        guard menu_id != 0 else{
            return
        }
        
        guard pickViewSelect == true else{
            return
        }
        pickViewSelect = false
        
        print("menu_id:   \(menu_id)")
        
        
        downloader.menuUpdata_stock(fileName: #file,self.num, menu_id: menu_id) { (error, data) in

            print("menuUpdata_with_image: \(String(describing: String(data: data, encoding: .utf8)))")

            self.socket.sendMessage("notifyDataSetChanged")
            
            print("發送出")
        }
        self.num = 0
        self.menu_id = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //        socket.stopLinkServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let id = app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].id
        menu_id = id

        pickview.frame.origin.y == self.HEIGHT ? viewslide(false) : viewslide(true)
        pickview.selectRow(0, inComponent: 0, animated: true)
        pickview.selectRow(0, inComponent: 1, animated: true)
        pickview.selectRow(0, inComponent: 2, animated: true)
        
        tap?.isEnabled = true
        
//        guard let pop =
//            self.storyboard?.instantiateViewController(withIdentifier: "popview") as? popViewController else{
//                return
//        }
//
//        pop.menu_id = app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].id
//
//        pop.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        pop.modalPresentationStyle = .overCurrentContext //必須覆蓋過去
//        self.present(pop, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if app.menuList.count > 0 {
            
            if Segmented_SW.selectedSegmentIndex == 0{
                return app.menuList[0].count
            }else if Segmented_SW.selectedSegmentIndex == 1{
                return app.menuList[1].count
            }else{
                return app.menuList[2].count
            }
            
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100 //or whatever you need
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockmenucell", for: indexPath) as! StockTableViewCell
        
        let id = app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].id
        
        cell.FoodImage.showImage(urlString: downloader.Menu_URL,
                                 id: app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].id)
        let stock = app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].stock
        
        cell.menu_name.text = app.menuList[Segmented_SW.selectedSegmentIndex][indexPath.row].name
        cell.menu_stock.setTitle("\((stock))", for: .normal)
        
        cell.controler = self
        cell.tag = id
        
//        cell.menu_stock.addTarget(self, action: #selector(self.buttonpressed), for: .touchDown)
//        cell.tableHight = HEIGHT
//        cell.pickview = self.pickview
        
        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
