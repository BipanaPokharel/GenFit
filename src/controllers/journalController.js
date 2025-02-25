// controllers/journalController.js
const Journal = require("../models/journal");

exports.getAllEntries = async (req, res) => {
    try {
        const entries = await Journal.findAll();
        res.json(entries);
    } catch (err) {
        console.error("Error fetching journal entries:", err);
        res.status(500).json({ error: err.message });
    }
};

exports.addEntry = async (req, res) => {
    const { user_id, date, mood, notes } = req.body;

    console.log("Received data:", req.body);

    try {
        const entry = await Journal.create({
            user_id,
            date,
            mood,
            notes,
        });

        console.log("Entry created:", entry);

        res.status(201).json(entry);
    } catch (err) {
        console.error("Error adding journal entry:", err);
        res.status(500).json({ error: err.message });
    }
};

exports.updateEntry = async (req, res) => {
    const { id } = req.params;
    try {
        const entry = await Journal.findByPk(id);
        if (!entry) {
            return res.status(404).json({ message: 'Entry not found' });
        }
        await Journal.update(req.body, {
            where: {
                id: id
            }
        });
        res.status(200).json({ message: 'Entry updated successfully' });
    } catch (err) {
        console.error("Error updating journal entry:", err);
        res.status(500).json({ error: err.message });
    }
};

exports.deleteEntry = async (req, res) => {
    const { id } = req.params;
    try {
        const entry = await Journal.findByPk(id);
        if (!entry) {
            return res.status(404).json({ message: 'Entry not found' });
        }
        await Journal.destroy({
            where: {
                id: id
            }
        });
        res.status(200).json({ message: 'Entry deleted successfully' });
    } catch (err) {
        console.error("Error deleting journal entry:", err);
        res.status(500).json({ error: err.message });
    }
};
