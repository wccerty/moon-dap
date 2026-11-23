vim.opt.runtimepath:prepend(assert(vim.env.MOON_DAP_NVIM_DAP))
local dap = require("dap")
local config = dofile("examples/bpflab/neovim.lua")
local source = vim.fn.fnamemodify("examples/bpflab/demo/helper.bpf", ":p")
vim.cmd.edit(vim.fn.fnameescape(source))
vim.api.nvim_win_set_cursor(0, { 4, 0 })
dap.toggle_breakpoint()

local stops = {}
dap.listeners.after.event_stopped["moon-dap-smoke"] = function(session, event)
  stops[#stops + 1] = { session = session, reason = event.reason }
end

local function request(session, command, args)
  local finished, result, fault
  session:request(command, args, function(err, response)
    fault, result, finished = err, response, true
  end)
  assert(vim.wait(8000, function() return finished end), "请求超时 " .. command)
  assert(not fault, vim.inspect(fault))
  return result
end

dap.run(config)
assert(vim.wait(12000, function() return #stops == 1 end), "未命中断点")
local first = stops[1]
assert(first.reason == "breakpoint")
local stack = request(first.session, "stackTrace", { threadId = 1 }).stackFrames
assert(#stack == 3 and stack[1].name == "add_one" and stack[1].line == 4)
assert(stack[2].name == "increment" and stack[3].name == "main")
assert(request(first.session, "evaluate", { frameId = stack[1].id, expression = "r0" }).result == "1")
assert(vim.wait(8000, function() return first.session.stopped_thread_id == 1 end))
dap.step_out()
assert(vim.wait(10000, function() return #stops == 2 end), "步出超时")
assert(stops[2].reason == "step")
local later = request(first.session, "stackTrace", { threadId = 1 }).stackFrames
assert(#later == 2 and later[1].name == "increment" and later[1].line == 3)
dap.disconnect()
assert(vim.wait(8000, function() return dap.session() == nil end), "会话关闭超时")
print("Neovim：ELF 源码断点、三层真实调用栈、寄存器求值和步出通过")
