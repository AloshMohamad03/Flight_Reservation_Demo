<?php
header('Content-Type: application/json');
session_start();

// التحقق من أن المستخدم مسجل دخول من خلال السيرفر أيضاً للأمان
if (!isset($_SESSION['CustomerID'])) {
    echo json_encode(['status' => 'error', 'message' => 'جلسة العمل انتهت، يرجى تسجيل الدخول ثانية']);
    exit;
}

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "flight_reservation";

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    echo json_encode(['status' => 'error', 'message' => 'فشل الاتصال بالقاعدة']);
    exit;
}

// استقبال البيانات القادمة من الجافا سكريبت
$customerID = $_SESSION['CustomerID'];
$totalAmount = $_POST['price'] ?? 0;
$paymentStatus = "Pending"; // حالة الدفع الافتراضية
$bookingDate = date('Y-m-d H:i:s');

// الاستعلام المتوافق مع أسماء أعمدتك
$sql = "INSERT INTO booking (CustomerID, BookingDate, TotalAmount, PaymentStatus) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("isds", $customerID, $bookingDate, $totalAmount, $paymentStatus);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'تم تسجيل الحجز بنجاح']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'خطأ أثناء الحجز: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>