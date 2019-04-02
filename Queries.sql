--
--           Задача 1 
--

SELECT departments.name, MAX(employees.salary) as salary
FROM departments
       JOIN employees
            ON employees.department_id = departments.id
GROUP BY departments.id;

--
--           Задача 2
--

SELECT employees.name
FROM employees
INNER JOIN employees as manager_salary
    ON employees.manager_id = manager_salary.id
WHERE employees.salary > manager_salary.salary;

--
--           Задача 3
--
--
--           Добавление контакта
--

INSERT INTO contacts (name, number, customer_id)
VALUES ('Михаил Алексеевич Дольный', 79781667652, 1);
INSERT INTO connect_groups_cont (contact_id, groups_id)
VALUES (500010, 10);
INSERT INTO email(address, contacts_id)
VALUES ('64637@gmail.com', 500010);
INSERT INTO viber(installed, contacts_id)
VALUES (0, 500010);
INSERT INTO whatsapp(installed, contacts_id)
VALUES (1, 500010);
INSERT INTO telegram(token, contacts_id)
VALUES (77728, 500010);

-- 
--           Изменения контакта
--

UPDATE contacts
SET number=7978000002
WHERE id = 500010;
UPDATE email
SET address='53432@gmail.com'
WHERE id = 500001;
UPDATE viber
SET installed=0
WHERE id = 500001;
UPDATE whatsapp
SET installed=1
WHERE id = 500001;
UPDATE telegram
SET token=14232
WHERE id = 500001;

--
--           Удаление контакта
--

DELETE
FROM contacts
WHERE id = 500010;

--
--           Добавление контакт в группу
--

INSERT INTO connect_groups_cont (contact_id, groups_id)
VALUES (500009, 4);

--
--           Изменения контакта в группе
--
UPDATE connect_groups_cont
SET groups_id=2
WHERE id = 1007405;

--
--           Удаление контакта из группы
--

DELETE
FROM connect_groups_cont
WHERE id = 1007405;

--
--           Вывод групп с подсчетом количества контактов.
--
-- по структуре БД можно произвести два запроса
-- первый запрос, учитывает условие, что каждая группа принадлежит 
-- отдельному клиенту, и как следствие указываем id данного клиента.
-- 
-- второй запрос выводит всю совокупность групп, всех клиентов.
--
--
SELECT customer.customer_name, `groups`.name_group,  COUNT(contacts.number) as count
FROM `groups`
       LEFT JOIN connect_groups_cont
                 ON `groups`.id = connect_groups_cont.groups_id
       LEFT JOIN contacts
                 ON contacts.id = connect_groups_cont.contact_id
       LEFT JOIN customer
                 ON `groups`.customer_id = customer.id
WHERE `groups`.customer_id = 1
GROUP BY `groups`.name_group;

--
-- по всей совокупности
--

SELECT `groups`.name_group,  COUNT(contacts.number) as count
FROM `groups`
            LEFT JOIN connect_groups_cont
                      ON `groups`.id = connect_groups_cont.groups_id
            LEFT JOIN contacts
                      ON contacts.id = connect_groups_cont.contact_id
GROUP BY `groups`.name_group;

--
-- По отдельной группе (ПРИМЕР)
-- с учетом id клиента
--

SELECT customer.customer_name, `groups`.name_group,  COUNT(contacts.number) as count
FROM `groups`
            LEFT JOIN connect_groups_cont
                      ON `groups`.id = connect_groups_cont.groups_id
            LEFT JOIN contacts
                      ON contacts.id = connect_groups_cont.contact_id
            LEFT JOIN customer
                      ON `groups`.customer_id = customer.id
WHERE `groups`.customer_id = 1
AND `groups`.name_group = 'Кафе Санкт-Петербург'
GROUP BY `groups`.name_group;

--           Вывод группы “Часто используемые”, где выводятся топ10 
-- контактов, на которые рассылают сообщения
-- учитывает условие, с учетом id клиента
--

SELECT customer.customer_name, contacts.number, contacts.volume
FROM `groups`
       LEFT JOIN connect_groups_cont
                 ON `groups`.id = connect_groups_cont.groups_id
       LEFT JOIN `contacts`
                 ON contacts.id = connect_groups_cont.contact_id
       LEFT JOIN customer
                 ON `groups`.customer_id = customer.id
WHERE `groups`.customer_id = 1
  AND `groups`.name_group = 'Часто используемые'
ORDER BY contacts.volume DESC
LIMIT 10;

--
--            Поиск контактов по ФИО/номеру.
--

SELECT contacts.id FROM contacts
WHERE name='Савинa Алиса Борисовна' AND number=74952705717;

--
--            Выборка контактов по группе.
--

SELECT customer.customer_name, contacts.number
FROM `groups`
       LEFT JOIN connect_groups_cont
                 ON `groups`.id = connect_groups_cont.groups_id
       LEFT JOIN contacts
                 ON contacts.id = connect_groups_cont.contact_id
       LEFT JOIN customer
                 ON `groups`.customer_id = customer.id
WHERE `groups`.name_group = 'Кафе Санкт-Петербург'

--
-- Примеры работы с использованием EXPLAIN
-- 


-- 		Таблица contacts
--
-- Вариант без использования составного индекса
--

mysql> EXPLAIN SELECT contacts.id FROM contacts
    -> WHERE name='Савинa Алиса Борисовна' AND number=74952705717;
+----+-------------+----------+------------+------+---------------+------+---------+------+--------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+--------+----------+-------------+
|  1 | SIMPLE      | contacts | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 496790 |     1.00 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+--------+----------+-------------+
1 row in set, 1 warning (0.01 sec)

-- Вариант с использованием составного индекса

mysql> EXPLAIN SELECT contacts.id FROM contacts     WHERE name='Савинa Алиса Борисовна' AND number=74952705717;
+----+-------------+----------+------------+------+---------------+-------------+---------+-------+------+----------+--------------------------+
| id | select_type | table    | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra                    |
+----+-------------+----------+------------+------+---------------+-------------+---------+-------+------+----------+--------------------------+
|  1 | SIMPLE      | contacts | NULL       | ref  | name_number   | name_number | 122     | const |    1 |    10.00 | Using where; Using index |
+----+-------------+----------+------------+------+---------------+-------------+---------+-------+------+----------+--------------------------+
1 row in set, 2 warnings (0.00 sec)


-- В основном заметно сильное сокращение количества проработанных строк, до 1.



-- Также целесообразно создать составной индекс для поиска в таблице groups,  
-- первым будет идти в ключе, значение customer_id т.к. их всего 5 вариаций, 
-- по сравнению с именем группы которое может быть уникально.

SELECT customer.customer_name, `groups`.name_group,  COUNT(contacts.number) as count
FROM `groups`
            LEFT JOIN connect_groups_cont
                      ON `groups`.id = connect_groups_cont.groups_id
            LEFT JOIN contacts
                      ON contacts.id = connect_groups_cont.contact_id
            LEFT JOIN customer
                      ON `groups`.customer_id = customer.id
WHERE `groups`.customer_id = 1
AND `groups`.name_group = 'Кафе Санкт-Петербург'
GROUP BY `groups`.name_group;

-- Вариант без использования составного индекса

+----+-------------+---------------------+------------+--------+-------------------------------+-----------------------+---------+------------------------------------------+------+----------+-------------+
| id | select_type | table               | partitions | type   | possible_keys                 | key                   | key_len | ref                                      | rows | filtered | Extra       |
+----+-------------+---------------------+------------+--------+-------------------------------+-----------------------+---------+------------------------------------------+------+----------+-------------+
|  1 | SIMPLE      | groups              | NULL       | ref    | groups_customer_id_fk         | groups_customer_id_fk | 4       | const                                    |   35 |    10.00 | Using where |
|  1 | SIMPLE      | connect_groups_cont | NULL       | ref    | relation_row_unique,groups_id | relation_row_unique   | 4       | DB_rarus3.groups.id                      | 2399 |   100.00 | Using index |
|  1 | SIMPLE      | contacts            | NULL       | eq_ref | PRIMARY                       | PRIMARY               | 4       | DB_rarus3.connect_groups_cont.contact_id |    1 |   100.00 | NULL        |
|  1 | SIMPLE      | customer            | NULL       | const  | PRIMARY                       | PRIMARY               | 4       | const                                    |    1 |   100.00 | NULL        |
+----+-------------+---------------------+------------+--------+-------------------------------+-----------------------+---------+------------------------------------------+------+----------+-------------+
4 rows in set, 1 warning (0.00 sec)

-- Вариант с использованием составного индекса

+----+-------------+---------------------+------------+--------+-----------------------------------------------------------+-------------------------------------+---------+------------------------------------------+------+----------+-------------+
| id | select_type | table               | partitions | type   | possible_keys                                             | key                                 | key_len | ref                                      | rows | filtered | Extra       |
+----+-------------+---------------------+------------+--------+-----------------------------------------------------------+-------------------------------------+---------+------------------------------------------+------+----------+-------------+
|  1 | SIMPLE      | groups              | NULL       | ref    | groups_customer_id_fk,groups_customer_id_name_group_index | groups_customer_id_name_group_index | 126     | const,const                              |    1 |   100.00 | Using index |
|  1 | SIMPLE      | connect_groups_cont | NULL       | ref    | relation_row_unique,groups_id                             | relation_row_unique                 | 4       | DB_rarus3.groups.id                      | 2399 |   100.00 | Using index |
|  1 | SIMPLE      | contacts            | NULL       | eq_ref | PRIMARY                                                   | PRIMARY                             | 4       | DB_rarus3.connect_groups_cont.contact_id |    1 |   100.00 | NULL        |
|  1 | SIMPLE      | customer            | NULL       | const  | PRIMARY                                                   | PRIMARY                             | 4       | const                                    |    1 |   100.00 | NULL        |
+----+-------------+---------------------+------------+--------+-----------------------------------------------------------+-------------------------------------+---------+------------------------------------------+------+----------+-------------+
4 rows in set, 1 warning (0.00 sec)

-- так же сокращенно количество обрабатываемых строк.





