//
//  SoundViewController.swift
//  SoundBoardCancino
//
//  Created by Mac 09 on 5/21/21.
//  Copyright © 2021 Mac 09. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarBoton: UIButton!
    @IBOutlet weak var reproducirBoton: UIButton!
    @IBOutlet weak var nombreTextfield: UITextField!
    @IBOutlet weak var tiempoAudio: UILabel!
    @IBOutlet weak var agregarBoton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio = AVAudioPlayer()
    var audioURL:URL?
  
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarBoton.setTitle("GRABAR", for: .normal)
            reproducirBoton.isEnabled = true
            agregarBoton.isEnabled = true
        }else{
            grabarAudio?.record()
            grabarBoton.setTitle("DETENER", for: .normal)
            tiempoAudio.text = getFormatoTiempo(tiempoIntervalo: reproducirAudio.currentTime)
            reproducirBoton.isEnabled = false
        }
    }
    
    private func getFormatoTiempo(tiempoIntervalo: TimeInterval) -> String {
        let mins = tiempoIntervalo / 60
        let secs = tiempoIntervalo.truncatingRemainder(dividingBy: 60)
        let timeFormatter = NumberFormatter()
        timeFormatter.minimumIntegerDigits = 2
        timeFormatter.minimumFractionDigits = 0
        timeFormatter.roundingMode = .down
        
        guard let minsString = timeFormatter.string(from: NSNumber(value: mins)), let secStr =
            timeFormatter.string(from: NSNumber(value: secs)) else {
                return "00:00"
        }
        return "\(minsString):\(secStr)"
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
                   try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
                   reproducirAudio.play()
                   tiempoAudio.text = getFormatoTiempo(tiempoIntervalo: reproducirAudio.duration)
                       let tiempo = Float(reproducirAudio.duration)
            

                   print("Reproduciendo \(tiempo)")
                
               }catch{
                   
               }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let grabacion = Grabacion(context: context)
            let tiempo = Float(reproducirAudio.duration)
            print("Agregandodddd \(tiempo)")
            grabacion.nombre = nombreTextfield.text
            grabacion.audio = NSData(contentsOf: audioURL!)! as Data
            grabacion.duracion = tiempo
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController!.popViewController(animated: true)
        }catch{
            
        }
    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("**********************")
            print(audioURL!)
            print("**********************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configurarGrabacion()
        reproducirBoton.isEnabled = false
        agregarBoton.isEnabled = false
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
