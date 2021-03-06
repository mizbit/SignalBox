//
//  PWMChannel.swift
//  RaspberryPi
//
//  Created by Scott James Remnant on 6/10/18.
//

/// PWM Channel
///
/// Instances of this class are vended by `PWM` and combine the reference to the vending `pwm`
/// instance, and the channel `number`.
public final class PWMChannel {
    
    /// PWM instance.
    public let pwm: PWM
    
    /// Channel number.
    public let number: Int
    
    internal init(pwm: PWM, number: Int) {
        self.pwm = pwm
        self.number = number
    }
    
    /// PWM channel enabled.
    public var isEnabled: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.control.contains(.channel1Enabled)
            case 2: return pwm.registers.pointee.control.contains(.channel2Enabled)
            default: preconditionFailure("invalid channel")
            }
        }
        
        set {
            let enabled: PWMControl
            switch number {
            case 1: enabled = .channel1Enabled
            case 2: enabled = .channel2Enabled
            default: preconditionFailure("invalid channel")
            }
            
            if newValue {
                pwm.registers.pointee.control.insert(enabled)
            } else {
                pwm.registers.pointee.control.remove(enabled)
            }
        }
    }
    
    /// PWM channel mode.
    ///
    /// Chooses the mode of the PWM channel, selecting the behavior of the `range` and `data`
    /// for the channel.
    ///
    /// Encapsulates both the MODEx and MSENx fields of the control register.
    public var mode: PWMMode {
        get {
            let serializerMode: PWMControl, useMarkSpace: PWMControl
            switch number {
            case 1: (serializerMode, useMarkSpace) = (.channel1SerializerMode, .channel1UseMarkSpace)
            case 2: (serializerMode, useMarkSpace) = (.channel2SerializerMode, .channel2UseMarkSpace)
            default: preconditionFailure("invalid channel")
            }
            
            let control = pwm.registers.pointee.control
            switch (control.contains(serializerMode), control.contains(useMarkSpace)) {
            case (true, _): return .serializer
            case (false, true): return .markSpace
            case (false, false): return .pwm
            }
        }
        
        set {
            let serializerMode: PWMControl, useMarkSpace: PWMControl
            switch number {
            case 1: (serializerMode, useMarkSpace) = (.channel1SerializerMode, .channel1UseMarkSpace)
            case 2: (serializerMode, useMarkSpace) = (.channel2SerializerMode, .channel2UseMarkSpace)
            default: preconditionFailure("invalid channel")
            }
            
            var control = pwm.registers.pointee.control
            switch newValue {
            case .pwm:
                control.remove(serializerMode)
                control.remove(useMarkSpace)
            case .markSpace:
                control.remove(serializerMode)
                control.insert(useMarkSpace)
            case .serializer:
                control.insert(serializerMode)
                control.remove(useMarkSpace)
            }
            pwm.registers.pointee.control = control
        }
    }
    
    /// Range of channel.
    ///
    /// The behavior of the range depends on the `mode` of the PWM, and works with the value in
    /// `data` of from the FIRO.
    ///
    /// In PWM mode the range and data define a ratio of time, the output will be high during
    /// the `data` portion and low during the remainder of `range`. The duration of `data`
    /// lasts for one clock cycle, and the duration of the remainder lasts for whatever the ratio
    /// demands.
    ///
    /// In Mark-space mode `data` bits of one cycle each will be output high, while the
    /// remainder of `range` bits will be output low.
    ///
    /// In Serializer mode `range` defines the number of most-significant bits of `data` that will
    /// be transmitted, with the high or low state determined by `data`. In this mode ranges over
    /// a value of 32 result in padding zeros at the end of data.
    public var range: UInt32 {
        get {
            switch number {
            case 1: return pwm.registers.pointee.channel1Range
            case 2: return pwm.registers.pointee.channel2Range
            default: preconditionFailure("invalid channel")
            }
        }
        set {
            switch number {
            case 1: pwm.registers.pointee.channel1Range = newValue
            case 2: pwm.registers.pointee.channel2Range = newValue
            default: preconditionFailure("invalid channel")
            }
        }
    }
    
    /// Channel data.
    ///
    /// The behavior of channel data depends on the `mode` of the PWM, and works with the value in
    /// `range`. In addition, data is unused when `useFifo` is `true`.
    ///
    /// In PWM mode the range and data define a ratio of time, the output will be high during
    /// the `data` portion and low during the remainder of `range`. The duration of `data`
    /// lasts for one clock cycle, and the duration of the remainder lasts for whatever the ratio
    /// demands.
    ///
    /// In Mark-space mode `data` bits of one cycle each will be output high, while the
    /// remainder of `range` bits will be output low.
    ///
    /// In Serializer mode `range` defines the number of most-significant bits of `data` that will
    /// be transmitted, with the high or low state determined by `data`. In this mode ranges over
    /// a value of 32 result in padding zeros at the end of data.
    public var data: UInt32 {
        get {
            switch number {
            case 1: return pwm.registers.pointee.channel1Data
            case 2: return pwm.registers.pointee.channel2Data
            default: preconditionFailure("invalid channel")
                
            }
        }
        set {
            switch number {
            case 1: pwm.registers.pointee.channel1Data = newValue
            case 2: pwm.registers.pointee.channel2Data = newValue
            default: preconditionFailure("invalid channel")
            }
        }
    }
    
    /// Channel silence bit.
    ///
    /// Selects the state of the channel when there is no data to transmit, or when padding
    /// data in serializer mode.
    public var silenceBit: PWMBit {
        get {
            let silenceBit: PWMControl
            switch number {
            case 1: silenceBit = .channel1SilenceBit
            case 2: silenceBit = .channel2SilenceBit
            default: preconditionFailure("invalid channel")
            }
            
            return pwm.registers.pointee.control.contains(silenceBit) ? .high : .low
        }
        
        set {
            let silenceBit: PWMControl
            switch number {
            case 1: silenceBit = .channel1SilenceBit
            case 2: silenceBit = .channel2SilenceBit
            default: preconditionFailure("invalid channel")
            }
            
            switch newValue {
            case .high: pwm.registers.pointee.control.insert(silenceBit)
            case .low: pwm.registers.pointee.control.remove(silenceBit)
            }
        }
    }
    
    /// Channel output polarity is inverted.
    ///
    /// When `true` the channel will output high for a 0, and low for a 1.
    public var invertPolarity: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.control.contains(.channel1InvertPolarity)
            case 2: return pwm.registers.pointee.control.contains(.channel2InvertPolarity)
            default: preconditionFailure("invalid channel")
            }
        }
        
        set {
            let invertPolarity: PWMControl
            switch number {
            case 1: invertPolarity = .channel1InvertPolarity
            case 2: invertPolarity = .channel2InvertPolarity
            default: preconditionFailure("invalid channel")
            }
            
            if newValue {
                pwm.registers.pointee.control.insert(invertPolarity)
            } else {
                pwm.registers.pointee.control.remove(invertPolarity)
            }
        }
    }
    
    // MARK: Channel-specific state
    
    /// Channel is transmitting.
    ///
    /// - Note:
    ///   Setting the value to false actually writes 1 to the underlying bit; the interface is
    ///   intended to be more programatic than the underlying hardware register.
    public var isTransmitting: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.status.contains(.channel1Transmitting)
            case 2: return pwm.registers.pointee.status.contains(.channel2Transmitting)
            default: preconditionFailure("invalid channel")
            }
        }
    }
    
    /// Gap occurred during transmission.
    ///
    /// - Note:
    ///   Setting the value to false actually writes 1 to the underlying bit; the interface is
    ///   intended to be more programatic than the underlying hardware register.
    public var gapOccurred: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.status.contains(.channel1GapOccurred)
            case 2: return pwm.registers.pointee.status.contains(.channel2GapOccurred)
            default: preconditionFailure("invalid channel")
            }
        }
        
        set {
            if !newValue {
                switch number {
                case 1: pwm.registers.pointee.status.insert(.channel1GapOccurred)
                case 2: pwm.registers.pointee.status.insert(.channel2GapOccurred)
                default: preconditionFailure("invalid channel")
                }
            }
        }
    }
    
    /// Channel uses FIFO.
    ///
    /// When `true` the channel will use data written to `fifoInput` rather than `data`.
    public var useFifo: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.control.contains(.channel1UseFifo)
            case 2: return pwm.registers.pointee.control.contains(.channel2UseFifo)
            default: preconditionFailure("invalid channel")
            }
        }
        
        set {
            let useFifo: PWMControl
            switch number {
            case 1: useFifo = .channel1UseFifo
            case 2: useFifo = .channel2UseFifo
            default: preconditionFailure("invalid channel")
            }
            
            if newValue {
                pwm.registers.pointee.control.insert(useFifo)
            } else {
                pwm.registers.pointee.control.remove(useFifo)
            }
        }
    }
    
    /// Channel repeats FIFO data.
    ///
    /// When `true`, if the FIFO becomes empty, the last data written to it is repeated rather
    /// than `silenceBit` being output. Has no effect when `useFifo` is `false`.
    public var repeatLastData: Bool {
        get {
            switch number {
            case 1: return pwm.registers.pointee.control.contains(.channel1RepeatLastData)
            case 2: return pwm.registers.pointee.control.contains(.channel2RepeatLastData)
            default: preconditionFailure("invalid channel")
            }
        }
        
        set {
            let repeatLastData: PWMControl
            switch number {
            case 1: repeatLastData = .channel1RepeatLastData
            case 2: repeatLastData = .channel2RepeatLastData
            default: preconditionFailure("invalid channel")
            }
            
            if newValue {
                pwm.registers.pointee.control.insert(repeatLastData)
            } else {
                pwm.registers.pointee.control.remove(repeatLastData)
            }
        }
    }
    
}

// MARK: Debugging

extension PWMChannel : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var parts: [String] = []

        parts.append("\(type(of: self)) \(number)")
        if isEnabled { parts.append("enabled") }
        parts.append("mode: \(mode)")
        parts.append("range: \(range)")
        parts.append("data: \(data)")
        if silenceBit != .low { parts.append("silenceBit: \(silenceBit)") }
        if invertPolarity { parts.append("invertPolarity") }
        if isTransmitting { parts.append("transmitting") }
        if gapOccurred { parts.append("gapOccurred") }
        if useFifo { parts.append("useFifo") }
        if repeatLastData { parts.append("repeatLastData")}
        
        return "<" + parts.joined(separator: ", ") + ">"
    }
    
}
