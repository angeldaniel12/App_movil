<?php
    require "conexion.php";

    $email=$_POST['email'];
    $password=$_POST['password'];

    $sql="SELECT * FROM email WHERE email='$email' AND password='$password'";
    $query=$mysqli->query($sql);
    if($query->num_rows >0){
        echo "correcto";
    }else{
        echo "error";
    }
?>