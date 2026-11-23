local dap = require("dap")
local function required_env(name)
  return assert(vim.env[name], "请设置 " .. name)
end

vim.filetype.add({ extension = { bpf = "moon_dap_bpflab" } })
dap.adapters.moon_bpf = {
  type = "executable",
  command = required_env("MOON_DAP_BPF_ADAPTER"),
}
local config = {
  type = "moon_bpf",
  request = "launch",
  name = "调试 ELF 嵌套调用",
  program = required_env("MOON_DAP_BPF_PROGRAM"),
  programFormat = "elf",
  sourceMap = required_env("MOON_DAP_BPF_SOURCE_MAP"),
}
dap.configurations.moon_dap_bpflab = { config }
return config
