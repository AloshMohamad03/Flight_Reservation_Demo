<?php
header('Content-Type: application/json');
session_start();

if (!isset($_SESSION['CustomerID'])) {
    echo json_encode(['status' => 'error', 'message' => 'يجب تسجيل الدخول أولاً']);
    exit;
}

$conn = new mysqli("localhost", "root", "", "flight_reservation");
$ticketID = $_GET['id'] ?? 0;

// تحديث حالة التذكرة في قاعدة البيانات
$sql = "UPDATE ticket SET TicketStatus = 'Cancelled' WHERE TicketID = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $ticketID);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'تم إلغاء الحجز بنجاح']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'فشل في عملية الإلغاء']);
}

$stmt->close();
$conn->close();
?>