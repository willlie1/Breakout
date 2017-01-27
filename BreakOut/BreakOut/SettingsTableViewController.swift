//
//  SettingsTableViewController.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 20-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var RowsStepper: UIStepper!
    @IBOutlet weak var ColumnsStepper: UIStepper!
    @IBOutlet weak var BallsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var LivesStepper: UIStepper!
    @IBOutlet weak var BallSpeedSlider: UISlider!
    @IBOutlet weak var PaddleSizeSlider: UISlider!
    @IBOutlet weak var RowsLabel: UILabel!
    @IBOutlet weak var ColumnsLabel: UILabel!
    @IBOutlet weak var LivesLabel: UILabel!
    @IBOutlet weak var SoundSwitch: UISwitch!
    
    
    private var sound: Bool {
        get {
            return SettingsHelper.getSound()
        }
        set {
            SettingsHelper.saveSound(sound: newValue)
        }
    }
    private var rows: Int {
        get {
           return SettingsHelper.getRows()
        }
        set {
            self.RowsLabel.text = String(newValue)
            SettingsHelper.saveRows(rows: newValue)
        }
    }
    private var columns: Int {
        get {
            return SettingsHelper.getColumns()
        }
        set {
            self.ColumnsLabel.text = String(newValue)
            SettingsHelper.saveColumns(columns: newValue)
         }
    }
    private var balls: Int {
        get {
            return SettingsHelper.getBalls()
        }
        set {
            SettingsHelper.saveBalls(balls: newValue)
        }
    }
    private var lives: Int {
        get{
            return SettingsHelper.getLives()
        }
        set{
            self.LivesLabel.text = String(newValue)
            SettingsHelper.saveLives(lives: newValue)
        }
    }
    private var ballSpeed: Double {
        get {
            return SettingsHelper.getBallSpeed()
        }
        set {
            SettingsHelper.saveBallSpeed(ballSpeed: newValue)
        }
    }
    private var paddleSize: Double {
        get {
            return SettingsHelper.getPaddleWidth()
        }
        set {
            SettingsHelper.savePaddleWidth(paddleWith: newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.RowsLabel.text = String(rows)
        RowsStepper.value = Double(rows)
        self.ColumnsLabel.text = String(columns)
        ColumnsStepper.value = Double(columns)
        BallSpeedSlider.setValue(Float(ballSpeed), animated: false)
        self.LivesLabel.text = String(lives)
        LivesStepper.value = Double(lives)
        PaddleSizeSlider.setValue(Float(paddleSize), animated: false)
        BallsSegmentedControl.selectedSegmentIndex = balls-1
        SoundSwitch.isOn = sound
    }
    // MARK: - Stepper
    @IBAction func settingsStepperPressed(_ sender: UIStepper) {
        switch sender {
        case RowsStepper:
            rows = Int(RowsStepper.value)
        case ColumnsStepper:
            columns = Int(ColumnsStepper.value)
        case LivesStepper:
            lives = Int(LivesStepper.value)
        default:
            break
        }
    }
    // MARK: - Switch
    @IBAction func settingsSwitchValueChanged(_ sender: UISwitch) {
        switch sender {
        case SoundSwitch:
            sound = SoundSwitch.isOn
        default:
            break
        }
    }
    // MARK: - Slider
    @IBAction func settingsSliderValueChanged(_ sender: UISlider) {
        switch sender {
        case BallSpeedSlider:
            ballSpeed = Double(BallSpeedSlider.value)
        case PaddleSizeSlider:
            paddleSize = Double(PaddleSizeSlider.value)
        default:
            break
        }
    }
    // MARK: - SegmentedControl
    @IBAction func settingSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender {
        case BallsSegmentedControl:
            balls = Int(BallsSegmentedControl.titleForSegment(at: BallsSegmentedControl.selectedSegmentIndex)!)!
            break
        default:
            break
        }
        
    }
}
