when HTTP_REQUEST {
    local host = HTTP:host()

    if host == "delivery.lab.local" then
        HTTP:setpriv("delivery_l6")
    end
}

when HTTP_RESPONSE {
    if HTTP:priv() == "delivery_l6" then
        HTTP:add_header("X-Lesson6-Lua", "active")
    end
}
