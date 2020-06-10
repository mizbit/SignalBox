//
//  AddressTests.swift
//  DCCTests
//
//  Created by Scott James Remnant on 6/9/20.
//

import XCTest

import DCC

class AddressTests : XCTestCase {

    /// Check the binary pattenr of the broadcast address.
    func testBroadcastAddress() {
        let address = Address.broadcast

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b00000000 ])
    }

    /// Check the binary pattern of a primary address.
    func testPrimaryAddress() {
        let address = Address.primary(3)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b00000011 ])
    }

    /// Check the binary pattern of an extended address that fits in the second byte.
    func testSimpleExtendedAddress() {
        let address = Address.extended(210)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b11000000, 0b11010010 ])
    }

    /// Check the binary pattern of an extended address that requires both bytes.
    func testBothBytesExtendedAddress() {
        let address = Address.extended(1250)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b11000100, 0b11100010 ])
    }

    /// Check the binary pattern of an extended address in the overlapped space still contains two bytes.
    func testOverlappedExtendedAddress() {
        let address = Address.extended(3)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b11000000, 0b00000011 ])
    }

    /// Check the binary pattern of an accessory address, including the one's complement part.
    func testAccessoryAddress() {
        let address = Address.accessory(310)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b10100110, 0b10010000 ])
        XCTAssertEqual(packer.bitsRemaining, 4)
    }

    /// Check the binary pattern of an extended accessory (signal) address.
    func testSignalAddress() {
        let address = Address.signal(1134)

        var packer = BitPacker<UInt8>()
        packer.add(address)

        XCTAssertEqual(packer.results, [ 0b10100011, 0b00110101 ])
    }

}
