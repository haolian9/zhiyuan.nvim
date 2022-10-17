
纸鸢
---

what for:
* provides a lightweight way to send system-wide notifications

status: experimental

supported capatibilities:
* body
* icon
* timeout
* urgency

prerequisites: (i just tested it with these envs)
* linux with a working notification-daemon like dunst
* libnotify 0.8.1
* [zig 0.10](https://ziglang.org/download)
* neovim 0.8.0

setup:
* add it to your nvim plugin manager
* `$ zig build -Drelease-safe`

use:
* standalone use: `require'zhiyuan'.notify('hello', 'world')`
* or let it take over the `vim.notify`

```
vim.notify = function(msg)
    require'zhiyuan'.notify('nvim', msg)
end
```

---

thanks to:
* https://github.com/evan-goode/batnotifyd # i learnt the necessary usages of libnotify from it
