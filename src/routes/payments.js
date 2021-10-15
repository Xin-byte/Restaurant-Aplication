const express = require('express');
const router = express.Router();
const pool = require('../database');
const helepers =  require('../lib/helpers');
const { isLoggedIn } = require('../lib/auth');
const { route } = require('./clients');
const upload = require('../lib/multer');

router.get('/payments/:id', async (req, res) => {
    const { id } = req.params;
    const types =  await pool.query('SELECT * FROM tipo_pago');
    res.render('links/payments',{id,types, title: 'Pagar'});
})

router.post('/payments', async (req, res) => {
    const [[{...msg}]] = await pool.query('CALL p_procesar_pago(?)',[Object.values(req.body)])
    req.flash('success', Object.values(msg));
    res.redirect('/reservation');
})
module.exports = router