import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.clock import Clock

def reset_input(dut):
  dut.rst.value          = 1
  dut.mdu_in_valid.value = 0
  dut.funct3.value       = 0
  dut.mdu_in_1.value     = 0
  dut.mdu_in_2.value     = 0
  dut.cpu_busy.value     = 0

async def generate_rst(dut):
  await Timer(1.5, units='ns')
  dut.rst.value = 0

async def wait_answer(dut):
  while not dut.mdu_out_valid.value:
    await Timer(1, units='ns')

async def mul(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 0
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nmul test:')
  print('{} x {} = {} (decimal)'.format(val1, val2, val1 * val2))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def div(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 4
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\ndiv test:')
  print('{} // {} = ?'.format(val1, val2))
  print('abs({}) // abs({}) = {} (decimal)'.format(val1, val2, abs(val1) // abs(val2)))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def divu(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 5
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\ndivu test:')
  print('{} // {} = ?'.format(val1, val2))
  print('abs({}) // abs({}) = {} (decimal)'.format(abs(val1), abs(val2), abs(val1) // abs(val2)))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def rem(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 6
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nrem test:')
  print('{} % {} = ?'.format(val1, val2))
  print('abs({}) % abs({}) = {} (decimal)'.format(val1, val2, abs(val1) % abs(val2)))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def remu(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 7
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nremu test:')
  print('{} % {} = ?'.format(val1, val2))
  print('abs({}) % abs({}) = {} (decimal)'.format(val1, val2, abs(val1) % abs(val2)))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def mulh(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 1
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nmulh test:')
  print('{} x {} = {} (decimal)'.format(val1, val2, val1 * val2))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def mulhsu(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 2
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nmulhsu test:')
  print('{} x {} = {} (decimal)'.format(val1, val2, val1 * val2))
  print('output = {} (binary)'.format(dut.mdu_out.value))

async def mulhu(dut, val1, val2):
  await RisingEdge(dut.clk)
  dut.mdu_in_valid.value = 1
  dut.funct3.value = 3
  dut.mdu_in_1.value = val1
  dut.mdu_in_2.value = val2
  await Timer(2, units='ns')
  dut.mdu_in_valid.value = 0
  await wait_answer(dut)
  print('\nmulhu test:')
  print('{} x {} = {} (decimal)'.format(val1, val2, val1 * val2))
  print('output = {} (binary)'.format(dut.mdu_out.value))

@cocotb.test()
async def mdu_test(dut):
  cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
  reset_input(dut)
  await generate_rst(dut)

  await div(dut, 72, 5)
  await div(dut, 72, -5)
  await div(dut, -72, 5)
  await div(dut, -72, -5)
  print('\n')

  await rem(dut, 72, 5)
  await rem(dut, 72, -5)
  await rem(dut, -72, 5)
  await rem(dut, -72, -5)
  print('\n')

  # await mul(dut, 20000, 10000)
  # await mul(dut, 10900, -100010)
  # await mul(dut, -180290, 10440)
  # await mul(dut, -233100, -171020)
  # print('\n')

  # await mulh(dut, 20000, 10000)
  # await mulh(dut, 10900, -100010)
  # await mulh(dut, -180290, 10440)
  # await mulh(dut, -233100, -171020)
  # print('\n')

  # await mulhsu(dut, 4294967295, 4294967295) # -1 * 4294967295
  # print('\n')

  # await mulhu(dut, 4294967295, 4294967295)
  # print('\n')