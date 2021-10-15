const express = require('express');
const router = express.Router();
const pool = require('../database');
const helepers =  require('../lib/helpers');
const { isLoggedIn } = require('../lib/auth');
const days = require('dayjs');

router.get('/reservation', isLoggedIn, async (req, res) => {
    
    const reservation = await pool.query('SELECT * FROM v_reservav');
    const turn =  await pool.query('SELECT*FROM turnos');
    const clients = await pool.query('SELECT*FROM v_cliente');
    //const type =  await pool.query('')
    const validateDate = days(new Date()).format('YYYY-MM-DD');
    const validateTime = days(new Date()).format('hh:mm:ss')
    console.log(validateTime);
    res.render('links/reservation', {  clients,validateTime,validateDate,turn, reservation, title: 'Rervas'});
});

router.post('/newReservation', async(req, res) => {
    const newReservation = await pool.query('CALL p_crear_reserva(?)',[Object.values(req.body)]);
    const [[{...msg}]] = newReservation;
    req.flash('success', Object.values(msg));
    res.redirect('/reservation')
})
module.exports = router