
<?php
session_start();
if (!isset($_SESSION['Type_1']) || $_SESSION['Type_1'] != 1) {
    header("Location: login.html");
    exit();
}
// اتصال قاعدة البيانات
$host = 'localhost'; $db = 'flight_reservation'; $user = 'root'; $pass = '';
try {
    $conn = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) { die("Connection failed: " . $e->getMessage()); }

$active_tab = $_GET['tab'] ?? 'flights';
$search = $_GET['search'] ?? '';

// --- منطق المعالجة (إضافة، تعديل، وحذف) ---
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // 1. منطق الإضافة (Add)
    if (isset($_POST['add_airport'])) {
        $stmt = $conn->prepare("INSERT INTO airport (AirportCode, Name, City, Country) VALUES (?, ?, ?, ?)");
        $stmt->execute([$_POST['code'], $_POST['name'], $_POST['city'], $_POST['country']]);
    } 
    elseif (isset($_POST['add_flight'])) {
        $stmt = $conn->prepare("INSERT INTO flight (FlightNumber, Airline, AirCraftType, TotalSeats) VALUES (?, ?, ?, ?)");
        $stmt->execute([$_POST['f_num'], $_POST['airline'], $_POST['aircraft'], $_POST['seats']]);
    }
    elseif (isset($_POST['add_customer'])) {
        $stmt = $conn->prepare("INSERT INTO customer (FirstName, LastName, Email, PhoneNumber) VALUES (?, ?, ?, ?)");
        $stmt->execute([$_POST['fname'], $_POST['lname'], $_POST['email'], $_POST['phone']]);
    }

    // 2. منطق التعديل (Update)
    if (isset($_POST['update_record'])) {
        if ($active_tab == 'airports') {
            $stmt = $conn->prepare("UPDATE airport SET AirportCode=?, Name=?, City=?, Country=? WHERE AirportID=?");
            $stmt->execute([$_POST['code'], $_POST['name'], $_POST['city'], $_POST['country'], $_POST['id']]);
        } elseif ($active_tab == 'flights') {
            $stmt = $conn->prepare("UPDATE flight SET FlightNumber=?, Airline=?, AirCraftType=?, TotalSeats=? WHERE FlightID=?");
            $stmt->execute([$_POST['f_num'], $_POST['airline'], $_POST['aircraft'], $_POST['seats'], $_POST['id']]);
        } elseif ($active_tab == 'customers') {
            $stmt = $conn->prepare("UPDATE customer SET FirstName=?, LastName=?, Email=?, PhoneNumber=? WHERE CustomerID=?");
            $stmt->execute([$_POST['fname'], $_POST['lname'], $_POST['email'], $_POST['phone'], $_POST['id']]);
        }
    }

    // 3. منطق الحذف (Delete) - المضاف حديثاً
    if (isset($_POST['delete_record'])) {
        $id_to_delete = $_POST['delete_id'];
        if ($active_tab == 'airports') {
            $stmt = $conn->prepare("DELETE FROM airport WHERE AirportID = ?");
        } elseif ($active_tab == 'flights') {
            $stmt = $conn->prepare("DELETE FROM flight WHERE FlightID = ?");
        } elseif ($active_tab == 'customers') {
            $stmt = $conn->prepare("DELETE FROM customer WHERE CustomerID = ?");
        }
        $stmt->execute([$id_to_delete]);
    }

    header("Location: ".$_SERVER['PHP_SELF']."?tab=$active_tab");
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pro Dashboard | Ali Mahmoud</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #1e40af; --accent: #10b981; --bg: #f8fafc; --sidebar: #1e293b; --warning: #f59e0b; --danger: #ef4444; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); margin: 0; display: flex; }
        .sidebar { width: 260px; background: var(--sidebar); height: 100vh; color: white; padding: 20px; position: fixed; }
        .sidebar h3 { font-size: 20px; border-bottom: 1px solid #334155; padding-bottom: 15px; color: #38bdf8; }
        .sidebar a { display: block; color: #cbd5e1; padding: 12px; text-decoration: none; border-radius: 8px; margin-bottom: 8px; transition: 0.3s; }
        .sidebar a:hover, .sidebar a.active { background: var(--primary); color: white; }
        .main-content { margin-left: 260px; padding: 40px; width: calc(100% - 260px); }
        .card { background: white; padding: 25px; border-radius: 15px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05); }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #f1f5f9; }
        .add-form { background: #f1f5f9; padding: 20px; border-radius: 10px; margin-bottom: 25px; display: none; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 15px; }
        input { padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; }
        .btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; transition: 0.2s; }
        .btn-toggle { background: #6366f1; color: white; margin-bottom: 20px; }
        .btn-edit { background: var(--warning); color: white; padding: 5px 12px; font-size: 12px; margin-right: 5px; }
        .btn-delete { background: var(--danger); color: white; padding: 5px 12px; font-size: 12px; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: white; margin: 10% auto; padding: 30px; border-radius: 12px; width: 400px; }
        .action-cell { display: flex; }
    </style>
</head>
<body>

<div class="sidebar">
    <h3>Flight Admin</h3>
    <a href="?tab=flights" class="<?= $active_tab == 'flights' ? 'active' : '' ?>">✈️ Flights</a>
    <a href="?tab=airports" class="<?= $active_tab == 'airports' ? 'active' : '' ?>">🏢 Airports</a>
    <a href="?tab=customers" class="<?= $active_tab == 'customers' ? 'active' : '' ?>">👥 Customers</a>
</div>

<div class="main-content">
    <button onclick="toggleAddForm()" class="btn btn-toggle">+ Add New Record</button>

    <div class="card">
        <?php if($active_tab == 'airports'): ?>
            <h2>Airport Management</h2>
            <div id="addForm" class="add-form">
                <form method="POST" class="form-grid">
                    <input type="text" name="code" placeholder="Code" required>
                    <input type="text" name="name" placeholder="Name" required>
                    <input type="text" name="city" placeholder="City" required>
                    <input type="text" name="country" placeholder="Country" required>
                    <button type="submit" name="add_airport" class="btn" style="background:var(--accent); color:white;">Save</button>
                </form>
            </div>
            <table>
                <thead><tr><th>Code</th><th>Name</th><th>City</th><th>Actions</th></tr></thead>
                <tbody>
                    <?php
                    $stmt = $conn->prepare("SELECT * FROM airport WHERE Name LIKE :s OR City LIKE :s");
                    $stmt->execute(['s' => "%$search%"]);
                    foreach($stmt->fetchAll() as $row) {
                        echo "<tr><td>{$row['AirportCode']}</td><td>{$row['Name']}</td><td>{$row['City']}</td>
                        <td class='action-cell'>
                            <button class='btn btn-edit' onclick='openEditModal(\"airports\", ".json_encode($row).")'>Edit</button>
                            <form method='POST' onsubmit='return confirm(\"Are you sure you want to delete this airport?\")'>
                                <input type='hidden' name='delete_id' value='{$row['AirportID']}'>
                                <button type='submit' name='delete_record' class='btn btn-delete'>Delete</button>
                            </form>
                        </td></tr>";
                    }
                    ?>
                </tbody>
            </table>

        <?php elseif($active_tab == 'flights'): ?>
            <h2>Flight Schedule</h2>
            <div id="addForm" class="add-form">
                <form method="POST" class="form-grid">
                    <input type="text" name="f_num" placeholder="Flight #" required>
                    <input type="text" name="airline" placeholder="Airline" required>
                    <input type="text" name="aircraft" placeholder="Aircraft Type">
                    <input type="number" name="seats" placeholder="Seats">
                    <button type="submit" name="add_flight" class="btn" style="background:var(--accent); color:white;">Save</button>
                </form>
            </div>
            <table>
                <thead><tr><th>Flight #</th><th>Airline</th><th>Aircraft</th><th>Actions</th></tr></thead>
                <tbody>
                    <?php
                    $stmt = $conn->prepare("SELECT * FROM flight WHERE FlightNumber LIKE :s");
                    $stmt->execute(['s' => "%$search%"]);
                    foreach($stmt->fetchAll() as $row) {
                        echo "<tr><td>{$row['FlightNumber']}</td><td>{$row['Airline']}</td><td>{$row['AirCraftType']}</td>
                        <td class='action-cell'>
                            <button class='btn btn-edit' onclick='openEditModal(\"flights\", ".json_encode($row).")'>Edit</button>
                            <form method='POST' onsubmit='return confirm(\"Are you sure you want to delete this flight?\")'>
                                <input type='hidden' name='delete_id' value='{$row['FlightID']}'>
                                <button type='submit' name='delete_record' class='btn btn-delete'>Delete</button>
                            </form>
                        </td></tr>";
                    }
                    ?>
                </tbody>
            </table>

        <?php elseif($active_tab == 'customers'): ?>
            <h2>Customer List</h2>
            <div id="addForm" class="add-form">
                <form method="POST" class="form-grid">
                    <input type="text" name="fname" placeholder="First Name" required>
                    <input type="text" name="lname" placeholder="Last Name" required>
                    <input type="email" name="email" placeholder="Email" required>
                    <input type="text" name="phone" placeholder="Phone">
                    <button type="submit" name="add_customer" class="btn" style="background:var(--accent); color:white;">Add Customer</button>
                </form>
            </div>
            <table>
                <thead><tr><th>Full Name</th><th>Email</th><th>Phone</th><th>Actions</th></tr></thead>
                <tbody>
                    <?php
                    $stmt = $conn->prepare("SELECT * FROM customer WHERE FirstName LIKE :s OR Email LIKE :s");
                    $stmt->execute(['s' => "%$search%"]);
                    foreach($stmt->fetchAll() as $row) {
                        echo "<tr><td>{$row['FirstName']} {$row['LastName']}</td><td>{$row['Email']}</td><td>{$row['PhoneNumber']}</td>
                        <td class='action-cell'>
                            <button class='btn btn-edit' onclick='openEditModal(\"customers\", ".json_encode($row).")'>Edit</button>
                            <form method='POST' onsubmit='return confirm(\"Delete this customer permanently?\")'>
                                <input type='hidden' name='delete_id' value='{$row['CustomerID']}'>
                                <button type='submit' name='delete_record' class='btn btn-delete'>Delete</button>
                            </form>
                        </td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</div>

<div id="editModal" class="modal">
    <div class="modal-content">
        <h3>Edit Record</h3>
        <form method="POST">
            <input type="hidden" name="id" id="edit_id">
            <div id="modalFields"></div>
            <button type="submit" name="update_record" class="btn" style="background:var(--primary); color:white; width:100%; margin-top:10px;">Update</button>
            <button type="button" onclick="closeModal()" class="btn" style="background:#ddd; width:100%; margin-top:5px;">Cancel</button>
        </form>
    </div>
</div>



<script>
    function toggleAddForm() {
        var x = document.getElementById("addForm");
        x.style.display = (x.style.display === "none" || x.style.display === "") ? "block" : "none";
    }

    function openEditModal(tab, data) {
        const fields = document.getElementById('modalFields');
        const idInput = document.getElementById('edit_id');
        fields.innerHTML = ''; 

        if (tab === 'airports') {
            idInput.value = data.AirportID;
            fields.innerHTML = `
                <input type="text" name="code" value="${data.AirportCode}" style="width:100%; margin-bottom:10px">
                <input type="text" name="name" value="${data.Name}" style="width:100%; margin-bottom:10px">
                <input type="text" name="city" value="${data.City}" style="width:100%; margin-bottom:10px">
                <input type="text" name="country" value="${data.Country}" style="width:100%; margin-bottom:10px">`;
        } else if (tab === 'flights') {
            idInput.value = data.FlightID;
            fields.innerHTML = `
                <input type="text" name="f_num" value="${data.FlightNumber}" style="width:100%; margin-bottom:10px">
                <input type="text" name="airline" value="${data.Airline}" style="width:100%; margin-bottom:10px">
                <input type="text" name="aircraft" value="${data.AirCraftType}" style="width:100%; margin-bottom:10px">
                <input type="number" name="seats" value="${data.TotalSeats}" style="width:100%; margin-bottom:10px">`;
        } else if (tab === 'customers') {
            idInput.value = data.CustomerID;
            fields.innerHTML = `
                <input type="text" name="fname" value="${data.FirstName}" style="width:100%; margin-bottom:10px">
                <input type="text" name="lname" value="${data.LastName}" style="width:100%; margin-bottom:10px">
                <input type="email" name="email" value="${data.Email}" style="width:100%; margin-bottom:10px">
                <input type="text" name="phone" value="${data.PhoneNumber}" style="width:100%; margin-bottom:10px">`;
        }
        document.getElementById('editModal').style.display = 'block';
    }

    function closeModal() { document.getElementById('editModal').style.display = 'none'; }
</script>

</body>
</html>