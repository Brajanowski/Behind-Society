GameEvents = {}

-- mom story
GameEvents.mom_leave = 
[[Hello my Son!
Unfortunately I have to leave and I don't know when I will be back. I don't feel very well...
My friend, Jessica will check you everyday, just be kind to her. I hope you can handle all of this. I sent some money for you.

Big love for you.]]

GameEvents.birthday_wishes = 
[[Happy birthday, my Son!
May happiness surround you today and all your wishes come true!

Unfortunately I can't come visit. I am going through some tough times but I will always love you.

PS: I sent a little gift for you, it's not much but it's all I have.]]

GameEvents.mommy_cancer =
[[Hey son, I'm really really sick but you probably you already figured it out.
I don't have much time left the doctor said I have only a couple weeks remaining.
Even though you don't visit anymore I know you still love me. Goodbye my Son.

I love you my little boy.]]

GameEvents.treatment_money =
[[Good morning my son.
How are you? I hope you haven't had any problems. I'm really sorry, but I can leave this world soon.
I have cancer progression. The doctors say that if I don't start going to chemotherapy I will have only 15 days left. I guess this will be my last message, unless some miracle will happen.
 
I love you my son.]]

GameEvents.mommy_successfully =
[[Son!

Thanks to chemotherapy sponsored by you I have won the battle with cancer. I don't know what to say, I am so gratefull. I have to end this message, the doctors say I need to rest now.

See you soon!]]

GameEvents.mommy_death =
[[Good morning,

Unfortunately I've got bad news. Your mother has died today on 13:37. She came to us in a terrible condition. We still don't know the cause of her death, but we suspect she died from cancer.

My condolences.]]

-- mr edward story
GameEvents.mredward_harddrive =
[[Hello!
Listen I need your help quick. I forgot about one last hard-drive to decode.
I need it done ASAP, of course I will pay top dollar for your work. How much? What about $10?]]

GameEvents.mredward_company_info =
[[Hey,

Have you heard about that new company that works with the goverment? They don't even have a name, but what they're trying to do is just terrifying. 
Exactly 113 days from now they want to completely change the internet. They will have complete control over what we are watching, who we are talking 
to, who we are typing to, what we are typing about and what we are doing on the internet. They will be no anonimity left, even encryption wont help.

Not much people know about this. But one thing is sure, this isn't good.]]

-- random jobs
GameEvents.matthias =
[[Hi, I'm Matthias, I've heard you are good with computers. There are way too many toolbars on my browser.
Can you delete them? I can pay $2 for that, because it's an easy job for you. love ya <3]]

GameEvents.eddy =
[[Hey dude. I got this wierd problem on my... I mean my friends computer. He accidently clicked on some wierd ad with umm.. with a certain proposition. And know he has these pop-ups when he goes on the internet. Oh and could you also delete my umm... his browser history? I hope I can count on your discretion, please...]]

GameEvents.rapper0 =
[[Hey dude, I heard that you know your stuff when it comes to those metal boxes sitting under our desks. You know the ones with flashing lights and other gizmos... computronics, 
I think that's what they're called. Well, I have a job for you. If you can do it, I'll send a few bucks your way. So you know... just say the word and I'll fill you in on the the details.
Peace out.]]

GameEvents.rapper1 = 
[[Yo, its me again. I see that you're interested in making some cash, but remember ... if the 5-0 comes, you say you know nothing like Socrates. Even though the risk is high, it will be worth it. The pay out will be good.

So I want to make the album of the year, but I don't have any fire beats. You following me? A rapper without beats is like an accountant without receipts, yo. Ok, moving on, there's this DJ SwagLord. He makes killer beats, but he doesn't share them. He keeps them on his server. Now you're wondering what are you supposed to do? Steak them. Trust me, it will be worth it.

P.S. Remember it doesn't mean anything, it doesn't prove anything.
]]

GameEvents.rapper2 = 
[[Yo, thanks for the sick beats my man. My record is there in the air, but there is one problem... nobody knows about it. I bet it's all because of those stupid music ranking 
algorythms on the internet, they don't know what's good. Just do your magic and fix those rankings for me. Oh I'll pay you later with a little bonus for your wait, 
because you know... I'm between albums. 

Peace.]]

GameEvents.rapper3 =
[[Woah dude, you got a little carried away with thos rankings... I won two awards for that record. Man, I knew my stuff was lit. As promised, you get what you deserve plus a little extra 
for your wait. Now I'm heading off to a party. I'll talk to you when I'll be recording something, because you know... I got the fire lyrics and you got those smarts. 

May the rap gods be with you. Peace.]]

GameEvents.spoiler_man =
[[Hey... psstt... has someone ever screwed your day up? Of course, it happens to all of us, but have you ever thought about getting back at them? For sure you have, hahaha... So i've got an idea, you just need to do what I say and you will get some profit for doing something evil ahahaha.... The final season for this popular series is comming out soon, and I want you to break into their private servers, watch all the episodes and post the ending online, it's pure evil!!! I'll be checking on the internet for the leaks, if you do the job you will get your pay!]]

GameEvents.bomberman =
[[Help!
I woke up today with some explosives attached to me, time is ticking away and I only have 47 hours left... please help me ... I've got a note with some website addres. I'll send you a pic of the note in the attachments, maybe it's some kind of clue, please help me, get me the deactivation code.
Help!]]

GameEvents.pizza_pepperoni =
[[Buon giorno!
Mamma mia! I've got uno grande problem with someone who calls himself Italiano. He opened a few pizzerias a couple streets away from me-a and he stole my customers! They are eating orrendo pizzas with none of my italiano passion. Can you do something with that? I can't deal with this anymore. You can cancel his order of formaggio for this week. That may work.]]

GameEvents.memester = 
[[Welcome my memester friend,yesterday someone hacked my computer and stole all my dank memes that I wanted to post today! Can you find that asshole and retrieve my memes? Please! Those memes are my lifes work!]]

-- Call this function every new day
GameEvents.Update = function()
  -- mom story
  if Game.Data.day == 3 then -- mom leave
    Messages.Add("mom", "Mom", "I have to leave.", GameEvents.mom_leave,
             {
               yes = {
                 msg = "So be it.",
                 func = nil
               },

               no = nil
             }
             )
    Game.Data.money = Game.Data.money + math.random(12, 16)
  elseif Game.Data.day == 8 then -- birthday
    local hacker = Game.Data.GetHacker(0)
    hacker.age = 18
    local gift = math.random(10, 20)

    Game.Data.money = Game.Data.money + gift

    Messages.Add("mom", "Mom", "Happy birthday!", GameEvents.birthday_wishes,
                 {
                   yes = {
                     msg = "Thanks!",
                     func = nil
                   },

                   no = nil
                 }
  )

  elseif Game.Data.day == 31 then -- mom's cancer
    Messages.Add("mom", "Mom", "Disease", GameEvents.mommy_cancer)
  elseif Game.Data.day == 69 then -- treatment
    Messages.Add("mom", "Mom", "Treatment", GameEvents.treatment_money,
                 {
                   yes = {
                      msg = "I'm gonna help you.",
                      func = function() 
                        local task = Game.Task()
                        task.name = "Money for a treatment"
                        task.money = 1000
                        task.type = 1
                        task.days_to_finish = 14
                        Game.Data.PushTask(task)
                      end
                   },

                   no = {
                      msg = "Who cares?",
                      func = nil
                   }
                 }
    )
  elseif Game.Data.day == 84 then
    if Game.Data.GetQuestVariable("mom_treatment") == 1 then
      Messages.Add("mom", "Mom", "Good news", GameEvents.mommy_successfully,
               {
                 yes = {
                   msg = "And this is good news",
                   func = nil
                 },

                 no = nil
               }
               )
    else
      Messages.Add(-1, "Dr. Shree", "Bad news", GameEvents.mommy_death, nil)   
    end
  end

  -- mr edward
  if Game.Data.day == 3 then
    Messages.Add(
      "mr_edward", 
      "Mr Edward", 
      "I need your help.", 
      GameEvents.mredward_harddrive,
      {
        yes = {
          msg = "Yea, I can do that.",
          func = function()
            local task = Game.Task()
            task.name = "Decoding hard-drive for Mr Edward"
            task.type = 2
            task.points = 0
            task.points_to_finish = 2
            task.reward = 10
            Game.Data.PushTask(task)
          end
        },
        no = {
          msg = "Sorry, maybe next time.",
          func = function() end
        }
      }         
    )
  elseif Game.Data.day == 15 then
    Messages.Add(
      "mr_edward", 
      "Mr Edward", 
      "Bad news", 
      GameEvents.mredward_company_info,
      nil       
    )

    local company = Game.Company("Mysterious Company")
    company.popularity = 0
    company.people_love = 50
    company.security = 1410
    company.type = CompanyType.Story
    Gameplay.PushFrontCompany(company)
  end

  -- random work
  if Game.Data.day == 2 then
    Messages.Add(
      -1, 
      "Eddy", 
      "Weird computer virus.", 
      GameEvents.eddy,
      {
        yes = {
          msg = "Yeah sure, for a price.",
          func = function()
            local task = Game.Task()
            task.name = "Weird computer virus."
            task.points = 0
            task.points_to_finish = 3
            task.type = 2
            task.reward = math.random(8, 12)
            Game.Data.PushTask(task)
          end
        },
        no = {
          msg = "No way man, disgusting.",
          func = function() end
        }
      }         
    )
  end

  if Game.Data.day == 15 then
    Messages.Add(
      "rapper",
      "McRapper", 
      "Yo man", 
      GameEvents.rapper0,
      {
        yes = {
          msg = "Okay?",
          func = function()
            Game.Data.SetQuestVariable("rapper", 1)
          end
        },
        no = {
          msg = "No way man.",
          func = function() end
        }
      }         
    )
  elseif Game.Data.day == 21 then
    Messages.Add(
      -1,
      "Spoiler", 
      "---", 
      GameEvents.spoiler_man,
      {
        yes = {
          msg = "Yea, let's do this.",
          func = function()
            local task = Game.Task()
            task.name = "Spoilers."
            task.points = 0
            task.points_to_finish = 10
            task.type = 2
            task.reward = math.random(24, 48)
            Game.Data.PushTask(task)
          end
        },
        no = {
          msg = "No way man.",
          func = function() end
        }
      }         
    )
  elseif Game.Data.day == 29 then
    Messages.Add(
      -1,
      "Bomberman", 
      "HELP", 
      GameEvents.bomberman,
      {
        yes = {
          msg = "Don't worry.",
          func = function()
            local task = Game.Task()
            task.name = "Bomb code"
            task.points = 0
            task.points_to_finish = 16
            task.days_to_quit = 2
            task.type = 2
            task.reward = math.random(75, 99)
            Game.Data.PushTask(task)
          end
        },
        no = {
          msg = "Nice prank, br0",
          func = function() end
        }
      }         
    )
  end

  if Game.Data.GetQuestVariable("rapper") >= 1 then
    if Game.Data.day == 17 then
      Messages.Add(
        "rapper", 
        "McRapper", 
        "Yo man", 
        GameEvents.rapper1,
        {
          yes = {
            msg = "Got it",
            func = function()
              local task = Game.Task()
              task.name = "Sick beats."
              task.points = 0
              task.points_to_finish = 8
              task.type = 2
              task.reward = 0
              Game.Data.PushTask(task)
            end
          },
          no = nil
        }         
      )
    elseif Game.Data.GetQuestVariable("rapper") == 2 and Game.Data.day > 20 then
      Game.Data.SetQuestVariable("rapper", 3)
      Messages.Add(
        "rapper", 
        "McRapper", 
        "Rankings...", 
        GameEvents.rapper2,
        {
          yes = {
            msg = "Got it",
            func = function()
              local task = Game.Task()
              task.name = "Rankings."
              task.points = 0
              task.points_to_finish = 8
              task.type = 2
              task.reward = 0
              Game.Data.PushTask(task)
            end
          },
          no = nil
        }         
      )  
    elseif Game.Data.day == Game.Data.GetQuestVariable("rapper") then
      Messages.Add(
        "rapper", 
        "McRapper", 
        "Thanks", 
        GameEvents.rapper3,
        {
          yes = {
            msg = "Got it",
            func = function()
              Game.Data.money = Game.Data.money + math.random(125, 155)
            end
          },
          no = nil
        }         
      )  
    end
  end

  if Game.Data.fans >= 69 then
    if Game.Data.GetQuestVariable("popularity_info") == -1 then
      Hud.AddNotification("Popularity", Game.Data.group_name .. " is gaining in popularity. Other groups can begin to get interested in security of your servers. Be carefull." , "OK")
      Game.Data.SetQuestVariable("popularity_info", 1)
    end
  end

  if Game.Data.GetQuestVariable("popularity_info") == 1 then
    local is_attacking = false

    if math.random(0, 100) > 50 then
      is_attacking = true
    end

    if is_attacking == true then
      local points = 0

      if Game.Data.security > 50 then
        points = math.random(math.floor(Game.Data.security * 0.35), math.floor(Game.Data.security * 0.55))
      elseif Game.Data.security > 15 then
        points = math.random(6, 12)
      else
        points = math.random(1, 3)
      end

      Game.Data.security = Game.Data.security - points
    end
  end

  -- rent
  if Game.Data.day == 17 and Game.Data.current_abode == 0 then
    local new_rent = math.random(13, 18)
    Game.Data.rent = new_rent
    Messages.Add(-1, "Landlord", "Rent", "I see you're doing well. So I'm gonna to increase your rent, you won't live here for free. So It's gonna be $" .. new_rent .. " per week.", {
        yes = { msg = "You piece of shit!", nil}})
  end

  -- game over stuff
  if Game.Data.day == 128 and Game.Data.GetQuestVariable("main_company_hacked") == 0 then
    Gameplay.Gameover()
  end

  if Game.Data.security < 0 then
    Gameplay.Gameover("Someone hacked you.")
  end
end

GameEvents.TaskFinished = function(task, successfully)
  if successfully then
    if task.name == "Money for a treatment" then
      Game.Data.SetQuestVariable("mom_treatment", 1)
    elseif task.name == "Hacking Mysterious Company" then
      Gameplay.WinGame()
    elseif task.name == "Sick beats." then
      Game.Data.SetQuestVariable("rapper", 2)
    elseif task.name == "Rankings." then
      Game.Data.SetQuestVariable("rapper", Game.Data.day + math.random(3, 6))
    end
  end
end

