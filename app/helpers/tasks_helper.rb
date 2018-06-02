module TasksHelper
  def tr_for_task(task, &block)
    class_val =
      case task.task_status_id
      when Constants::TaskStatuses::WORK then nil
      when Constants::TaskStatuses::DONE then 'success'
      when Constants::TaskStatuses::CANCEL then 'error'
      else nil
      end
    content_tag(:tr, class: class_val, &block)
  end
end
