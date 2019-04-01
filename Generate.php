<?php

$link = mysqli_connect('localhost', 'root', '13579', 'DB_rarus3');


$domen = [
    '@mail.ru',
    '@yandex.ru',
    '@rambler.ru',
    '@gmail.com',
    '@yahoo.com',
    '@worker.com',
    '@job.com',
    '@company.com'
];


for($i = 1;$i < 35; $i++)
{
//    $body = mt_rand(0,9) . mt_rand(0,9) .mt_rand(1,9) . mt_rand(1,9) . mt_rand(1,9) . mt_rand(1,9);
//    $string = $body . $domen[mt_rand(0,7)];


//    $insert = "UPDATE contacts SET email='$string' WHERE id='$i'";
//    $result = mysqli_query($link, $insert) or die(mysqli_error($link));

      $insert = "UPDATE contacts SET group_i=1 WHERE id='$i'";
      $result = mysqli_query($link, $insert) or die(mysqli_error($link));

}

//for($i = 1;$i < 20000; $i++)
//{
//    $contact = rand(1,100000);
//    $group = rand(1,35);
//
//    $insert = "INSERT INTO connect_group_cont(contact_id, group_id) VALUES ('$contact', '$group')";
//    $result = mysqli_query($link, $insert);
//
//}