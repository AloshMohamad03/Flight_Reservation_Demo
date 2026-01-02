<?php
header('Content-Type: application/json');
session_start();

if (!isset($_SESSION['CustomerID'])) {
    echo json_encode(['status' => 'error', 'message' => 'غير مصرح لك']);
    exit;
}

$conn = new mysqli("localhost", "root", "", "flight_reservation");

$ticketID = $_POST['ticket_id'] ?? 0;
$newSeat = $_POST['new_seat'] ?? '';

// تحديث رقم المقعد
$sql = "UPDATE ticket SET SeatNumber = ? WHERE TicketID = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $newSeat, $ticketID);

if ($stmt->execute()) {
    echo json_encode(['status' => 'success', 'message' => 'تم تحديث رقم المقعد بنجاح']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'فشل تحديث البيانات']);
}

$stmt->close();
$conn->close();
?>