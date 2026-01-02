<?php
// ابدأ الجلسة
session_start();

// اذا حاول تسجيل الدخول ولم يكن مسجل دخول مسبقاً
if (isset($_POST['login']) && !isset($_SESSION['client_id'])) {
    include("connection.php");

    // احصل على بيانات تسجيل الدخول
    $user_email = trim($_POST['client_email']);
    $user_password = trim($_POST['client_pwd']);
    if (!empty($user_email) && !empty($user_password)) {
        // الاستعلام حسب جدول clients
        $query = "SELECT * FROM clients WHERE client_email = ? AND client_pwd = ?";
        $stmt = $conn->prepare($query);
        $stmt->execute([$user_email, sha1($user_password)]);
        $client = $stmt->fetch();
        $count = $stmt->rowCount();

        if ($count == 1) {
            // تخزين بيانات العميل في الجلسة
            $_SESSION['client_id'] = $client['client_id'];
            $_SESSION['client_email'] = $client['client_email'];
            $_SESSION['client_name'] = $client['client_name'];

            // الانتقال للصفحة الرئيسية
            $home_url = 'http://' . $_SERVER['HTTP_HOST'] . dirname($_SERVER['PHP_SELF']) . '/index.php';
            header('Location: ' . $home_url);
        } else {
            header('Location: login.php?message=error');
        }
    } else {
        header('Location: login.php?message=empty');
    }
} else {
    // المستخدم مسجل دخول مسبقاً
    echo ('<p>You are logged in as ' . $_SESSION['client_name'] . '.</p>');
    echo "<a href='logout.php'>logout</a>";
}
