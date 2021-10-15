const express = require('express');
const router = express.Router();
const pool = require('../database');
const helepers =  require('../lib/helpers');
const { isLoggedIn } = require('../lib/auth');

router.get('/reportFacture', isLoggedIn, (req, res) => {
    res.render('links/reportFacture')
});

router.get('/reportReservation/:id', isLoggedIn, async(req, res) => {
    const {id} =  req.params;
    const dataReservation = await pool.query('CALL p_datos_reserva(?)',[id]);
    const [[{...data}]] = dataReservation;
    console.log(data);
    res.render('links/reportReservation', {data});
});
/*router.get('/reportReservation/:id', isLoggedIn, (req, res) => {
    const { id } =  req.params;
    res.redirect('/reportReservation/'+id);
});*/
router.get('/reportClient', async (req, res) => {
    const clients =  await pool.query('SELECT * FROM v_cliente');
    res.render('links/reportClient', {clients, title: 'Reporte Cliente'})
})


module.exports = router;