const express = require('express');
const router = express.Router();

//protected routes
const { isLoggedIn } =  require('../lib/auth');
//execute query
const pool = require('../database');

router.get('/clients', isLoggedIn, async (req , res) => {
    const clients = await pool.query('SELECT * FROM v_clientes');
    const category = await pool.query('SELECT*FROM categorias');
    res.render('links/clients', { clients, category, title: 'Clientes' });
});

router.post('/clientsRegister', (req, res) => {
    console.log(req.body);
});

module.exports = router;