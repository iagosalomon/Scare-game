//
//  ViewController.swift
//  MotionSensors
//
//  Created by Bruno Omella Mainieri on 14/06/19.
//  Copyright © 2019 Bruno Omella Mainieri. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate {
    
    
    @IBOutlet weak var Label: UILabel!
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var Button: UIButton!
    
    @IBOutlet weak var image: UIImageView!
    var Scare = false
    

    
    var referenceAttitude:CMAttitude?
    
    let motion = CMMotionManager()
    
    var lastXUpdate = 0.0
    var lastYUpdate = 0.0
    var lastZUpdate = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        image.isHidden = true
        startDeviceMotion()
    }
    
    func startDeviceMotion() {
        if motion.isDeviceMotionAvailable {
            //Frequencia de atualização dos sensores definida em segundos - no caso, 60 vezes por segundo
            self.motion.deviceMotionUpdateInterval = 1.0 / 60.0
            self.motion.showsDeviceMovementDisplay = true
            //A partir da chamada desta função, o objeto motion passa a conter valores atualizados dos sensores; o parâmetro representa a referência para cálculo de orientação do dispositivo
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            //Um Timer é configurado para executar um bloco de código 60 vezes por segundo - a mesma frequência das atualizações dos dados de sensores. Neste bloco manipulamos as informações mais recentes para atualizar a interface.
            var timer = Timer(fire: Date(), interval: (1.0 / 60.0), repeats: true,
                              block: { (timer) in
                                if let data = self.motion.deviceMotion {
                                    var relativeAttitude = data.attitude
                                    if let ref = self.referenceAttitude{
                                        //Esta função faz a orientação do dispositivo ser calculado com relação à orientação de referência passada
                                        relativeAttitude.multiply(byInverseOf: ref)
                                    }
                                    if self.Scare == true {
                                        
                                        if abs(self.lastYUpdate - self.motion.deviceMotion!.attitude.roll) > 0.3 || abs(self.lastXUpdate - self.motion.deviceMotion!.attitude.pitch) > 0.3 ||  abs(self.lastZUpdate - self.motion.deviceMotion!.attitude.yaw) > 0.3{
                                            
                                            
                                            
                                            
                    
                                            let soundURL = Bundle.main.url(forResource: "nmh_scream1", withExtension: "mp3")
                                            do {
                                                self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
                                                self.audioPlayer!.play()
                                            }
                                            catch {
                                            }
                                            
                                            
                                            sleep(5)
                                            self.Label.text = "Wanna do it again"
                                            self.Button.setTitle("Scare", for: .normal)
                                            self.image.isHidden = true
                                            self.Scare = false
                                            
                                        }
                                        
                                    }
                                }
            })
            
            RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        }
    }
    
    //Ao tocar na tela, a orientação atual do dispositivo passa a ser considerada a de referência com relação à qual os dados serão calculados
    
    @IBAction func BeginScare(_ sender: Any) {
        Label.text = ""
        Button.setTitle("", for: .normal)
        
        lastYUpdate = self.motion.deviceMotion!.attitude.roll
        lastXUpdate = self.motion.deviceMotion!.attitude.pitch
        lastZUpdate = self.motion.deviceMotion!.attitude.yaw

        
        Scare = true
    }
    

    
    
    
}

