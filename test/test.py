# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def seriallyInput(DUT, dataType, data, clockDelay):
    dataString = str(data)
    if(dataType == 1): #This means that we are inputting a message
        DUT.iLoad_msg.value = 1
        await ClockCycles(DUT.clk, clockDelay)
        for x in range(512):
            DUT.iData_in.value = int(dataString[x])
            await ClockCycles(DUT.clk, clockDelay)
        DUT.iLoad_msg.value = 0
        await ClockCycles(DUT.clk, clockDelay)
    else: # Otherwise we are inputting a key
        DUT.iLoad_key.value = 1
        await ClockCycles(DUT.clk, clockDelay)
        for x in range(32):
            DUT.iData_in.value = int(dataString[x])
            await ClockCycles(DUT.clk, clockDelay)
        DUT.iLoad_key.value = 0
        await ClockCycles(DUT.clk, clockDelay)


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    dut.iEn.value = 0
    dut.iData_in.value = 0
    dut.iData_in.value = 0
    dut.iRst.value = 0
    dut.iLoad_key.value = 0
    dut.iLoad_msg.value = 0

    # Reset
    dut._log.info("Reset")
    dut.iRst.value = 0
    await ClockCycles(dut.clk, 1)
    
    await seriallyInput(DUT=dut, dataType=0, data=11011000110010110110001100101101, clockDelay=4)
    await seriallyInput(DUT=dut, dataType=1, data=11011000110010110110001100101101110110001100101101100011001011011101100011001011011000110010110111011000110010110110001100101101110110001100101101100011001011011101100011001011011000110010110111011000110010110110001100101101110110001100101101100011001011011101100011001011011000110010110111011000110010110110001100101101110110001100101101100011001011011101100011001011011000110010110111011000110010110110001100101101110110001100101101100011001011011101100011001011011000110010110111011000110010110110001100101101, clockDelay=4)
    
    """""
    await ClockCycles(dut.clk, 4)
    dut.iLoad_key.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iLoad_key.value = 0

    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0

    await ClockCycles(dut.clk, 4)
    dut.iLoad_msg.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 0
    await ClockCycles(dut.clk, 4)
    dut.iData_in.value = 1
    await ClockCycles(dut.clk, 4)
    dut.iLoad_msg.value = 0
    """""
    await ClockCycles(dut.clk, 80)
    """""
    for i in range(256):
        dut.uio_in.value = i
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == i

        
    # When under reset: Output is uio_in, uio is in input mode
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_oe.value == 0
    for i in range(256):
        dut.ui_in.value = i
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == i
    """""