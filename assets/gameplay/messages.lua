Messages = {}
Messages.msg = {}

Messages.Add = function(avatarid, from, title, content, replies)
  Messages.msg[#Messages.msg + 1] = {
    ["avatarid"] = avatarid,
    ["from"]     = from,
    ["title"]    = title,
    ["content"]  = content,
    ["replies"]  = replies
  }
end

Messages.Clear = function()
  for i = 1, #Messages.msg do
    Messages.msg[i] = nil
  end
end

