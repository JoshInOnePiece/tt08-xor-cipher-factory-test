# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def seriallyInput(DUT, dataType, data, clockDelay):
    dataString = str(data)
    if(dataType == 1): #This means that we are inputting a message
        await ClockCycles(DUT.iClk, clockDelay)
        for x in range(512):
            DUT.iData_in.value = int(dataString[x])
            await ClockCycles(DUT.iClk, clockDelay)
    else: # Otherwise we are inputting a key
        DUT.iLoad_key.value = 1
        for x in range(32):
            DUT.iData_in.value = int(dataString[x])
            await ClockCycles(DUT.iClk, clockDelay)
    
@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 MHz)
    clock = Clock(dut.iClk, 10, units="ns")
    cocotb.start_soon(clock.start())
    dut.iRst.value = 1
    dut.iEn.value = 0
    dut.iLoad_key.value = 0
    dut.iLoad_msg.value = 0
    dut.iSerial_in.value = 0

    # Apply Reset
    dut._log.info("Reset")
    dut.iRst.value = 0
    await ClockCycles(dut.iClk, 1)
    dut.iRst.value = 1
    await ClockCycles(dut.iClk, 1)

    # Start Key Loading Process
    dut.iEn.value = 1
    keyInteger = 0xA5A5A5A5
    messageInteger = 0xA3B1F9D2E7C6A5948B7D3E2F1A4C9E7D6B5A2F8C9D1E4B6A3958C7D2E1F3A6B9C4D8E7F1A2B3C5D7E6F9A4B2C8D3E9F1C7A2B5D8E4F9C3D1B7A4C6F2E8D5B3A9C7D4F1E6B8A2C3D5F9E7B4A1C9D2E8F6B5A3C7D1F2E4
    key = format(keyInteger, '0>32b')
    message = format(messageInteger, '0>512b')

    dut.iLoad_key.value = 1
    await seriallyInput(DUT=dut, dataType=0, data=key, clockDelay=1)
    await ClockCycles(dut.iClk, 2)
    dut.iLoad_key.value = 0
    await ClockCycles(dut.iClk, 2)
    dut.iLoad_msg.value = 1
    await seriallyInput(DUT=dut, dataType=1, data=message, clockDelay=1)
    dut.iLoad_msg.value = 0

    while True:
        if dut.xor_encryptor.oEncrypt_done == 1:
            break
    
    


    """""
    await ClockCycles(dut.iClk, 4)
    dut.iLoad_key.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iLoad_key.value = 0

    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0

    await ClockCycles(dut.iClk, 4)
    dut.iLoad_msg.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.iClk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.iClk, 4)
    dut.iLoad_msg.value = 0
    """""
    await ClockCycles(dut.iClk, 80)
    """""
    for i in range(256):
        dut.uio_in.value = i
        await ClockCycles(dut.iClk, 1)
        assert dut.uo_out.value == i

        
    # When under reset: Output is uio_in, uio is in input mode
    dut.rst_n.value = 0
    await ClockCycles(dut.iClk, 1)
    assert dut.uio_oe.value == 0
    for i in range(256):
        dut.ui_in.value = i
        await ClockCycles(dut.iClk, 1)
        assert dut.uo_out.value == i
    """""