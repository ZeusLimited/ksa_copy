def load_task_status
  TaskStatus.delete_all
  TaskStatus.create(id: 1, name: 'В работе')
  TaskStatus.create(id: 2, name: 'Выполнено')
  TaskStatus.create(id: 3, name: 'Отклонено')

  change_sequence('TASK_STATUSES_SEQ', 5)
end