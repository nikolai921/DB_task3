            Задача 1 

SELECT departments.name, MAX(employees.salary) as salary
FROM departments
       JOIN employees
            ON employees.department_id = departments.id
GROUP BY departments.id;

            Задача 2

SELECT employees.name
FROM employees
INNER JOIN employees as manager_salary
    ON employees.manager_id = manager_salary.id
WHERE employees.salary > manager_salary.salary;

            Задача 3

            Добавление контакта

INSERT INTO contacts (name, number, contact_db_id)
VALUES ('Михаил Алексеевич Дольный', 79781667652, 1);
INSERT INTO connect_group_cont (contact_id, group_id)
VALUES (10, 2);

            Изменения контакта

UPDATE contacts
SET number=7978000002
WHERE id = 100001;

            Удаление контакта

DELETE
FROM contacts
WHERE id = 100001;

            Добавление контакт в группу

INSERT INTO connect_group_cont (contact_id, group_id)
VALUES (1, 4);

            Изменения контакта в группе

UPDATE connect_group_cont
SET group_id=2
WHERE id = 5;

При условии что id не известен (ПРИМЕР)

UPDATE connect_group_cont
SET group_id=2
WHERE contact_id = 3
  AND group_id = 3;

            Удаление контакта из группы

DELETE
FROM connect_group_cont
WHERE id = 6;

При условии что id не известен(ПРИМЕР)

DELETE
FROM connect_group_cont
WHERE group_id = 2
  AND contact_id = 8;

            Вывод групп с подсчетом количества контактов.

SELECT `group`.name, COUNT(contacts.number) as count FROM `group`
LEFT JOIN connect_group_cont 
    ON `group`.id = connect_group_cont.group_id
LEFT JOIN contacts 
    ON contacts.id = connect_group_cont.contact_id
GROUP BY `group`.name;

По отдельной группе (ПРИМЕР)

SELECT `group`.name, COUNT(contacts.number) as count
FROM `group`
       LEFT JOIN connect_group_cont 
        ON `group`.id = connect_group_cont.group_id
       LEFT JOIN contacts 
        ON contacts.id = connect_group_cont.contact_id
GROUP BY `group`.name
HAVING `group`.name = 'Владивосток';


            Вывод группы “Часто используемые”, где выводятся топ10 контактов, на которые рассылают сообщения

SELECT contacts.number, contacts.volume
FROM `group`
       LEFT JOIN connect_group_cont 
        ON `group`.id = connect_group_cont.group_id
       LEFT JOIN `contacts` 
        ON contacts.id = connect_group_cont.contact_id
WHERE `group`.name = 'Часто используемые'
ORDER BY contacts.volume DESC
LIMIT 3;

            Поиск контактов по ФИО/номеру.

SELECT id FROM contacts 
WHERE name='Игнатьевa Анастасия Альбертовна' AND number=78059801795;

            Выборка контактов по группе.

SELECT contacts.number FROM `group`
LEFT JOIN connect_group_cont 
    ON `group`.id = connect_group_cont.group_id
LEFT JOIN contacts 
    ON contacts.id = connect_group_cont.contact_id
WHERE `group`.name='Москва'
