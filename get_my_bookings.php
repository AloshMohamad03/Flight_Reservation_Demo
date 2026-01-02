<?php
header('Content-Type: application/json');
session_start();

if (!isset($_SESSION['CustomerID'])) {
    echo json_encode(['status' => 'error', 'message' => 'غير مصرح']); exit;
}

$conn = new mysqli("localhost", "root", "", "flight_reservation");
$uid = $_SESSION['CustomerID'];

$sql = "SELECT t.TicketID, t.PassengerFirstName, t.SeatNumber, t.TicketStatus, b.BookingDate, b.TotalAmount 
        FROM ticket t 
        JOIN booking b ON t.BookingID = b.BookingID 
        WHERE b.CustomerID = ? AND t.TicketStatus != 'Cancelled'";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $uid);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while($row = $result->fetch_assoc()) { $data[] = $row; }

echo json_encode(['status' => 'success', 'bookings' => $data]);
?>