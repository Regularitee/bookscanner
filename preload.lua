local MOD = {
    id = "add_ebook",
    reading_book = nil
}

function parse_ebooks(str)
    return load("return {" .. str .. "}")()
end

function stringify_ebooks(t)
    local str = ""
    for _, v in pairs(t) do
        if str == "" then
            str = '"' .. v .. '"'
        else
            str = str .. ',"' .. v .. '"'
        end
    end

    return str
end

function iuse_ebook_scan_book(it, active)
    local cons = 10
    local time = -1000
    local ebooks = parse_ebooks(it:get_var("ebooks", ""))
    local books = {}
    local new_book = nil
    local um
    local menu_num = 0
    local item_num = 0
    local real_inv_num = player:get_item_position(it)
    if not player:has_amount("ebook_scanner", 1) then
        game.popup("You lack an e-book scanner！")
        return 0
    end
    if it:ammo_remaining() < cons then
        game.popup("There's nothing inside there to scan!")
        return 0
    end

    um = game.create_uimenu()
    um.title = "Choose a book to scan"
    local tmp = player:i_at(item_num)
    while tmp:is_null() ~= true do
        tmp = player:i_at(item_num)
        if tmp:is_book() then
            local new = true
            -- Check ebook is already scanned
            for _, v in pairs(ebooks) do
                if v == tmp:typeId() then
                    new = false
                end
            end
            if new then
                table.insert(books, tmp:typeId())
                um:addentry(tmp:display_name())
                menu_num = menu_num + 1
            end
        end
        item_num = item_num + 1
    end
    um:addentry("Cancel")
    um:query(true)
    if um.selected == menu_num or um.selected < 0 then
        return 0
    end
    new_book = books[um.selected + 1]
    table.insert(ebooks, new_book)
    player:i_at(real_inv_num):set_var("ebooks", stringify_ebooks(ebooks))
    game.add_msg("The book has finished scanning.")
    player:mod_moves(time)

    player:consume_charges(it, cons)
    return cons
end

function iuse_ebook_craft(it, active)
    local cons = 0
    local ebooks = parse_ebooks(it:get_var("ebooks"))
    local tmp_list = {}
    -- Check lastrecipe
    local lastrecipe = player.lastrecipe
    local last_batch = player.last_batch
    -- Add tmporary dummy books
    for _, v in pairs(ebooks) do
        local tmp = item(v, -1)
        table.insert(tmp_list, player:i_add(tmp))
    end
    -- Show craft menu
    player:invalidate_crafting_inventory()
    player:craft()
    -- Remove tmporary dummy books
    for _, v in pairs(tmp_list) do
        player:i_rem(v)
    end
    -- Consume if lastrecipe differs
    if lastrecipe ~= player.lastrecipe and last_batch ~= player.last_batch then
        cons = it:ammo_required()
    end

    player:consume_charges(it, cons)
    return cons
end

function ebook_list_menu(it)
    local ebooks = parse_ebooks(it:get_var("ebooks", ""))
    local books = {}
    local um
    local menu_num = 0
    um = game.create_uimenu()
    um.title = "List"
    for _, v in pairs(ebooks) do
        local tmp = item(v, -1)
        table.insert(books, tmp:typeId())
        um:addentry(tmp:display_name())
        menu_num = menu_num + 1
    end
    um:addentry("Cancel")
    um:query(true)
    if um.selected == menu_num or um.selected < 0 then
        return nil
    end
    return books[um.selected + 1]
end

function iuse_ebook_list(it, active)
    ebook_list_menu(it)
    return 0
end

function on_preload()
    game.register_iuse("IUSE_EBOOK_SCAN_BOOK", iuse_ebook_scan_book)
    game.register_iuse("IUSE_EBOOK_CRAFT", iuse_ebook_craft)
    game.register_iuse("IUSE_EBOOK_LIST", iuse_ebook_list)
end

on_preload()
