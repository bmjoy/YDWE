local sleep = require 'ffi.sleep'

local function task(f, ...)
    for i = 1, 99 do
        if pcall(f, ...) then
            return true
        end
        sleep(10)
    end
    return false
end

local function scan_dir(dir, callback)
    for path in dir:list_directory() do
        if fs.is_directory(path) then
            scan_dir(path, callback)
        else
            callback(path)
        end
    end
end

local mt = {}
mt.__index = mt

function mt:save(path, dirs)
    return true
end

function mt:close()
end

function mt:count_files()
    local count = 0
    for _, name in ipairs {'map', 'resource', 'script', 'sound', 'trigger'} do
        scan_dir(self.path / name, function ()
            count = count + 1
        end)
    end
    return count
end

function mt:extract(name, path)
    return fs.copy_file(self.path / name, path, true)
end

function mt:has_file(name)
    return fs.exists(self.path / name)
end

function mt:remove_file(name)
    fs.remove(self.path / name)
end

function mt:load_file(name)
    local f = io.open((self.path / name):string(), 'rb')
    if not f then
        return nil
    end
    local buf = f:read 'a'
    f:close()
    return buf
end

function mt:save_file(name, buf, filetime)
    local dir = name:match '^([^/\\]+)[/\\]'
    if dir then
        dir = dir:lower()
        if not self.cleaned[dir] then
            self.cleaned[dir] = true
            if not task(fs.remove_all, self.path / dir) then
                error(('无法清空目录[%s]，请检查目录是否被占用。'):format((self.path / dir):string()))
            end
        end
    end
    local dir = (self.path / name):remove_filename()
    if not fs.exists(dir) then
        fs.create_directories(dir)
    end
    io.save(self.path / name, buf)
    return true
end

return function (input)
    return setmetatable({ path = input, cleaned = {} }, mt)
end
