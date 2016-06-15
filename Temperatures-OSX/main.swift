//
//  main.swift
//  Temp
//
//  Created by Manuel Leitold on 14.06.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation

enum SystemTemperaturesError : ErrorType {
    case ErrorExecutingiStats
    case ErrorBadFormat
    case ErrorReturnedOnStderr(error: String)
}

class SystemTemperatures {
    
    private(set) var cpuTemperature: Double?
    private(set) var batteryTemperature: Double?
    
    init() throws {
        try reload()
    }
    
    func reload() throws {
        let stdoutPipe = NSPipe()
        let stdoutFile = stdoutPipe.fileHandleForReading
        
        let stderrPipe = NSPipe()
        let stderrFile = stderrPipe.fileHandleForReading
        
        // close handles at the end of the function scope
        defer {
            stdoutFile.closeFile()
            stderrFile.closeFile()
        }
        
        // create task
        let task = NSTask()
        task.launchPath = "/usr/local/bin/istats"
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe

        // launch task
        // Exceptions like NSInvalidArgumentException can only be caught in ObjC :(
        if !ObjCTryCatch.executeSafe(task.launch) {
            throw SystemTemperaturesError.ErrorExecutingiStats
        }
        
        // read data from stdout and process it
        let stdoutData = stdoutFile.readDataToEndOfFile()
        if let str = NSString(data: stdoutData, encoding: NSUTF8StringEncoding) {
            try process(str as String)
        }
        
        let stderrData = stderrFile.readDataToEndOfFile()
        if let str = NSString(data: stderrData, encoding: NSUTF8StringEncoding) {
            if str.length > 0 {
                throw SystemTemperaturesError.ErrorReturnedOnStderr(error: str as String)
            }
            
        }
    }
    
    private func process(data: String) throws {
        // create regex pattern
        guard let pattern = try? NSRegularExpression(
            pattern: "\\d+.\\d+°",
            options: [.CaseInsensitive]) else {
                return
        }
        
        // look for matches
        let matches = pattern.matchesInString(
            data,
            options: [],
            range: NSMakeRange(0, data.characters.count))
        
        if matches.count != 2 {
            throw SystemTemperaturesError.ErrorBadFormat
        }
        
        // iterate through the matches
        for (i, match) in matches.enumerate() {
            
            // adjust the range (remove °-character)
            var newRange = match.range
            newRange.length -= 1
            
            // parse value
            let value = Double((data as NSString).substringWithRange(newRange))
            
            // the first match is cpu, the second one is battery
            if i == 0 { cpuTemperature = value }
            if i == 1 { batteryTemperature = value }
        }
    }
}

while(true) {
    do {
        let sys = try SystemTemperatures()
        
        if let temp = sys.cpuTemperature {
            print("CPU temperature: \(temp)")
        }
        
        if let temp = sys.batteryTemperature {
            print("Battery temperature: \(temp)")
        }
    }
    catch {
        print("Exception occured while reading system temperatures: \(error)")
    }
}


