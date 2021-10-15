const express = require('express');
//llamada para todas las rutas entrantes [GET] [POST]
const router = express.Router();
//llamada a la base de datos
const pool = require('../database');

const { isLoggedIn } = require('../lib/auth');

//req = request, res = response , next = siguiente
router.get('/', isLoggedIn, async (req, res, next) => {
    const resultNow = await pool.query('SELECT * FROM v_reservas_hoy');
    const resultPro = await pool.query('SELECT * FROM v_reservas_ahora');
    //console.log(result);
    res.render('index', {resultNow,resultPro,title: 'Inicio'});
});


//Exportacion de modulo para su uso en en index.js Rutas
module.exports = router;