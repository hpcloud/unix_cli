require 'thor/base'

class Thor 
  class << self
    
    # Prints help information for the given task.
    #
    # ==== Parameters
    # shell<Thor::Shell>
    # task_name<String>
    #
    def task_help(shell, task_name)
      meth = normalize_task_name(task_name)
      task = all_tasks[meth]
      handle_no_task_error(meth) unless task

      shell.say "Usage:"
      shell.say "  #{banner(task)}"
      shell.say
      class_options_help(shell, nil => task.options.map { |_, o| o })
      if task.long_description
        shell.say "Description:"
        shell.say task.long_description
      # elsif nil and task.long_description
      #   shell.say "Description:"
      #   shell.print_wrapped(task.long_description, :ident => 2)
      else
        shell.say task.description
      end
    end
    
  end
end
