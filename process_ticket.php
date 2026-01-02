<?php
header('Content-Type: application/json');
session_start();

if (!isset($_SESSION['CustomerID'])) {
    echo json_encode(['status' => 'error', 'message' => 'الرجاء تسجيل الدخول']);
    exit;
}

$conn = new mysqli("localhost", "root", "", "flight_reservation");

// 1. إدخال سجل الحجز (Booking)
$custID = $_SESSION['CustomerID'];
$amount = $_POST['total_amount'];
$date = date('Y-m-d H:i:s');

$sql1 = "INSERT INTO booking (CustomerID, BookingDate, TotalAmount, PaymentStatus) VALUES (?, ?, ?, 'Confirmed')";
$stmt1 = $conn->prepare($sql1);
$stmt1->bind_param("isd", $custID, $date, $amount);
$stmt1->execute();
$newBookingID = $conn->insert_id; // جلب الـ ID الذي تم إنشاؤه للتو

// 2. إدخال سجل التذكرة (Ticket)
$fName = $_POST['p_firstname'];
$lName = $_POST['p_lastname'];
$passport = $_POST['passport'];
$seat = $_POST['seat'];
$fareID = 1; // يمكن تعديله ليكون ديناميكياً لاحقاً
$status = "Active";

$sql2 = "INSERT INTO ticket (BookingID, FareID, PassengerFirstName, PassengerLastName, PassportNumber, SeatNumber, TicketStatus) VALUES (?, ?, ?, ?, ?, ?, ?)";
$stmt2 = $conn->prepare($sql2);
$stmt2->bind_param("iisssss", $newBookingID, $fareID, $fName, $lName, $passport, $seat, $status);

if ($stmt2->execute()) {
    echo json_encode(['status' => 'success', 'ticket_id' => $conn->insert_id]);
} else {
    echo json_encode(['status' => 'error', 'message' => $conn->error]);
}
?>