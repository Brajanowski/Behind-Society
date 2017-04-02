Tasks = {}

-- Call this function only on changing day, not every frame
Tasks.Update = function() 
  for i = 0, Game.Data.GetHackersNumber() - 1 do
    local hacker = Game.Data.GetHacker(i)
    
    if hacker.computer >= 0 then
      if hacker.task >= 0 then
        local task = Game.Data.GetTask(hacker.task)
        if task.type == 0 or task.type == 2 then
          local computer = Game.Data.GetComputer(hacker.computer)
          local points = math.floor((Gameplay.GetComputingPower(computer) / 10) * hacker.cracking)
          DayLog.points = DayLog.points + points

          task.points = task.points + points

          hacker.experience = hacker.experience + points
          Gameplay.HackerLevelUp(i)

          if task.points >= task.points_to_finish then
            Tasks.TaskDone(hacker.task)
          end
        end
      elseif hacker.task == -2 then
        local computer = Game.Data.GetComputer(hacker.computer)
        local points = math.floor((Gameplay.GetComputingPower(computer) / 10) * hacker.security)
        DayLog.points = DayLog.points + points

        hacker.experience = hacker.experience + points
        Gameplay.HackerLevelUp(i)

        Game.Data.security = Game.Data.security + points
      end
    end
  end

  -- update all tasks
  local task_number = Game.Data.GetTaskNumber() - 1
  for i = 0, Game.Data.GetTaskNumber() - 1 do
    local task = Game.Data.GetTask(i)

    if task.days_to_finish ~= -1 then
      task.days_to_finish = task.days_to_finish - 1
      if task.days_to_finish == 0 then
        GameEvents.TaskFinished(task, false)
        -- delete this task
        Gameplay.UnassignHackersFromTask(taskid)
        Game.Data.RemoveTask(i)
        Gameplay.TaskRemoved(i)
        task_number = task_number - 1
      end
    end
  end
end

Tasks.Remove = function(id)
  
  
end

Tasks.TaskDone = function(taskid)
  local task = Game.Data.GetTask(taskid)

  if task.reward > 0 then
    Game.Data.money = Game.Data.money + task.reward
    Console.Log("You got " .. task.reward .. "$ for finishing task named: " ..
                task.name)
  end

  if task.company_id >= 0 then
    local company = Game.Data.GetCompany(task.company_id)
    local fans_to_change = 50 - company.people_love

    if fans_to_change > 0 then
      local fans_number = math.ceil(company.popularity * (fans_to_change / 100))

      Game.Data.fans = Game.Data.fans + fans_number
      Console.Log("You have earned " .. fans_number .. " fans.") 
    elseif fans_to_change < 0 then
      local fans_number = math.ceil(company.popularity * (-fans_to_change / 100))
      
      if Game.Data.fans - fans_number > 1 then
        Game.Data.fans = Game.Data.fans - fans_number
        Console.Log("You have lost " .. fans_number .. " fans.")
      else
        Game.Data.fans = 1
        Console.Log("You lost all of your fans (expect your mom).")
      end
    end
    Companies.Hacked(Game.Data.GetTask(taskid).company_id)
  end

  GameEvents.TaskFinished(task, true)
  Gameplay.UnassignHackersFromTask(taskid)
  Game.Data.RemoveTask(taskid)
end
