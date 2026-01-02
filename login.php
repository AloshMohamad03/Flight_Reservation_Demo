<?php
header('Content-Type: application/json');
session_start();

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "flight_reservation";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    echo json_encode(['status' => 'error', 'message' => 'فشل الاتصال']);
    exit;
}

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

// استعلام لجلب البيانات - تأكد من مطابقة اسم العمود Type_1 تماماً كما في phpMyAdmin
$stmt = $conn->prepare("SELECT CustomerID, Email, Passward, FirstName, Type_1 FROM customer WHERE Email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();

 if (password_verify($password, $user['Passward']) || $password === $user['Passward']) {
        
        $_SESSION['CustomerID'] = $user['CustomerID'];
        $_SESSION['FirstName'] = $user['FirstName'];
        
        $rawType = trim($user['Type_1']); 
        $userType = (int)$rawType; 
        
        $_SESSION['Type_1'] = $userType;

        if ($userType === 1 || $rawType == "1") {
            $redirect_url = 'admin.php';
        } else {
            $redirect_url = 'index.html';
        }

        // --- التعديل هنا: إرسال بيانات المستخدم ليراها المتصفح ---
        echo json_encode([
            'status' => 'success', 
            'message' => 'تم التحقق بنجاح',
            'redirect' => $redirect_url,
            'user' => [
                'name' => $user['FirstName'],
                'email' => $user['Email'],
                'role' => ($userType === 1) ? 'Admin' : 'User'
            ],
            'debug_value' => $rawType 
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'كلمة المرور خطأ']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'الحساب غير موجود']);
}
$stmt->close();
$conn->close();
?>