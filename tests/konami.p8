pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

function konami()
    print 'konami'
    stop()
end

function bad()
    print 'bad'
    stop()
end

moves = {
    {
        sequence = { 4, 4, 8, 8, 1, 2, 1, 2, 32, 16 },
        position = 1,
        action = konami
    },
    {
        sequence = { 8, 8, 1 },
        position = 1,
        action = bad
    }
}

dt = 0

function _update60()
    cls()
    if dt > 0 then
        dt -= 1
        if dt == 0 then
            for move in all(moves) do
               move.position = 1
            end
        end
    end
    local b = btnp()
    if b > 0 then
        print(b, 0, 0)
        for move in all(moves) do
            local state_ok = move.position > 1 or (move.position == 1 and dt == 0)
            local btn_ok = b & move.sequence[move.position] > 0
            if state_ok and btn_ok then
                dt = 60
                if move.position == #move.sequence then
                    move.action()
                else
                    move.position += 1
                end
            else
                move.position = 1
            end
        end
    end
    print(dt, 10, 0)
end

