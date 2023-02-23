@isTest
public class TaskTriggerHelperTest {
  public static List<Task> createTasks(
    List<Account> accounts,
    String taskType,
    Integer numOfTasks
  ) {
    List<Task> tasks = new List<Task>();
    for (Account acc : accounts) {
      for (Integer i = 0; i < numOfTasks; i++) {
        Task newTask = new Task(Type = taskType, WhatId = acc.id);
        tasks.add(newTask);
      }
    }
    insert tasks;
    return tasks;
  }

  public static List<Task> createTasksOnSingleAccount(
    Account account,
    String taskType,
    Integer numOfTasks
  ) {
    List<Task> tasks = new List<Task>();
    for (Integer i = 0; i < numOfTasks; i++) {
      Task newTask = new Task(Type = taskType, WhatId = account.id);
      tasks.add(newTask);
    }
    insert tasks;
    return tasks;
  }
}
