
纸鸢
---

what for:
* provides a lightweight way to send system-wide notifications

status: experimental

prerequisites:
* linux with working notification-daemon like dunst
* libnotify
* [zig 0.10](https://ziglang.org/download)

setup:
* add it to your nvim plugin manager
* `$ zig build`

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
