const express = require('express');
const router =  express.Router();
//validation
const { isLoggedIn } =  require('../lib/auth')
//pool querys
const pool =  require('../database');

router.get('/dish', isLoggedIn, async (req, res) => {
    const dish =  await pool.query('SELECT*FROM v_platos');
    const typeDish =  await pool.query('SELECT * FROM tipo_platos');
    const specialties =  await pool.query('SELECT * FROM especialidades');
    res.render('links/dish', { dish, typeDish, specialties, title: 'Platos' });
});

router.post('/dishRegister', isLoggedIn, async (req, res) => {
    const resultRegister =  await pool.query('CALL p_nuevo_plato(?)',[Object.values(req.body)]);
    const [[{...msg}]] =  resultRegister;
    req.flash('success', Object.values(msg));
    res.redirect('/dish');
});

router.get('/editDish/:id', isLoggedIn, async (req, res) => {
    const { id } = req.params;
    const edit = await pool.query('SELECT * FROM v_platos WHERE ID = ?',[id]);
    const typeDish =  await pool.query('SELECT * FROM tipo_platos WHERE nom_tipoplato != ?',[edit[0].TIPO]);
    const specialties =  await pool.query('SELECT * FROM especialidades WHERE nomespecialidad != ?',[edit[0].ESPECIALIDAD]);
    //console.log(typeDish);
    res.render('links/editDish', {edit: edit[0], typeDish, specialties
    , title: 'Editar Plato' })
});

router.post('/editDish', isLoggedIn, async (req, res) => {
    const resultEdit = await pool.query('CALL p_actualizar_plato(?)',[Object.values(req.body)]);
    const [[{...msg}]] = resultEdit;
    req.flash('success', Object.values(msg));
    res.redirect('/dish');
});

router.get('/deleteDish/:id', isLoggedIn, async (req, res) => {
    const {id } = req.params;
    const resultDelete = await pool.query('CALL p_eliminar_plato(?)', [id]);
    const [[{...msg}]] =  resultDelete;
    req.flash('success', Object.values(msg));
    res.redirect('/dish');
});

module.exports =  router;