const express = require('express');
const router = express.Router();

//protected routes
const { isLoggedIn } =  require('../lib/auth');
//execute query
const pool = require('../database');

router.get('/clients', isLoggedIn, async (req , res) => {
    const clients = await pool.query('SELECT * FROM v_cliente');
    res.render('links/clients', { clients, title: 'Clientes' });
});

router.post('/clientsRegister', async (req, res) => {
    const registerClients = await pool.query('CALL p_nuevo_cliente(?)', [Object.values(req.body)]);
    const [[{...msg}]] = registerClients;
    req.flash('success', Object.values(msg));
    res.redirect('/clients');
});

router.get('/editClients/:id', isLoggedIn, async (req, res) => {
    
    const { id } =  req.params;
    const resultEdit =  await pool.query('SELECT*FROM v_cliente WHERE dni = ?', [id]);
    res.render('links/editClients', { edit: resultEdit[0], title: 'Editar Clientes' });
});

router.post('/editClients', isLoggedIn, async (req, res) => {
    const resultEdit = await pool.query('CALL p_actualizar_cliente(?)', [Object.values(req.body)]);
    const [[{...msg}]] = resultEdit;
    req.flash('success', Object.values(msg));
    res.redirect('/clients')
});

router.get('/deleteClients/:id', isLoggedIn, async (req, res) => {
    const { id } =  req.params;
    const resultDelete =  await pool.query('CALL p_eliminar_cliente(?)',[id]);
    const [[{...msg}]] =  resultDelete;
    req.flash('success', Object.values(msg));
    res.redirect('/clients');
});

module.exports = router;