const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  id: { type: String, unique: true, default: () => new mongoose.Types.ObjectId().toString() },
  title: { type: String, required: true },
  description: { type: String, required: true },
  status: { type: String, enum: ['To do', 'In progress', 'Done', 'Cancelled'], default: 'To do' },
  priority: { type: Number, enum: [1, 2, 3], default: 1 },
  dueDate: { type: Date },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  assignedTo: { type: String },
  createdBy: { type: String, required: true },
  category: { type: String },
  attachments: [{ type: String }],
  completed: { type: Boolean, default: false }
});

module.exports = mongoose.model('Task', taskSchema);