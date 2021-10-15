const express = require('express');
const router =  express.Router();
//validation
const { isLoggedIn } =  require('../lib/auth')
//pool querys
const pool =  require('../database');
const upload = require('../lib/multer');

router.get('/addDish/:id', async (req, res) => {
    const { id } =  req.params
    const [[...data]] =  await pool.query('CALL p_ver_detalles(?)',[id]);
    const dish =  await pool.query('select * from v_platos vp where not EXISTS(select * from detalles d where vp.ID=d.fk_idPlato and d.fk_idReserva = ?)',[id]); 
    res.render('links/addDish', {id,data, dish,title: 'Agregar Platos'})
});

router.get('/removeDish/:id&:idr', async(req, res) => {
    const { id, idr } =  req.params;
    //const [[{...msg}]] = 
    const [[{...msg}]] =  await pool.query('CALL p_eliminar_detalle_plato(?,?)',[idr, id]);
    req.flash('success', Object.values(msg));
    res.redirect('/reservation/addDish/'+idr)
});

router.post('/addeDish', async(req, res) => {
    const [[{...msg}]] = await pool.query('CALL p_agregar_detalle_plato(?)',[Object.values(req.body)])
    req.flash('success', Object.values(msg));
    res.redirect('/reservation/addDish/'+req.body.reser)

})

module.exports = router;