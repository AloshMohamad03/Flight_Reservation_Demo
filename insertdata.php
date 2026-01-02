<?php
ob_start();
session_start();
header('Content-Type: application/json');

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "flight_reservation";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    ob_clean();
    echo json_encode(["status" => "error", "message" => "فشل الاتصال: " . $conn->connect_error]);
    exit;
}

$fname = $_POST['firstname'] ?? '';
$lname = $_POST['lastname'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (!empty($email) && !empty($password)) {

    $checkEmail = $conn->prepare("SELECT Email FROM customer WHERE Email = ?");
    $checkEmail->bind_param("s", $email);
    $checkEmail->execute();
    $result = $checkEmail->get_result();

    if ($result->num_rows > 0) {
        $res = ["status" => "error", "message" => "هذا البريد الإلكتروني مسجل بالفعل!"];
    } else {
        $sql = "INSERT INTO customer (FirstName, LastName, Passward, Email) VALUES (?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("ssss", $fname, $lname, $password, $email);

        if ($stmt->execute()) {
            $_SESSION['user_name'] = $fname; 
            $res = ["status" => "success", "message" => "تم التسجيل بنجاح!"];
            $res = ["status" => "success", "message" => "تم تسجيلك بنجاح في نظام الرحلات يا بروفيسور!"];
        } else {
            $res = ["status" => "error", "message" => "خطأ في الإدخال: " . $conn->error];
        }
        $stmt->close();
    }
    $checkEmail->close();
} else {
    $res = ["status" => "error", "message" => "يرجى إكمال البيانات"];
}

ob_clean();
echo json_encode($res);
$conn->close();
?>