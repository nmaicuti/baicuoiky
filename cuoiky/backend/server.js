const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const app = express();

app.use(express.json());

// Cấu hình multer để upload file
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Danh sách giả lập (thay bằng database thực tế)
let users = [];
let tasks = [];

// Middleware xác thực JWT và lấy thông tin user
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Access denied' });

  jwt.verify(token, 'secret_key', (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    // Tìm thông tin user để lấy role
    const currentUser = users.find(u => u.id === user.id);
    if (!currentUser) return res.status(404).json({ error: 'User not found' });
    req.user.role = currentUser.role; // Thêm role vào req.user
    next();
  });
};

// Đăng ký
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password, role } = req.body;
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    // Mặc định role là 'user' nếu không chỉ định, chỉ admin mới được tạo với role 'admin'
    const userRole = role && role === 'admin' ? 'admin' : 'user';
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = {
      id: String(users.length + 1),
      username,
      email,
      password: hashedPassword,
      role: userRole, // Thêm role
      avatar: null,
      createdAt: new Date(),
      lastActive: new Date(),
    };
    users.push(user);
    const token = jwt.sign({ id: user.id }, 'secret_key', { expiresIn: '1h' });
    res.status(201).json({ token, user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to register' });
  }
});

// Đăng nhập
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = users.find(u => u.email === email);
    if (!user) return res.status(404).json({ error: 'User not found' });
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });
    user.lastActive = new Date();
    const token = jwt.sign({ id: user.id }, 'secret_key', { expiresIn: '1h' });
    res.status(200).json({ token, user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to login' });
  }
});

// Lấy danh sách công việc
app.get('/api/tasks', authenticateToken, (req, res) => {
  let userTasks;
  if (req.user.role === 'admin') {
    // Admin có thể xem tất cả công việc
    userTasks = tasks;
  } else {
    // User thông thường chỉ xem công việc được gán cho họ
    userTasks = tasks.filter(task => task.assignedTo === req.user.id);
  }
  res.status(200).json(userTasks);
});

// Tạo công việc mới
app.post('/api/tasks', authenticateToken, (req, res) => {
  try {
    const taskData = req.body;
    const { assignedTo } = taskData;

    // Kiểm tra quyền gán công việc
    if (req.user.role !== 'admin' && assignedTo && assignedTo !== req.user.id) {
      return res.status(403).json({ error: 'Users can only assign tasks to themselves' });
    }

    // Kiểm tra xem assignedTo có tồn tại trong danh sách users không
    if (assignedTo && !users.find(u => u.id === assignedTo)) {
      return res.status(404).json({ error: 'Assigned user not found' });
    }

    const task = {
      id: String(tasks.length + 1),
      ...taskData,
      createdBy: req.user.id,
      createdAt: new Date(),
      updatedAt: new Date(),
      attachments: taskData.attachments || [],
      completed: taskData.completed || false,
    };
    tasks.push(task);
    res.status(201).json({ task });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// Cập nhật công việc
app.put('/api/tasks/:id', authenticateToken, (req, res) => {
  try {
    const taskId = req.params.id;
    const taskIndex = tasks.findIndex(task => task.id === taskId);
    if (taskIndex === -1) return res.status(404).json({ error: 'Task not found' });

    const task = tasks[taskIndex];
    // Kiểm tra quyền truy cập
    if (req.user.role !== 'admin' && task.assignedTo !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Kiểm tra quyền gán công việc khi cập nhật
    const { assignedTo } = req.body;
    if (req.user.role !== 'admin' && assignedTo && assignedTo !== req.user.id) {
      return res.status(403).json({ error: 'Users can only assign tasks to themselves' });
    }

    // Kiểm tra xem assignedTo có tồn tại không
    if (assignedTo && !users.find(u => u.id === assignedTo)) {
      return res.status(404).json({ error: 'Assigned user not found' });
    }

    tasks[taskIndex] = {
      ...tasks[taskIndex],
      ...req.body,
      updatedAt: new Date(),
    };
    res.status(200).json(tasks[taskIndex]);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// Xóa công việc
app.delete('/api/tasks/:id', authenticateToken, (req, res) => {
  try {
    const taskId = req.params.id;
    const taskIndex = tasks.findIndex(task => task.id === taskId);
    if (taskIndex === -1) return res.status(404).json({ error: 'Task not found' });

    const task = tasks[taskIndex];
    // Kiểm tra quyền truy cập
    if (req.user.role !== 'admin' && task.assignedTo !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    tasks.splice(taskIndex, 1);
    res.status(200).json({ message: 'Task deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

// Tải lên tệp đính kèm
app.post('/api/tasks/upload/:id', authenticateToken, upload.single('file'), (req, res) => {
  try {
    const taskId = req.params.id;
    const taskIndex = tasks.findIndex(task => task.id === taskId);
    if (taskIndex === -1) return res.status(404).json({ error: 'Task not found' });

    const task = tasks[taskIndex];
    // Kiểm tra quyền truy cập
    if (req.user.role !== 'admin' && task.assignedTo !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const fileUrl = `/uploads/${req.file.filename}`;
    tasks[taskIndex].attachments = tasks[taskIndex].attachments || [];
    tasks[taskIndex].attachments.push(fileUrl);
    res.status(200).json({ fileUrl });
  } catch (error) {
    res.status(500).json({ error: 'Failed to upload file' });
  }
});

app.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});