pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

printh("=====")

gif=false
extcmd("rec")

text="fourscore and seven years ago our fathers brought forth, on this continent, a new nation, conceived in liberty, and dedicated to the proposition that all men are created equal. now we are engaged in a great civil war, testing whether that nation, or any nation so conceived, and so dedicated, can long endure. we are met on a great battle-field of that war. we have come to dedicate a portion of that field, as a final resting-place for those who here gave their lives, that that nation might live. it is altogether fitting and proper that we should do this. but, in a larger sense, we cannot dedicate, we cannot consecrate - we cannot hallow - this ground. the brave men, living and dead, who struggled here, have consecrated it far above our poor power to add or detract. the world will little note, nor long remember what we say here, but it can never forget what they did here. it is for us the living, rather, to be dedicated here to the unfinished work which they who fought here have thus far so nobly advanced. it is rather for us to be here dedicated to the great task remaining before us - that from these honored dead we take increased devotion to that cause for which they here gave the last full measure of devotion - that we here highly resolve that these dead shall not have died in vain - that this nation, under god, shall have a new birth of freedom, and that government of the people, by the people, for the people, shall not perish from the earth."

wpm=250

function render_word(words,x1,x2,y)
    local x=(x2-x1+1)\2-2

    local text=words[word]
    if word<#words then
        if words[word+1]=="-" then
            text=text.." - "
            word+=1
        end
    end

    local len=#text
    local last=text[len]

    local punctuation={{",",1},{"$",1},{";",2},{":",2},{".",3}}
    local col={"\f7","\f9"}

    pause=0
    for v in all(punctuation) do
        if last==v[1] then pause=interval*v[2] end
    end

    local ranges={1,5,9,13}
    char=5
    for k,v in ipairs(ranges) do
        if len <= v then char=k break end
    end

    if len==1 then
        chars={"",text,""}
    else
        chars={sub(text,1,char-1),text[char],sub(text,char+1)}
    end

    x-=#chars[1]*4

    local display=col[1]..chars[1]..col[2]..chars[2]..col[1]..chars[3]

    return {display,x,y}
end

function reset()
    extcmd("rec")
    word=1
    pause=0
    current=render_word(words,0,127,64)
end

function _init()
    words=split(text," ")
    interval=60/wpm
    previous=time()
    reset()
end

function _update60()
    if btn(⬆️) then wpm+=1 interval=60/wpm end
    if btn(⬇️) then wpm-=1 interval=60/wpm end
    if btn(🅾️) then reset() end

    -- if time()>15.9 and gif==false then gif=true extcmd("video") end

    if time()-previous<interval+pause then return end
    previous=time()
    word+=1
    if word>#words then word=#words return end
    current=render_word(words,0,127,64)
end

function _draw()
    cls()
    print(unpack(current))
    print("\f2wpm \f3"..wpm.." \f1⬆️⬇️ \f2 reset text \f1🅾️",0,0)
end
